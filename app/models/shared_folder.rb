class SharedFolder < ActiveRecord::Base
  belongs_to :user
  belongs_to :folder

  attr_accessible :user_id, :folder_id

  validates_presence_of :user_id, :folder_id
end