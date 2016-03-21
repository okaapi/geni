#json.surname @surname
#json.names do
  json.array! @names do |name|
    json.uid name[:uid]
    json.fullname name[:fullname]
    json.birth name[:birth]
  end
#end


