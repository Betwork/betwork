class Odd< ActiveRecord::Base
    include Shared::Callbacks
  
    acts_as_commentable
  
  
end
  