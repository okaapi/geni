
require "../config/environment" unless defined?(::Rails.root)

  
def label_recursively( uid )

  individual = Individual.by_uid( uid )
  
  q = []
       
  if ( father = individual.father )
    if father.label == "0"
      father.label = individual.label
      father.save
      q << father
    end
  end
  
    
  if ( mother = individual.mother )
    if mother.label == "0"
      mother.label = individual.label
      mother.save
      q << mother
    end
  end     
      
  individual.unions.each do |union|
  
    if ( spouse = union.spouse( individual.uid ) )
      if spouse.label == "0"      
        spouse.label = individual.label       
        spouse.save
        q << spouse
      end    
    end
  
    union.children.each do |child|
    
      if child.label == "0"      
        child.label = individual.label     
        child.save       
        q << child
      end
      
    end if union.children
    
  end if individual.unions    
       
  q.each do |i|
    label_recursively( i.uid )
  end 
  
  print "."
  
end


sql = "update individuals set label = 0"
ActiveRecord::Base.connection.execute(sql)

label = 0

(0..10).each {|i| puts "."}  
  
begin
  

  puts "Trees #{Individual.trees}"
  puts "Labels #{Individual.labels}"
  
  allofthem = Individual.all_by_uid

  allofthem.each do |individual|
    if individual.label == "0"
      
      label += 1
      puts "Label #{label} seeded by #{individual.name} in #{individual.tree} "  
      individual.label = label
      individual.save
  
      label_recursively( individual.uid )      
      
      break
    end
  end

  labels = Individual.labels
  
end until ( labels["0"] == "0" or !labels["0"] ) 
