class Event < ActiveRecord::Base
  include Shared::Callbacks
  belongs_to :user
  acts_as_votable
  acts_as_commentable

  include PublicActivity::Model
  tracked only: [:create, :like], owner: Proc.new{ |controller, model| model.user }

  validates_presence_of :name
  validates_presence_of :event_datetime
  validates_presence_of :user
end
