class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  has_merit
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable
  acts_as_voter
  acts_as_follower
  acts_as_followable

  has_many :posts
  has_many :comments
  has_many :events

  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover, AvatarUploader

  validates_presence_of :name

  self.per_page = 10

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  def self.get_admin_user()
    return User.where(email: "admin@betwork.com").first
  end 

  def decrease_balance(amount)
    self.actualBalance -= amount
    self.save
  end

  def increase_balance_in_escrow(amount)
    self.balanceInEscrow += amount
    self.save
  end


end
