class Group < ActiveRecord::Base
  # groupify :group
  has_many :group_memberships
  has_many :users, :through => :group_memberships
end

