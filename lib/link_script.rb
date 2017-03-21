
require "../config/environment" unless defined?(::Rails.root)


sql = "select tree from individuals group by tree"
res = ActiveRecord::Base.connection.execute(sql)
trees = []
res.each do |n|
  if n[0]
    trees << n[0]
  end
end    

p trees

if trees.size != 2
  puts "script designed for two trees"
  exit
end

sql = "select name from individuals where tree = '#{trees[1]}' group by name;"
names = []; ActiveRecord::Base.connection.execute(sql).each {|n| names << n[0] if n[0]}

mm = dd = nn = 0
specname = 'Johann Jakob /Lenz/'
names.each do |name|
  
    sql = "select uid from individuals where tree = '#{trees[0]}' and name LIKE '%#{name}%' group by uid, name;"
    individuals = []; ActiveRecord::Base.connection.execute(sql).each {|n| individuals << n[0] if n[0]}   
    
    individuals.each do |uid|    
      individual = Individual.by_uid( uid )
      
      num_matches = 0
      if name == specname
        puts "---------#{specname}--------------------------------------------------"
        p individuals
      end       
      
      sql = "select uid from individuals where tree = '#{trees[1]}' and name LIKE '%#{name}%' group by uid, name;"
      matches = []; ActiveRecord::Base.connection.execute(sql).each {|n| matches << n[0] if n[0]}      

      if name == specname
        p matches
      end
      
      matches.each do |muid|
        match = Individual.by_uid( muid )
        
        if name == specname
          puts "#{individual.tree} -#{individual.birth.date if individual.birth}- -#{individual.death.date if individual.death}-" 
          puts "#{match.tree} -#{match.birth.date if match.birth}- -#{match.death.date if match.death}-" 
        end        
        if ( individual.birth and match.birth and
             individual.death and match.death and
             individual.birth.date == match.birth.date and
             individual.death.date == match.death.date )
          print "m"
          mm += 1
          num_matches += 1
          individual.linkuid = match.uid
          match.linkuid = individual.uid
          match.save
        elsif ( individual.birth and match.birth and
             !individual.death and !match.death and
             individual.birth.date == match.birth.date )
          print "d"
          dd += 1
          num_matches += 1          
          individual.linkuid = match.uid
          match.linkuid = individual.uid
          match.save      
        elsif ( !individual.birth and !match.birth and
             !individual.death and !match.death and
             individuals.count == 1 and
             matches.count == 1 )
          print "n"
          nn += 1
          num_matches += 1          
          individual.linkuid = match.uid
          match.linkuid = individual.uid
          match.save             
        end
                  
      end
      if num_matches > 1
        puts
        puts "Multiple matches for #{individual.name}"
      end
      individual.save
      
    end
    print "."
    
end
puts
puts mm, dd, nn

