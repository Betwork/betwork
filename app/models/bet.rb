class Bet< ActiveRecord::Base
    include Shared::Callbacks
  
    acts_as_commentable

    def self.get_by_userid(user_id)
        return Bet.where(user_id_one:user_id).or(Bet.where(user_id_two:user_id))
    end
  
  
end
  