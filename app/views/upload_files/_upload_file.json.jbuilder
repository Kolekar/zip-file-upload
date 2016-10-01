json.extract! upload_file, :id, :zip_file_a, :created_at, :updated_at
json.url upload_file_url(upload_file, format: :json)
