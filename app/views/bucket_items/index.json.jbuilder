json.array!(@bucket_items) do |bucket_item|
  json.extract! bucket_item, :id, :name, :bucket_item_type, :bucket, :description, :status
  json.url bucket_item_url(bucket_item, format: :json)
end
