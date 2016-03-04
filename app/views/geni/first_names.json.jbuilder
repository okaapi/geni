json.surname @surname
json.names do
  json.array! @names do |name|
    json.uid name[:uid]
    json.given name[:fullname]
  end
end


