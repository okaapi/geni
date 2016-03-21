json.array!(@unions) do |union|
  json.extract! union, :id, :uid, :husband_uid, :wife_uid, :marriage_id, :divorce_id, :tree, :note
  json.url union_url(union, format: :json)
end
