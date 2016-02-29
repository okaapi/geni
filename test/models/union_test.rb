require 'test_helper'

class UnionTest < ActiveSupport::TestCase

  setup do
    assert_equal Individual.all.count, 0  
    assert_equal Union.all.count, 0  
    assert_equal Event.all.count, 0    
  end
  
  
  test "new" do
    
    fam = Union.new
    assert_not_nil fam.uid
    uid = fam.uid
    fam.save
    assert_equal Union.all.count, 1

    fam2 = Union.by_uid( uid )
    assert_not_nil fam2
    assert_not_equal fam.id, fam2.id
    fam2.save
    assert_equal Union.all.count, 2
    
  end
  
  test "create" do
    
    fam = Union.create
    assert_not_nil fam.uid
    uid = fam.uid
    fam.save
    assert_equal Union.all.count, 1

    fam2 = Union.by_uid( uid )
    assert_not_nil fam2
    assert_not_equal fam.id, fam2.id
    fam2.save
    assert_equal Union.all.count, 2
    
  end  

  test "add husband" do
  
    wido = Individual.create( name: 'Wido')
    wido.save

    fam = Union.create
    fam.husband = wido  
    assert_equal fam.husband.name, 'Wido' 
    fuid = fam.uid  
    assert_equal Individual.all.count, 1
    fam.save 
    assert_equal Union.all.count, 1
    assert_equal Individual.all.count, 1
    
    fam2 = Union.by_uid( fuid )    
    assert_equal fam2.husband.name, 'Wido' 
    
  end
  
  test "add and change wife" do
  
    trixi = Individual.create( name: 'Trixi')
    trixi.save

    fam = Union.create
    fam.wife = trixi  
    assert_equal fam.wife.name, 'Trixi' 
    fuid = fam.uid  
    fam.save 
    assert_equal Union.all.count, 1
    assert_equal Individual.all.count, 1
    
    fam2 = Union.by_uid( fuid )    
    assert_equal fam2.wife.name, 'Trixi' 
    
    trixi2 = Individual.create( name: 'Trixi2')
    trixi2.save   
    
    fam2.wife = trixi2
    fam2.save
    assert_equal fam2.wife.name, 'Trixi2'
    assert_equal Union.all.count, 2
    
    fam3 = Union.by_uid( fuid )
    assert_equal fam3.wife.name, 'Trixi2'
    fam3.save
    assert_equal Union.all.count, 3
     
  end  
  
  test "add to two families as husband" do
  
    wido = Individual.create( name: 'Wido')
    wido.save
    jane = Individual.create( name: 'Jane')
    jane.save
    june = Individual.create( name: 'June')
    june.save        

    fam1 = Union.create
    fam1.husband = wido  
    fam1.wife = jane  
    f1 = fam1.uid
    fam1.save 
    
    fam2 = Union.create
    fam2.husband = wido  
    fam2.wife = june  
    f2 = fam2.uid
    fam2.save 
    
    fam3 = Union.by_uid( f2 ) 
    fam3.save
    
    assert_equal Individual.all.count, 3
    assert_equal Union.all.count, 3

    assert_equal wido.unions.count, 2
    assert1 = ( wido.unions[0].wife.name == 'June' and wido.unions[1].wife.name == 'Jane' )
    assert2 = ( wido.unions[0].wife.name == 'Jane' and wido.unions[1].wife.name == 'June' )
    assert ( assert1 or assert2 )
  end
  
  test "add children" do
  
    wido = Individual.create( name: 'Wido')
    wido.save
    trixi = Individual.create( name: 'Trixi')
    trixi.save    
    camilla = Individual.create( name: 'Camilla')
    camilla.save
    mats = Individual.create( name: 'Mats')
    mats.save   
    assert_equal Individual.all.count, 4

    fam = Union.create
    fam.husband = wido
    fam.wife = trixi    
    fam.save
    
    camilla.parents = fam
    cuid = camilla.uid
    camilla.save
    mats.parents = fam
    mats.save    
    
    c = Individual.by_uid( cuid )
    assert_equal c.parents.husband.name, 'Wido'
    assert_equal c.parents.wife.name, 'Trixi'   
    assert_equal c.father.name, 'Wido'
    assert_equal c.mother.name, 'Trixi'  
       
    assert_equal fam.children[0].name, 'Camilla'
    assert_equal fam.children[1].name, 'Mats'
    
    mats.update_birth( rawdate: 'April 28 1996' )
    mats.save
    fam.children # execute the sort function with missing birthday
    
    camilla.update_birth( rawdate: 'November 2 2001')
    camilla.save
    assert_equal fam.children[0].name, 'Mats'
    assert_equal fam.children[1].name, 'Camilla'    
    
  end  
    
  test "add marriage" do
  
    fam = Union.create
    fam.marriage = Event.new( rawdate: 'October 19 1990' )
    fuid = fam.uid
    fam.save
    
    fam2 = Union.by_uid( fuid )
    assert_equal fam2.marriage.date, '19 Oct 1990'
    
  end
  
  test "add and change divorce" do
  
    fam = Union.create
    fam.divorce = Event.new( rawdate: '1880' )
    fuid = fam.uid
    fam.save
    assert_equal Event.all.count, 1 
    
    fam2 = Union.by_uid( fuid )   
    assert_equal fam2.divorce.date, '1880'    
    
    fam2.update_divorce( location: 'Kalamazoo', text: 'unfortunately' )
    fam2.save
    assert_equal Event.all.count, 2
    
    fam3 = Union.by_uid( fuid )
    assert_equal fam3.divorce.date, '1880'    
    assert_equal fam3.divorce.location, 'Kalamazoo'    
    assert_equal fam3.divorce.text, 'unfortunately' 
    assert_equal Event.all.count, 2
    
  end  
  
  test "add husband and wife" do
  
    fam = Union.create
    fuid = fam.uid
    fam.save 
          
    wido = Individual.create( name: 'Wido')
    wido.save
    
    trixi = Individual.create( name: 'Trixi')
    trixi.save
        
    fam2 = Union.by_uid( fuid ) 
    fam2.husband = wido
    fam2.save
    
    fam3 = Union.by_uid( fuid ) 
    fam3.wife = trixi
    fam3.save    
        
    fam4 = Union.by_uid( fuid ) 
    assert_equal fam4.wife.name, 'Trixi' 
    assert_equal fam4.husband.name, 'Wido'     
    
  end

end
