require 'test_helper'
require 'pp'

class GeniControllerTest < ActionController::TestCase

  setup do
	# this is required so 'testsite45A67' fixtures get loaded
	ZiteActiveRecord.site( 'testsite45A67' )
	@user = users(:wido)
	admin_login_4_test
	request.host = 'testhost45A67'	

  	assert !Individual.all.empty?
    Individual.destroy_all
    assert Individual.all.empty?
  	assert !Union.all.empty?
    Union.destroy_all
    assert Union.all.empty?		
    	
    #
	# some simple fixtures
	#
	john = Individual.new( given: 'John', name: 'John /Smith/', 
	                surname: 'Smith', sex: 'm' )
	john.save
	                
	erin = Individual.new( given: 'Erin', name: 'Erin /Smith/', 
	                surname: 'Smith', sex: 'f' )
    erin.update_birth( rawdate: '4 oct 1858' )	
    erin.save
    	               				
	Individual.new( given: 'Mary', name: 'Mary /Jones/', 
	                surname: 'Jones', sex: 'f' ).save
	
	jill = Individual.new( given: 'Jill', name: 'Jill /Jefferson/', 
	                surname: 'Jefferson', sex: 'f' )
    Union.new( wife_uid: jill.uid ).save
    parents = Union.new
	jill.parents_uid = parents.uid
	jill.save	
	
	peter = Individual.new( given: 'Peter', name: 'Peter Pan', sex: 'm' )
	peter.save	
	parents.husband_uid = peter.uid
	parents.save
	
  end
  
  test "should get tree" do
	get :tree, uid: Individual.find_by_given( "John" ).uid
	assert_response :success
	individual = assigns(:individual)
	assert_select '.currentindividualcontainer  a', 'John Smith'
  end  
  
  test "should get tree w/o individual" do
	get :tree, uid: 7
	assert_redirected_to root_path 
  end  

  test "surnames" do
	get :surnames
	assert_response :success
	surnames = assigns(:surnames)
	assert_equal surnames[0], 'Jefferson'
	assert_equal surnames[1], 'Jones'
	assert_equal surnames[2], 'Smith'
  end
  
  test "names for surnames" do
    get :names_for_surname, surname: 'Smith'
    names = assigns(:names)
	assert_equal names[0][:given], 'Erin'
	assert_equal names[1][:given], 'John'
  end
  
  test "names for term" do
    get :names_for_term, :format => :json, term: 'ith'
    body = JSON.parse(response.body)
    assert_equal body.count, 2
    assert_equal body[0]["fullname"], 'Erin Smith'
    assert_equal body[0]["birth"], '4 Oct 1858'    
    assert_equal body[1]["fullname"], 'John Smith'
  end  

  test "depth_change with individual" do
    get :tree, uid: Individual.find_by_given( "John" ).uid
    get :depth_change, change: 2, uid: Individual.find_by_given( "John" ).uid
	assert_equal @controller.session[:'min-tree-font'], 15
    get :depth_change, change: 2	
	assert_equal @controller.session[:'min-tree-font'], 15
    get :depth_change, change: -6
	assert_equal @controller.session[:'min-tree-font'], 11
  end
  
  test "depth_change w/o individual" do
    get :depth_change, change: 2
	assert_equal @controller.session[:'min-tree-font'], 15
    get :depth_change, change: 2	
	assert_equal @controller.session[:'min-tree-font'], 15
    get :depth_change, change: -6
	assert_equal @controller.session[:'min-tree-font'], 11
  end
  
  #
  #  edit person 
  # 
  test "edit person" do  
    @individual = Individual.find_by_given( "John" )
    xhr :post, :edit, uid: @individual.uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Death Date'  
      assert_select 'label', 'Location'  	  	  
    end  	
  end
     
  test "edit - save" do
    @individual = Individual.find_by_given( "John" )
	post :save, uid: @individual.uid, 
	     given: 'Holly', surname: 'Hunter', sex: 'F',
		 nickname: 'Hol', suffix: 's', prefix: 'Mag', pedigree: 'p',
		 Birthdate: '16 Nov 1972', Birthlocation: 'Paris',
		 Deathdate: '17 Mar 1987', Deathlocation: 'Rome',
		 note: 'some note'
    assert_redirected_to root_path + @individual.uid.to_s	

    individual = assigns(:individual)
	assert_equal individual.given, 'Holly'
	assert_equal individual.surname, 'Hunter'
	assert_equal individual.sex, 'F'
	assert_equal individual.nickname, 'Hol'
	assert_equal individual.suffix, 's'
	assert_equal individual.prefix, 'Mag'
	assert_equal individual.pedigree, 'p'
	assert_equal individual.birth.date, '16 Nov 1972'
	assert_equal individual.birth.location, 'Paris'
	assert_equal individual.death.date, '17 Mar 1987'
	assert_equal individual.death.location, 'Rome'
	assert_equal individual.note, 'some note'		
  end
  
  test "new person" do  
    get :new_person
    assert_response :success
    assert_select 'form' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Death Date'  
      assert_select 'label', 'Location'  	  	  
    end  	
  end  
  
  #
  #  edit union 
  # 
  test "edit union" do  
    jill = Individual.find_by_given( "Jill" )
    xhr :post, :union_edit, uid: jill.uid, uuid: jill.parents_uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Divorce Date'  
      assert_select 'label', 'Location'  
      assert_select 'label', 'Notes'  	      	  	  
    end  	
  end
  
  test "edit union - save" do
    jill = Individual.find_by_given( "Jill" )
	post :union_save, uid: jill.uid, uuid: jill.parents_uid,
		 Marriagedate: '16 Nov 1972', Marriagelocation: 'Paris',
		 Divorcedate: '17 Mar 1987', Divorcelocation: 'Rome',
		 note: 'some note'
    assert_redirected_to root_path + jill.uid.to_s	

    union = assigns(:union)
	assert_equal union.marriage.date, '16 Nov 1972'
	assert_equal union.marriage.location, 'Paris'
	assert_equal union.divorce.date, '17 Mar 1987'
	assert_equal union.divorce.location, 'Rome'
	assert_equal union.note, 'some note'	
  end
     
  #
  #  create marriage 
  #  
  test "new marriage with new person" do
    @individual = Individual.find_by_given( "John" )
	assert_equal @individual.unions.count, 0
    xhr :post, :marriage_new, uid: @individual.uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Marriage Date'  
      assert_select 'label', 'Location'  	  	      
    end  
  end

  test "new marriage with new person save" do
    @individual = Individual.find_by_given( "John" )
	assert_equal @individual.unions.count, 0
	post :save_marriage_new, uid: @individual.uid, 
	     given: 'Holly', surname: 'Hunter', sex: 'F',
		 nickname: 'Hol', suffix: 's', prefix: 'Mag', pedigree: 'p',
		 Birthdate: '16 Nov 1972', Birthlocation: 'Paris',
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.given, 'Holly'
	assert_equal spouse.surname, 'Hunter'
	assert_equal spouse.sex, 'F'
	assert_equal spouse.nickname, 'Hol'
	assert_equal spouse.suffix, 's'
	assert_equal spouse.prefix, 'Mag'
	assert_equal spouse.pedigree, 'p'
	assert_equal spouse.birth.date, '16 Nov 1972'
	assert_equal spouse.birth.location, 'Paris'
	
    union = assigns(:union)		
	individual = assigns(:individual)	
	assert_equal union.husband_uid, individual.uid	
	assert_equal union.wife_uid, spouse.uid
	assert_equal union.marriage.date, '17 Mar 1987'
	assert_equal union.marriage.location, 'Rome'		

  end
  
  test "new marriage with new person swapped save" do
    @individual = Individual.find_by_given( "Erin" )
	assert_equal @individual.unions.count, 0
	post :save_marriage_new, uid: @individual.uid, 
	     given: 'Holunder', surname: 'Hunter', sex: 'M',
		 nickname: 'Hol', suffix: 's', prefix: 'Mag', pedigree: 'p',
		 Birthdate: '16 Nov 1972', Birthlocation: 'Paris',
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.given, 'Holunder'
	assert_equal spouse.surname, 'Hunter'
	assert_equal spouse.sex, 'M'
	assert_equal spouse.nickname, 'Hol'
	assert_equal spouse.suffix, 's'
	assert_equal spouse.prefix, 'Mag'
	assert_equal spouse.pedigree, 'p'
	assert_equal spouse.birth.date, '16 Nov 1972'
	assert_equal spouse.birth.location, 'Paris'
	
    union = assigns(:union)		
	individual = assigns(:individual)	
	assert_equal union.wife_uid, individual.uid	
	assert_equal union.husband_uid, spouse.uid
	assert_equal union.marriage.date, '17 Mar 1987'
	assert_equal union.marriage.location, 'Rome'		

  end  

  test "new marriage with existing person" do
    @individual = Individual.find_by_given( "John" )
	assert_equal @individual.unions.count, 0
    xhr :post, :marriage_existing, uid: @individual.uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select ".search" do
		assert_select "input[placeholder=?]", 'search by given or surname'  	  	  
	  end	  
    end  
  end

  test "new marriage with existing person save" do
    @individual = Individual.find_by_given( "John" )
	@spouse = Individual.find_by_given( "Mary" )
	assert_equal @individual.unions.count, 0
	post :save_marriage_existing, uid: @individual.uid, uuid: nil,
	     'names-search-uid' => @spouse.uid,
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s		

    spouse = assigns(:spouse)
	assert_equal spouse.name, 'Mary /Jones/'
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.husband_uid, individual.uid
	assert_equal @individual.uid, individual.uid
    assert_equal union.wife_uid, spouse.uid	

  end
  
  test "new marriage with existing person save swapped" do
    @individual = Individual.find_by_given( "Mary" )
	@spouse = Individual.find_by_given( "John" )
	assert_equal @individual.unions.count, 0
	post :save_marriage_existing, uid: @individual.uid, uuid: nil,
	     'names-search-uid' => @spouse.uid,
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s		

    spouse = assigns(:spouse)
	assert_equal spouse.name, 'John /Smith/'
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.wife_uid, individual.uid
	assert_equal @individual.uid, individual.uid
    assert_equal union.husband_uid, spouse.uid	

  end  

  test "delete marriage" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
    get :delete_marriage, uid: @individual.uid, uuid: @union.uid
	assert_redirected_to root_path + @individual.uid.to_s
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
	assert_nil @union
  end
   
  #
  #  add spouse to existing marriage 
  #  
  test "create new spouse for existing marriage" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
	assert_not_nil @union
    xhr :post, :new_spouse, uid: @individual.uid, uuid: @union.uid
    assert_response :success	
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Marriage Date'  
      assert_select 'label', 'Location'  	  	  
    end  
  end
  
  test "create new wife for existing marriage - save" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
	post :create_new_spouse, uid: @individual.uid, uuid: @union.uid,
	     given: 'Jack', surname: 'Jackson', sex: 'M',
		 nickname: 'Jackie', suffix: 's', prefix: 'Dr', pedigree: 'p',
		 Birthdate: '17 Mar 1967', Birthlocation: 'Madrid',
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.given, 'Jack'
	assert_equal spouse.surname, 'Jackson'
	assert_equal spouse.sex, 'M'
	assert_equal spouse.nickname, 'Jackie'
	assert_equal spouse.suffix, 's'
	assert_equal spouse.prefix, 'Dr'
	assert_equal spouse.pedigree, 'p'
	assert_equal spouse.birth.date, '17 Mar 1967'
	assert_equal spouse.birth.location, 'Madrid'
	
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.wife_uid, individual.uid
	assert_equal union.husband_uid, spouse.uid
	assert_equal union.marriage.date, '17 Mar 1987'
	assert_equal union.marriage.location, 'Rome'			

  end

  test "create new husband for existing marriage - save" do
    @individual = Individual.find_by_given( "John" )
	@union = Union.new
	@union.husband_uid = @individual.uid
	@union.save
	post :create_new_spouse, uid: @individual.uid, uuid: @union.uid,
	     given: 'Joan', surname: 'Jackson', sex: 'F',
		 nickname: 'Joanie', suffix: 's', prefix: 'Dr', pedigree: 'p',
		 Birthdate: '17 Mar 1967', Birthlocation: 'Madrid',
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.given, 'Joan'
	assert_equal spouse.surname, 'Jackson'
	assert_equal spouse.sex, 'F'
	assert_equal spouse.nickname, 'Joanie'
	assert_equal spouse.suffix, 's'
	assert_equal spouse.prefix, 'Dr'
	assert_equal spouse.pedigree, 'p'
	assert_equal spouse.birth.date, '17 Mar 1967'
	assert_equal spouse.birth.location, 'Madrid'
	
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.husband_uid, individual.uid
	assert_equal union.wife_uid, spouse.uid
	assert_equal union.marriage.date, '17 Mar 1987'
	assert_equal union.marriage.location, 'Rome'			

  end  
	
  test "add existing spouse to existing marriage" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
    xhr :post, :add_spouse, uid: @individual.uid, uuid: @union.uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select "input[placeholder=?]", 'search by given or surname'  	  	  
    end 	
  end
    
  test "add existing spouse to existing marriage - save" do
	individual = Individual.find_by_given( "Jill" )  
    marriage = individual.unions[0]
	spouse = Individual.find_by_given( "John" )
	post :save_added_spouse, uid: individual.uid, uuid: marriage.uid,
	     'names-search-uid' => spouse.uid
    assert_redirected_to root_path + individual.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.name, 'John /Smith/'
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.wife_uid, individual.uid
	assert_equal union.husband_uid, spouse.uid
	
  end
  
  test "add existing spouse to existing marriage swapped - save" do
    marc = Individual.new( name: 'Marc')
    marc.save
    marriage = Union.new
    marriage.husband = marc
    marriage.save
	spouse = Individual.find_by_given( "Jill" )
	post :save_added_spouse, uid: marc.uid, uuid: marriage.uid,
	     'names-search-uid' => spouse.uid
    assert_redirected_to root_path + marc.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.name, 'Jill /Jefferson/'
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.husband_uid, individual.uid
	assert_equal union.wife_uid, spouse.uid
	
  end  
  
  test "remove spouse" do
    jill = Individual.find_by_given( "Jill" )
    marriage = jill.unions[0]
    marc = Individual.new( name: 'Marc')
    marriage.husband = marc
    marriage.save
    assert_equal marriage.husband_uid, marc.uid
    
    get :remove_spouse, uid: jill.uid, uuid: marriage.uid
	assert_redirected_to root_path + jill.uid.to_s
    new_jill = Individual.by_uid( jill.uid )    
    new_marriage = new_jill.unions[0]
    assert_nil new_marriage.husband_uid    
  end  
 
  test "remove other spouse" do
    marc = Individual.new( name: 'Marc')
    marc.save    
    jill = Individual.find_by_given( "Jill" )
    marriage = jill.unions[0]
    marriage.husband = marc
    marriage.save
    assert_equal marriage.husband_uid, marc.uid
    
    get :remove_spouse, uid: marc.uid, uuid: marriage.uid
	assert_redirected_to root_path + marc.uid.to_s
    new_marc = Individual.by_uid( marc.uid )    
    new_marriage = new_marc.unions[0]
    assert_nil new_marriage.wife_uid    
  end  

  #
  #  create a child 
  #    
  test "should create new child" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
    xhr :post, :new_child, uid: @individual.uid, uuid: @union.uid
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Location'   	  	  
    end  
  end
  
  test "should create new child - save" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
	post :create_new_child, uid: @individual.uid, uuid: @union.uid,
	     given: 'Jack', surname: 'Jackson', sex: 'M',
		 nickname: 'Jackie', suffix: 's', prefix: 'Dr', pedigree: 'p',
		 Birthdate: '17 Mar 1967', Birthlocation: 'Madrid',
		 Marriagedate: '17 Mar 1987', Marriagelocation: 'Rome'
    assert_redirected_to root_path + @individual.uid.to_s	

    child = assigns(:child)
	assert_equal child.given, 'Jack'
	assert_equal child.surname, 'Jackson'
	assert_equal child.sex, 'M'
	assert_equal child.nickname, 'Jackie'
	assert_equal child.suffix, 's'
	assert_equal child.prefix, 'Dr'
	assert_equal child.pedigree, 'p'
	assert_equal child.birth.date, '17 Mar 1967'
	assert_equal child.birth.location, 'Madrid'	

  end
  
  test "should add new child" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
    xhr :post, :add_child, uid: @individual.uid, uuid: @union.uid
    assert_select_jquery :html, '#editcontainer' do
      assert_select ".search" do
		assert_select "input[placeholder=?]", 'search by given or surname'  	  	  
	  end	 
    end	  
  end
  
  test "should add new child - save" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
	@child = Individual.new( name: 'New Child')
	@child.save
	post :save_added_child, uid: @individual.uid, uuid: @union.uid,
	     'names-search-uid' => @child.uid
    assert_redirected_to root_path + @individual.uid.to_s	

    child = assigns(:child)
	assert_equal child.name, 'New Child'
    union = assigns(:union)		
	assert_equal child.parents.uid, union.uid

  end

  test "remove child" do
    jill = Individual.find_by_given( "Jill" )
    parents = Union.find_by_uid( jill.parents_uid )
    get :remove_child, uid: jill.uid, puid: parents.husband_uid
	assert_redirected_to root_path + parents.husband_uid.to_s
    new_jill = Individual.by_uid( jill.uid )
	assert_nil new_jill.parents_uid
  end
  
  #
  #  create parents
  #    
  test "should create new parent w/o union" do
    @individual = Individual.find_by_given( "John" )
	assert_nil @individual.parents_uid
	
    xhr :post, :new_parent, uid: @individual.uid, sex: 'm'
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Marriage Date'  	  
      assert_select 'label', 'Location'   	  	  
    end  
  end

  test "should create new parent w/o union - save" do
    @individual = Individual.find_by_given( "John" )
    assert_nil @individual.parents_uid
	post :create_new_parent, uid: @individual.uid, uuid: nil,
	     given: 'Friedrich', surname: 'Meinhardt', sex: 'M',
		 nickname: 'Fritz', suffix: 'der Zweite', prefix: 'Dr', pedigree: 'nix',
		 Birthdate: '2 Nov 1801', Birthlocation: 'Wiener Neustadt',
		 Marriagedate: '19 Oct 1990', Marriagelocation: 'Wien'
    assert_redirected_to root_path + @individual.uid.to_s	

    parent = assigns(:parent)
	assert_equal parent.given, 'Friedrich'
	assert_equal parent.surname, 'Meinhardt'
	assert_equal parent.sex, 'M'
	assert_equal parent.nickname, 'Fritz'
	assert_equal parent.suffix, 'der Zweite'
	assert_equal parent.prefix, 'Dr'
	assert_equal parent.pedigree, 'nix'
	assert_equal parent.birth.date, '2 Nov 1801'
	assert_equal parent.birth.location, 'Wiener Neustadt'
	
    union = assigns(:union)		
	assert_equal union.marriage.date, '19 Oct 1990'
	assert_equal union.marriage.location, 'Wien'
	
	individual = assigns(:individual)
	assert_equal individual.parents_uid, union.uid
	assert_equal parent.uid, union.husband_uid

  end
  
  test "should create new parent with union" do
    @individual = Individual.find_by_given( "John" )
	assert_nil @individual.parents_uid
	
    xhr :post, :new_parent, uid: @individual.uid, sex: 'f'
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given'  
      assert_select 'label', 'Surname'  
      assert_select 'label', 'M/F'  
      assert_select 'label', 'Nickname'  
      assert_select 'label', 'Suffix'  
      assert_select 'label', 'Prefix'  
      assert_select 'label', 'Pedigree'  
      assert_select 'label', 'Birth Date'  
      assert_select 'label', 'Marriage Date'  	  
      assert_select 'label', 'Location'   	  	  
    end  
  end

  test "should create new parent with union - save" do
    i = Individual.find_by_given( "John" )
    john = Individual.by_uid( i.uid )
    union = Union.new
    john.parents = union
    union.save
    john.save
	assert_not_nil john.parents_uid
	post :create_new_parent, uid: john.uid, uuid: nil,
	     given: 'Friedericke', surname: 'Meinhardt', sex: 'F',
		 nickname: 'Friedi', suffix: 'die Dritte', prefix: 'Dr', pedigree: 'nix',
		 Birthdate: '2 Nov 1801', Birthlocation: 'Wiener Neustadt',
		 Marriagedate: '19 Oct 1990', Marriagelocation: 'Wien'
    assert_redirected_to root_path + john.uid.to_s	

    parent = assigns(:parent)
	assert_equal parent.given, 'Friedericke'
	assert_equal parent.surname, 'Meinhardt'
	assert_equal parent.sex, 'F'
	assert_equal parent.nickname, 'Friedi'
	assert_equal parent.suffix, 'die Dritte'
	assert_equal parent.prefix, 'Dr'
	assert_equal parent.pedigree, 'nix'
	assert_equal parent.birth.date, '2 Nov 1801'
	assert_equal parent.birth.location, 'Wiener Neustadt'
	
    union = assigns(:union)		
	assert_equal union.marriage.date, '19 Oct 1990'
	assert_equal union.marriage.location, 'Wien'
	
	individual = assigns(:individual)
	assert_equal individual.parents_uid, union.uid
	assert_equal parent.uid, union.wife_uid

  end
  
  test "remove father" do
    jill = Individual.find_by_given( "Jill" )
    assert_equal jill.parents.husband_uid, jill.father.uid

    get :remove_parent, uid: jill.uid, puid: jill.father.uid
	assert_redirected_to root_path + jill.uid.to_s
    assert_nil jill.father   
  end  

  test "remove mother" do
    j = Individual.find_by_given( "Jill" )
    jill = Individual.by_uid( j.uid )
    erin = Individual.find_by_given( "Erin" ) 
    parents = jill.parents
    parents.wife_uid = erin.uid
    parents.save    
    assert_equal jill.parents.wife_uid, jill.mother.uid

    get :remove_parent, uid: jill.uid, puid: jill.mother.uid
	assert_redirected_to root_path + jill.uid.to_s
    assert_nil jill.mother
  end  
  
  test "search_results uid" do
    jill = Individual.find_by_given( "Jill" )
    get :search_results, 'names-search-uid' => jill.uid
    assert_redirected_to root_path + jill.uid.to_s
  end
  
  test "search_results non-uid" do
    get :search_results, 'names-search-uid' => 0
    assert_redirected_to search_path 
  end

  test "import" do
    get :import
    assert_select 'form input[value=new-tree]'
  end
  
  test "ged file upload error" do
    Individual.destroy_all
    assert Individual.all.empty?
    Union.destroy_all
    assert Union.all.empty?	
    
    post :file_upload, tree: 'test-tree'
    assert_redirected_to root_path   
    assert_equal flash[:notice], 'Select file to upload first.'
    assert Individual.all.empty?
      
  end
    
  test "ged file upload" do
    Individual.destroy_all
    assert Individual.all.empty?
    Union.destroy_all
    assert Union.all.empty?	
    
    post :file_upload, tree: 'test-tree',
      file: fixture_file_upload('files/test.ged','text/txt') 
    assert_redirected_to root_path   
    assert_equal Individual.all.count, 18
    assert_equal Union.all.count, 15     
  end
  
end
