
require "../config/environment" unless defined?(::Rails.root)


p ENV

=begin
puts "aaa"
ZiteActiveRecord.site( 'aaa' )
UserSession.destroy_all

u_aaa = UserSession.new
u_aaa.save
id_aaa = u_aaa.id
u_aaa = nil

UserSession.all.each {|u| puts " #{u.id} #{u.site}"}

puts "bbb"
ZiteActiveRecord.site( 'bbb' )
UserSession.destroy_all

u_bbb = UserSession.new
u_bbb.save
id_bbb = u_bbb.id
u_bbb = nil

UserSession.all.each {|u| puts " #{u.id} #{u.site}"}

puts "---"
p UserSession.where( id: id_aaa )
puts "---"
p UserSession.where( id: id_bbb )
puts "---"
=end
