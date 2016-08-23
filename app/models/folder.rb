class Folder < ActiveRecord::Base
  acts_as_tree

  belongs_to :user

  has_many :files, class_name: "UploadedFile", foreign_key: "folder_id", :dependent => :destroy

  has_many :shared_folders, :dependent => :destroy
end