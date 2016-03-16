
require "../config/environment" unless defined?(::Rails.root)

puts "...."

puts
t1 = Time.now
indis = Individual.names_for_surname_old('Menhardt', true )
t2 = Time.now
puts "names_for_surname(Menhardt)"
puts "#{indis.count} results in #{(t2-t1).round(2)} time"
indis.each {|i| puts "#{i[:uid][i[:uid].length-5..i[:uid].length-1]}...#{i[:ver]}....#{i[:fullname]} " }; puts

t1 = Time.now
sql = 'select id, right(uid,5), ver from individuals where (uid, ver) in (select uid, max(ver) from individuals where surname = "Menhardt" group by uid) order by given, ver ASC;'
res = ActiveRecord::Base.connection.execute(sql)
array_of_ids = []
res.each {|r| array_of_ids << r[0]}
indis = Individual.find( array_of_ids )
indis.sort! {|a,b| a.given <=> b.given }
t2 = Time.now
puts sql
puts "#{indis.count} results in #{(t2-t1).round(2)} time"
indis.each {|i| puts "#{i.uid[i.uid.length-5..i.uid.length-1]}...#{i.ver}....#{i[:name]}"}

puts
t1 = Time.now
indis = Individual.names_for_surname('Menhardt', true )
t2 = Time.now
puts "names_for_surname(Menhardt)"
puts "#{indis.count} results in #{(t2-t1).round(2)} time"
indis.each {|i| puts "#{i[:uid][i[:uid].length-5..i[:uid].length-1]}...#{i[:ver]}..#{i[:fullname]} " }; puts


puts
t1 = Time.now
indis = Individual.names_for_term_old('Eve Wipp', true )
t2 = Time.now
puts "names for term OLD ('Eve Wipp')"
puts "#{indis.count} results in #{(t2-t1).round(2)} time"
indis.each {|i| puts "#{i[:uid][i[:uid].length-5..i[:uid].length-1]}...#{i[:ver]}..#{i[:fullname]} " }; puts

puts
t1 = Time.now
indis = Individual.names_for_term('Eve Wipp', true )
t2 = Time.now
puts "names for term NEW ('Eve Wipp')"
puts "#{indis.count} results in #{(t2-t1).round(2)} time"
indis.each {|i| puts "#{i[:uid][i[:uid].length-5..i[:uid].length-1]}...#{i[:ver]}..#{i[:fullname]}" }; puts


puts
t1 = Time.now
messing = Individual.by_uid( 'f56972cb-ac88-4195-926e-28862456d84c' )
unions = messing.unions_old
t2 = Time.now
puts "unions for Theodore Messing"
puts "#{unions.count} results in #{(t2-t1).round(2)} time"
unions.each {|i| puts "#{i.uid[i.uid.length-5..i.uid.length-1]}...#{i.ver}...#{i.marriage.date if i.marriage}" }; puts

puts
t1 = Time.now
messing = Individual.by_uid( 'f56972cb-ac88-4195-926e-28862456d84c' )
unions = messing.unions
t2 = Time.now
puts "unions for Theodore Messing"
puts "#{unions.count} results in #{(t2-t1).round(2)} time"
unions.each {|i| puts "#{i.uid[i.uid.length-5..i.uid.length-1]}...#{i.ver}...#{i.marriage.date if i.marriage}" }; puts

puts
individuals = Individual.all_by_uid
t1 = Time.now
individuals.each do |indi|
  indi.unions_old
end
t2 = Time.now
puts "pulled all unions for all individuals (old) in #{(t2-t1).round(2)} time"
unions.each {|i| puts "#{i.uid[i.uid.length-5..i.uid.length-1]}...#{i.ver}...#{i.marriage.date if i.marriage}" }; puts

puts
individuals = Individual.all_by_uid
t1 = Time.now
individuals.each do |indi|
  indi.unions
end
t2 = Time.now
puts "pulled all unions for all individuals in #{(t2-t1).round(2)} time"
unions.each {|i| puts "#{i.uid[i.uid.length-5..i.uid.length-1]}...#{i.ver}...#{i.marriage.date if i.marriage}" }; puts

puts

t1 = Time.now
old_individuals = Individual.all_by_uid_old
t2 = Time.now
puts "all_by_uid_old #{(t2-t1).round(2)} time"

t1 = Time.now
new_individuals = Individual.all_by_uid
t2 = Time.now
puts "all_by_uid_new #{(t2-t1).round(2)} time"

old_individuals.sort! {|a,b| a.uid <=> b.uid }
new_individuals.sort! {|a,b| a.uid <=> b.uid }

old_individuals.each_with_index do |indi,index|
  if old_individuals[index].uid != new_individuals[index].uid
    puts "probelm!"
    exit
  end
end
