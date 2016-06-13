
require "../config/environment" unless defined?(::Rails.root)

gedfile = 'sources.ged' # 'test.ged' # 

puts "importing from #{gedfile}..."

ignored = Import.from_gedfile( 'sources', gedfile, gedfile, true )

puts
puts ignored





