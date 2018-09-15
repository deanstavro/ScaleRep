json.extract! data_upload, :id, :created_at, :updated_at
json.url data_upload_url(data_upload, format: :json)
