json.array!(@bucket_items) do |bucket_item|
  json.extract! bucket_item, :id, :name, :description, :status
  json.url bucket_item_url(bucket_item, format: :json)
end
