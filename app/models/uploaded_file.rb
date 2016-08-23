class UploadedFile < ActiveRecord::Base
  has_attached_file :file

  belongs_to :folder
end