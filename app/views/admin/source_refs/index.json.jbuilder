json.array!(@source_refs) do |source_ref|
  json.extract! source_ref, :id, :individual_uid, :union_uid, :source_uid
  json.url source_ref_url(source_ref, format: :json)
end
