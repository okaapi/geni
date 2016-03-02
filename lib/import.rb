
require "../config/environment" unless defined?(::Rails.root)

gedfile = 'stammbaum.ged' # test.ged' # 

ignored = Import.from_gedfile( 'wido', gedfile, gedfile, true )

puts
puts ignored





