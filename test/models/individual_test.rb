require 'test_helper'

class IndividualTest < ActiveSupport::TestCase

  setup do
   
  	assert !Individual.all.empty?
    Individual.destroy_all
    assert Individual.all.empty?
  	assert !Event.all.empty?
    Event.destroy_all
    assert Event.all.empty?	
	
  end
  
  test "new" do
   
    wido = Individual.new( name: 'Wido')
    assert_not_nil wido.uid
    uid = wido.uid
    assert_equal wido.name, 'Wido'
    wido.save
    
    wido2 = Individual.by_uid( uid )
    assert_not_nil wido2
    assert_equal 'Wido', wido2.name
    
  end
  
  test "new no params" do
    
    wido = Individual.new  
    wido = Individual.create

  end
  
  test "create" do
    
    wido = Individual.create( name: 'Wido')
    assert_not_nil wido.uid
    uid = wido.uid
    wido.save
    
    wido2 = Individual.by_uid( uid )
    assert_not_nil wido2
    assert_equal wido2.name, 'Wido'
      
  end  
  
  test "update" do
	
    wido = Individual.create( name: 'Wido')
    assert_not_nil wido.uid
    uid = wido.uid
    wido.save
    assert_equal Individual.all.count, 1
    
    wido2 = Individual.by_uid( uid )   
    assert_not_nil wido2
    assert_equal wido2.name, 'Wido'
    assert_nil wido2.nickname
    wido2.nickname = 'Weed'
    wido2.save
    assert_equal Individual.all.count, 2
    
    wido3 = Individual.by_uid( uid )
    assert_not_nil wido3
    assert_equal wido3.name, 'Wido'
    assert_equal wido3.nickname, 'Weed'  
    wido3.save
    assert_equal Individual.all.count, 3   
          
  end    
  
  test "add birth" do
  
    assert Individual.all.count, 0
    wido = Individual.create( name: 'Wido' )
    wido.birth = Event.new( rawdate: 'October 2nd 1859' )
    uid = wido.uid    
    wido.save
    
    wido2 = Individual.by_uid( uid )
    assert_equal wido2.birth.date, '2 Oct 1859'
    
    assert_equal wido2.living?, false
  end
  
  test "add and change death" do
	
    assert Individual.all.count, 0
    paul = Individual.create( name: 'Paul' )
    paul.update_death( rawdate: 'October 2nd 1859' )
    uid = paul.uid    
    paul.save
    assert_equal Event.all.count, 1
    
    paul2 = Individual.by_uid( uid )   
    assert_equal paul2.death.date, '2 Oct 1859'    
    
    paul2.update_death( location: 'Kalamazoo', text: 'unfortunately' )
    paul2.save
    assert_equal Event.all.count, 2
    
    paul3 = Individual.by_uid( uid )
    assert_equal paul3.death.date, '2 Oct 1859'    
    assert_equal paul3.death.location, 'Kalamazoo'    
    assert_equal paul3.death.text, 'unfortunately' 
    assert_equal Event.all.count, 2
    
  end  
  
  test "compare names" do
    paul = Individual.create( given: 'Paul', surname: 'Smith' )
    peter = Individual.create( given: 'Peter', surname: 'Smith' )
    smith = Individual.create( surname: 'Smith' )
    assert_equal Individual.compare_names( paul, peter, true ), -1
    assert_equal Individual.compare_names( paul, peter, false ), -1    
    assert_equal Individual.compare_names( peter, paul, true ), 1
    assert_equal Individual.compare_names( paul, smith, true ), -1
    assert_equal Individual.compare_names( paul, smith, false ), -1    
    assert_equal Individual.compare_names( smith, paul, true ), 1
    assert_equal Individual.compare_names( smith, smith, true ), 0
       
    paul = Individual.create( given: 'Paul' )
    peter = Individual.create( given: 'Peter' )
    smith = Individual.create( surname: 'Smith' )
    miller = Individual.create( surname: 'Miller' )   
    assert_equal Individual.compare_names( smith, miller, true ), 1 
    assert_equal Individual.compare_names( smith, miller, false ), -1    
    assert_equal Individual.compare_names( miller, smith, false ), 1   
    assert_equal Individual.compare_names( paul, peter, true ), -1
    assert_equal Individual.compare_names( paul, peter, false ), -1    
    assert_equal Individual.compare_names( peter, paul, true ), 1    
    assert_equal Individual.compare_names( peter, smith, true ), 1             
    assert_equal Individual.compare_names( miller, paul, true ), -1   
        
  end
    
end









