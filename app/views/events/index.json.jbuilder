json.array!(@events) do |event|
  json.extract! event, :id, :date, :year, :month, :day, :location, :text
  json.url event_url(event, format: :json)
end
