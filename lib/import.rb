
require "../config/environment" unless defined?(::Rails.root)

gedfile = 'stammbaum.ged' # 'test.ged' # 

ignored = Import.from_gedfile( 'wido', 'stammbaum.ged' )

puts
puts ignored





