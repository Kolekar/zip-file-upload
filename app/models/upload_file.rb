class UploadFile < ActiveRecord::Base
  has_attached_file :zip_file_a
  validates_attachment_content_type :zip_file_a, content_type: ["application/zip"]
end
