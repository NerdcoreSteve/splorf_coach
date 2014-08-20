json.array!(@buckets) do |bucket|
  json.extract! bucket, :id, :name
  json.url bucket_url(bucket, format: :json)
end
