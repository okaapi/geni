json.array!(@sources) do |source|
  json.extract! source, :id, :title, :content, :filename, :sid, :tree, :gedfile, :gedraw
  json.url source_url(source, format: :json)
end
