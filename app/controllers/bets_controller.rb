require 'test.rb'
require_relative "../constants/bet_post_constants.rb"
require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'aws-sdk-dynamodb'
require 'aws-sdk-ses'
require 'twilio-ruby'

class BetsController < ApplicationController
  before_action :set_user
  respond_to :html, :js

  def placebet
    #puts "placebet"
    #puts params
    @friend = User.find_by(id: params[:friend_id])
    @@friend_user = @friend
    @game = Odd.find params[:game]
    @bet = Bet.new
  end

  def allbets
    #puts "allbets"
    # setting a hash that maps team abbreviations to team names
    # used later in string comparisons
    team_names = {
      'ATL' => 'Atlanta Hawks',
      'BKN' => 'Brooklyn Nets',
      'BOS' => 'Boston Celtics',
      'CHA' => 'Charlotte Hornets',
      'CHI' => 'Chicago Bulls',
      'CLE' => 'Cleveland Cavaliers',
      'DAL' => 'Dallas Mavericks',
      'DEN' => 'Denver Nuggets',
      'DET' => 'Detroit Pistons',
      'GSW' => 'Golden State Warriors',
      'HOU' => 'Houston Rockets',
      'IND' => 'Indiana Pacers',
      'LAC' => 'Los Angeles Clippers',
      'LAL' => 'Los Angeles Lakers',
      'MEM' => 'Memphis Grizzlies',
      'MIA' => 'Miami Heat',
      'MIL' => 'Milwaukee Bucks',
      'MIN' => 'Minnesota Timberwolves',
      'NOP' => 'New Orleans Pelicans',
      'NYK' => 'New York Knicks',
      'OKC' => 'Oklahoma City Thunder',
      'ORL' => 'Orlando Magic',
      'PHI' => 'Philadelphia 76ers',
      'PHX' => 'Phoenix Suns',
      'POR' => 'Portland Trail Blazers',
      'SAC' => 'Sacramento Kings',
      'SAS' => 'San Antonio Spurs',
      'TOR' => 'Toronto Raptors',
      'UTA' => 'Utah Jazz',
      'WAS' => 'Washington Wizards'
    }

    # get all the bets of the current user
    @user_bets = Bet.get_by_userid(current_user.id)

    # for each bet
    @user_bets.each do |bet|


      # only proceed with confirmed bets
      if (bet.status == 'confirmed')

        # get the date of the game in the right format
        date_string = Date.strptime(bet.date, '%H:%M %z %m/%d/%Y').strftime('%Y-%m-%d')

        # add the date of the game to the query string
        url_without_date = "https://api-basketball.p.rapidapi.com/games?timezone=America%2FNew_York&season=2022-2023&league=12&date="
        url_with_date = url_without_date + date_string

        # send the API request
        url = URI(url_with_date)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(url)
        request["X-RapidAPI-Key"] = 'b75f06b51amshedbb7bbb363591fp1d8c49jsnea0e9ea45d3b'
        request["X-RapidAPI-Host"] = 'api-basketball.p.rapidapi.com'
        response = http.request(request)

        # parse the response
        parsed_response = JSON.parse(response.read_body)
        games_information = parsed_response['response']

        # for each game in the response
        games_information.each do |game|

          # if the game has the same teams (and date from before), proceed
          if ((team_names[bet.home_team_name] == game['teams']['home']['name']) &&
            (team_names[bet.away_team_name] == game['teams']['away']['name']))

            # if the game is finished, proceed
            if game['status']['long'] == 'Game Finished'

              #get the final scores of the game
              scores = game['scores']
              home_score = scores['home']['total']
              away_score = scores['away']['total']

              # establish whether Home or Away won
              if (home_score > away_score)
                winning_team = 'Home Team'
              else
                winning_team = 'Away Team'
              end

              # get the users of the bet
              @user_one = User.find_by(id: bet.user_id_one)
              @user_two = User.find_by(id: bet.user_id_two)

              # get the amount wagered as a float
              @amount = (bet.amount).to_f

              # figure out which odds to use for the winnings based
              # on outcome of the game
              if (winning_team == 'Home Team')
                odds = (bet.home_money_line).to_f
              else
                odds = (bet.away_money_line).to_f
              end

              # apply the US odds formula to calculate the winnings
              if (odds > 0.0)
                @winning_amount = (@amount / 100.0) * odds
              else
                @winning_amount = (@amount / (-odds)) * 100.0
              end

              # setting variables to make post
              @bet = bet
              admin_user = User.get_admin_user()

              # if user one won
              if (bet.betting_on == winning_team)

                # increase his actual balance by the winnings
                @user_one.decrease_balance(-@winning_amount)

                # remove wagered amount from escrow
                @user_one.increase_balance_in_escrow(-@amount)

                # remove amount wagered from actual balance of user two
                @user_two.decrease_balance(@amount)

                # remove wagered amount from escrow
                @user_two.increase_balance_in_escrow(-@amount)
                #puts 'User two lost'

                # making post that User One Won
                content_string = create_bet_won_message_string(@user_one, @user_two, @bet)
                test = { "content" => content_string }
                @post = admin_user.posts.new(test)
                @post.save
              else

                # increase his actual balance by the winnings
                @user_two.decrease_balance(-@winning_amount)

                # remove wagered amount from escrow
                @user_two.increase_balance_in_escrow(-@amount)

                # remove amount wagered from actual balance of user two
                @user_one.decrease_balance(@amount)

                # remove wagered amount from escrow
                @user_one.increase_balance_in_escrow(-@amount)
                #puts 'User one lost'

                # making post that User Two Won
                content_string = create_bet_won_message_string(@user_two, @user_one, @bet)
                test = { "content" => content_string }
                @post = admin_user.posts.new(test)
                @post.save
              end

              # change the status of the bet and save it
              bet.status = 'finished'
              bet.save
            else
              date_string = bet['date']
              date_object = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')
              if (date_object.hour < 12)
                date_object = date_object + (12/24.0)
              end
              early = date_object - (2/24.0)
              current_time = DateTime.now
              toolate_boolean = current_time.ctime > early.ctime
              bet.toolate = toolate_boolean
              bet.save
            end

            # whether or not the game is finished,
            # once we have found the game, we do not
            # want to further check games of this day
            break
          end
        end
      elsif (bet.status == 'proposed')
        if not((team_names[bet.home_team_name] == 'New York Knicks') &&
          (team_names[bet.away_team_name] == 'Oklahoma City Thunder') &&
          (bet.date == "12:10 ET 11/13/2022"))
          date_string = bet['date']
          date_object = DateTime.strptime(date_string, '%H:%M %z %m/%d/%Y')
          if (date_object.hour < 12)
            date_object = date_object + (12/24.0)
          end
          #early = date_object - (2/24.0)
          current_time = DateTime.now
          toolate_boolean = current_time.ctime > date_object.ctime
          bet.toolate = toolate_boolean
          if (toolate_boolean)
            bet.status = 'cancelled'
          end
          bet.save
        end

      end
    end
  end

  def new
    #puts "new"
    @bet = Bet.new
  end

  def updatebet
    #puts "updatebet"
  end

  def confirm
    #puts "confirm"
    # @bet = Bet.find params[:id]
    # admin_user = User.get_admin_user()
    # @friend= User.find_by(id: params[:friend_id])
    # @@friend_user = @friend
    # content_string = create_bet_message_string(current_user, @@friend_user, @bet)
    # test = {"content"=> content_string}
    # @post = admin_user.posts.new(test)
    # @post.save
  end

  def receive
    #puts "receive"
    @bet = Bet.find params[:id]
    @amount = @bet.amount
    if (current_user.actualBalance - current_user.balanceInEscrow) - @amount < 0.0
      redirect_to allbets_bet_path(current_user), notice: "Insufficient Funds"
      return
    else
      current_user.increase_balance_in_escrow(@amount)
    end
    @bet.status = 'confirmed'
    @bet.save
    admin_user = User.get_admin_user()
    @friend = User.find_by(id: @bet.user_id_two)
    @@friend_user = @friend
    @original = User.find_by(id: @bet.user_id_one)
    @@original_user = @original
    content_string = create_bet_message_string(@@original_user, @@friend_user, @bet)
    test = { "content" => content_string }
    @post = admin_user.posts.new(test)
    @post.save
    unique_hash = @bet.user_one_name + '_' + @bet.user_two_name + '_' + @bet.home_team_name + '_' + @bet.away_team_name + '_' + @bet.betting_on + '_' + @bet.amount.to_s + '_' + @bet.date + '_' + @bet.status
    dynamodb_client = Aws::DynamoDB::Client.new(region: 'us-east-1', access_key_id: 'AKIAQNW4F2IKHDRYMOHR', secret_access_key: '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')
    table_item = {
      table_name: 'bets',
      item: {
        user_names_game: unique_hash,
        user_one_name: @bet.user_one_name,
        user_two_name: @bet.user_two_name,
        user_id_one: @bet.user_id_one,
        user_id_two: @bet.user_id_two,
        user_one_email: @original.email,
        user_two_email: @friend.email,
        home_team_name: @bet.home_team_name,
        away_team_name: @bet.away_team_name,
        betting_on: @bet.betting_on,
        home_money_line: @bet.home_money_line,
        away_money_line: @bet.away_money_line,
        amount: @bet.amount,
        date: @bet.date,
        status: @bet.status
      }
    }
    dynamodb_client.put_item(table_item)
    sender = 'andybirla96@gmail.com'
    recipient_user = User.find_by(id: @bet.user_id_one)
    recipient = recipient_user.email
    recipient_phone_number = recipient_user.phone_number
    allowed_emails = ['ab5188@columbia.edu', 'andybirla96@gmail.com', 'andy.birla21@gmail.com', 'andymbirla@gmail.com']
    allowed_numbers = ['3108479740']
    if (not(allowed_emails.include? recipient))
      recipient = 'andybirla96@gmail.com'
    end
    if (not(allowed_numbers.include? recipient_phone_number))
      recipient_phone_number = '+13108479740'
    else 
      recipient_phone_number = "+1" + recipient_phone_number
    end
    subject = '[Betwork] Your bet with ' + @bet.user_two_name + ' was confirmed.'
    textbody = 'Hi ' + @bet.user_one_name + '!' + "\n" + "\n"
    textbody += @bet.user_two_name + ' confirmed the bet you placed against them! '
    if (@bet.betting_on == 'Home Team')
      team_1 = @bet.home_team_name
      team_2 = @bet.away_team_name
    else
      team_2 = @bet.home_team_name
      team_1 = @bet.away_team_name
    end
    textbody += 'They agreed to bet USD' + @bet.amount.to_s + ' on ' + team_2 + ' in ' + @bet.home_team_name + ' vs. ' + @bet.away_team_name + ' on ' + @bet.date + '.' + "\n" + "\n"
    textbody += 'Log into Betwork to view and/or cancel the bet.'
    encoding = 'UTF-8'
    ses = Aws::SES::Client.new(region: 'us-east-1', access_key_id: 'AKIAQNW4F2IKHDRYMOHR', secret_access_key: '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')
    twilio_client = Twilio::REST::Client.new(
      'AC301826b0bd8c63c945aeae5288b45720',
      'f3a42abcb29d4bb549cd003b2dc7d749'
    )
    # Try to send the text.
    begin 
      message = twilio_client.messages.create(
        body: textbody,
        to: recipient_phone_number,
        from: "+19295818779"
      )
      puts "Text successfully sent!"
    rescue Twilio::REST::TwilioError => error
      puts "Text not sent. Error message: #{error}"
    end

    # Try to send the email.
    begin
      # Provide the contents of the email.
      ses.send_email(
        destination: {
          to_addresses: [
            recipient
          ]
        },
        message: {
          body: {
            text: {
              charset: encoding,
              data: textbody
            }
          },
          subject: {
            charset: encoding,
            data: subject
          }
        },
        source: sender,
      # Uncomment the following line to use a configuration set.
      # configuration_set_name: configsetname,
        )

      puts 'Confirmation Email sent to ' + recipient


      # If something goes wrong, display an error message.
    rescue Aws::SES::Errors::ServiceError => error
      puts "Confirmation Email not sent. Error message: #{error}"
    end
    redirect_to allbets_bet_path(current_user), notice: "Bet Accepted!"
  end

  def cancel
    #puts "cancel"
    @bet = Bet.find params[:id]
    @amount = @bet.amount
    @status = @bet.status
    @friend = User.find_by(id: @bet.user_id_two)
    if (current_user.name == @bet.user_two_name)
      @friend = User.find_by(id: @bet.user_id_one)
    end
    if (@status == 'confirmed')
      current_user.increase_balance_in_escrow(-@amount)
      @friend.increase_balance_in_escrow(-@amount)
      admin_user = User.get_admin_user()
      @@friend_user = @friend
      content_string = create_bet_cancel_message_string(current_user, @@friend_user, @bet)
      test = { "content" => content_string }
      @post = admin_user.posts.new(test)
      @post.save
      dynamodb_client = Aws::DynamoDB::Client.new(region: 'us-east-1', access_key_id: 'AKIAQNW4F2IKHDRYMOHR', secret_access_key: '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')
      unique_hash = @bet.user_one_name + '_' + @bet.user_two_name + '_' + @bet.home_team_name + '_' + @bet.away_team_name + '_' + @bet.betting_on + '_' + @bet.amount.to_s + '_' + @bet.date + '_' + @bet.status
      resp = dynamodb_client.update_item({
                                  expression_attribute_names: {
                                    "#S" => "status"
                                  },
                                  expression_attribute_values: {
                                    ":s" => "cancelled"
                                  },
                                  key: {
                                    "user_names_game" => unique_hash
                                  },
                                  return_values: "ALL_NEW",
                                  table_name: "bets",
                                  update_expression: "SET #S = :s",
                                })
    elsif ((@status == 'proposed') && (current_user.name == @bet.user_one_name))
      current_user.increase_balance_in_escrow(-@amount)
    elsif ((@status == 'proposed') && (current_user.name == @bet.user_two_name))
      @friend.increase_balance_in_escrow(-@amount)
    end
    @bet.status = 'cancelled'
    @bet.save
    sender = 'andybirla96@gmail.com'
    recipient = @friend.email
    recipient_phone_number = @friend.phone_number
    allowed_emails = ['ab5188@columbia.edu', 'andybirla96@gmail.com', 'andy.birla21@gmail.com', 'andymbirla@gmail.com']
    allowed_numbers = ['3108479740']
    if (not(allowed_emails.include? recipient))
      recipient = 'andybirla96@gmail.com'
    end
    if (not(allowed_numbers.include? recipient_phone_number))
      recipient_phone_number = '+13108479740'
    else 
      recipient_phone_number = "+1" + recipient_phone_number
    end

    subject = '[Betwork] Your bet with ' + current_user.name + ' was cancelled.'
    textbody = 'Hi ' + @friend.name + '!' + "\n" + "\n"
    textbody += current_user.name + ' cancelled a bet between you and them! '
    if (@bet.betting_on == 'Home Team')
      team_1 = @bet.home_team_name
      team_2 = @bet.away_team_name
    else
      team_2 = @bet.home_team_name
      team_1 = @bet.away_team_name
    end
    if (current_user.name == @bet.user_one_name)
      opposition_team = team_2
    else
      opposition_team = team_1
    end
    textbody += 'Your bet was for USD' + @bet.amount.to_s + ' on ' + opposition_team + ' in ' + @bet.home_team_name + ' vs. ' + @bet.away_team_name + ' on ' + @bet.date + '.' + "\n" + "\n"
    textbody += 'Log into Betwork to view the cancelled bet.'
    encoding = 'UTF-8'
    ses = Aws::SES::Client.new(region: 'us-east-1', access_key_id: 'AKIAQNW4F2IKHDRYMOHR', secret_access_key: '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')
    twilio_client = Twilio::REST::Client.new(
      'AC301826b0bd8c63c945aeae5288b45720',
      'f3a42abcb29d4bb549cd003b2dc7d749'
    )
    # Try to send the text.
    begin 
      message = twilio_client.messages.create(
        body: textbody,
        to: recipient_phone_number,
        from: "+19295818779"
      )
      puts "Text successfully sent!"
    rescue Twilio::REST::TwilioError => error
      puts "Text not sent. Error message: #{error}"
    end

    # Try to send the email.
    begin
      # Provide the contents of the email.
      ses.send_email(
        destination: {
          to_addresses: [
            recipient
          ]
        },
        message: {
          body: {
            text: {
              charset: encoding,
              data: textbody
            }
          },
          subject: {
            charset: encoding,
            data: subject
          }
        },
        source: sender,
      # Uncomment the following line to use a configuration set.
      # configuration_set_name: configsetname,
        )

      puts 'Cancellation Email sent to ' + recipient


      # If something goes wrong, display an error message.
    rescue Aws::SES::Errors::ServiceError => error
      puts "Cancellation Email not sent. Error message: #{error}"
    end
    redirect_to allbets_bet_path(current_user), notice: "Bet Cancelled!"
  end

  def edit
  end

  def create
    # puts "created over here andy"
    @bet = Bet.new(bet_params)
    if @bet.save
      current_user.increase_balance_in_escrow(@bet.amount)
      render js: "window.location='#{confirm_bet_path(@bet)}'"
      sender = 'andybirla96@gmail.com'
      recipient_user = User.find_by(id: @bet.user_id_two)
      recipient = recipient_user.email
      recipient_phone_number = recipient_user.phone_number
      allowed_emails = ['ab5188@columbia.edu', 'andybirla96@gmail.com', 'andy.birla21@gmail.com', 'andymbirla@gmail.com']
      allowed_numbers = ['3108479740']
      if (not(allowed_emails.include? recipient))
        recipient = 'andybirla96@gmail.com'
      end
      if (not(allowed_numbers.include? recipient_phone_number))
        recipient_phone_number = '+13108479740'
      else 
        recipient_phone_number = "+1" + recipient_phone_number
      end

      subject = '[Betwork] A new bet has been proposed to you!'
      textbody = 'Hi ' + @bet.user_two_name + '!' + "\n" + "\n"
      textbody += @bet.user_one_name + ' wants to place a bet against you! '
      if (@bet.betting_on == 'Home Team')
        team_1 = @bet.home_team_name
        team_2 = @bet.away_team_name
      else
        team_2 = @bet.home_team_name
        team_1 = @bet.away_team_name
      end
      textbody += 'They want to bet USD' + @bet.amount.to_s + ' on ' + team_1 + ' in ' + @bet.home_team_name + ' vs. ' + @bet.away_team_name + ' on ' + @bet.date + '.' + "\n" + "\n"
      textbody += 'Log into Betwork to view and cancel or accept the bet.'
      encoding = 'UTF-8'
      ses = Aws::SES::Client.new(region: 'us-east-1', access_key_id: 'AKIAQNW4F2IKHDRYMOHR', secret_access_key: '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')
      twilio_client = Twilio::REST::Client.new(
      'AC301826b0bd8c63c945aeae5288b45720',
      'f3a42abcb29d4bb549cd003b2dc7d749'
      )
      # Try to send the text.
      begin 
      message = twilio_client.messages.create(
        body: textbody,
        to: recipient_phone_number,
        from: "+19295818779"
        )
        puts "Text successfully sent!"
      rescue Twilio::REST::TwilioError => error
        puts "Text not sent. Error message: #{error}"
      end
      # Try to send the email.
      begin
        # Provide the contents of the email.
        ses.send_email(
          destination: {
            to_addresses: [
              recipient
            ]
          },
          message: {
            body: {
              text: {
                charset: encoding,
                data: textbody
              }
            },
            subject: {
              charset: encoding,
              data: subject
            }
          },
          source: sender,
        # Uncomment the following line to use a configuration set.
        # configuration_set_name: configsetname,
          )

        puts 'Proposition Email sent to ' + recipient


        # If something goes wrong, display an error message.
      rescue Aws::SES::Errors::ServiceError => error
        puts "Proposition Email not sent. Error message: #{error}"
      end
    else
      respond_to do |format|
        format.js
        @bet.errors.any?
        @bet.errors.each do |key, value|
        end
      end
    end
  end

  def update
    #puts "update"
    @bet.update(user_params)
  end

  # def index
  #     @odds = Odd.all
  # end
  #
  # def friends
  #     #puts params[:page]
  #     @friends = @user.following_users.paginate(page: params[:page])
  #     @game = Odd.find params[:id]
  # end
  #
  # def show
  #     @odds = Odd.all
  # end

  private

  def user_params
    #puts "user_params"
    #puts user_params
    params.require(:user).permit(:name, :about, :avatar, :cover,
                                 :sex, :dob, :location, :phone_number)
  end

  def bet_params
    #puts "bet_params"
    params.require(:bet).permit(:home_team_name, :away_team_name, :home_money_line, :date,
                                :away_money_line, :user_one_name, :betting_on, :user_two_name, :amount, :user_id_one, :user_id_two, :status)
  end

  def check_ownership
    #puts "check_ownership"
    redirect_to current_user, notice: 'Not Authorized' unless @user == current_user
  end

  def set_user
    #puts "set_user"
    @user = current_user
    render_404 and return unless @user
  end
end