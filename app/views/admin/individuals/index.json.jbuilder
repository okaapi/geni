json.array!(@individuals) do |individual|
  json.extract! individual, :id, :name, :surname, :given, :nickname, :prefix, :suffix, :sex, :birth_id, :death_id, :uid, :parents_uid, :changed_ged, :pedigree, :tree, :gedfile, :note, :gedraw
  json.url individual_url(individual, format: :json)
end
