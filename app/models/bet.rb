class Bet< ActiveRecord::Base
    include Shared::Callbacks
  
    acts_as_commentable

    def self.get_by_userid(user_id)
        return Bet.where(user_id_one:user_id).or(Bet.where(user_id_two:user_id))
    end

    def sufficient_funds
        if amount == nil 
            return
        end
        current_user = User.where(id: user_id_one).first
        if (current_user.actualBalance - current_user.balanceInEscrow) - amount < 0.0
            errors.add(:amount, "Insufficient Funds")
        end
    end 
    
    #validates_presence_of :amount, message: "Amount cannot be empty"
    validates :amount, numericality: {only_integer: true, greater_than: 0,  message: "Amount must be a valid number greater than zero!"}
    validate :sufficient_funds
  
  
end
  