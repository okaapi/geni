
require "../config/environment" unless defined?(::Rails.root)


##############################################################################
#
#gedfile = 'alberto.ged'  
#
#filename = '../../Desktop/' + gedfile  
#
#puts "importing from #{gedfile}..."
#
#ignored = Import.from_gedfile( gedfile, filename, gedfile, true )
#
##############################################################################

gedfile = 'stammbaum.ged'  

#filename = '../../Desktop/' + gedfile  
filename = gedfile  

puts "importing from #{gedfile}..."

ignored = Import.from_gedfile( gedfile, filename, gedfile, true )

##############################################################################
  
puts
puts ignored

puts Individual.trees



