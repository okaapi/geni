require 'test_helper'

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
	Individual.new( given: 'John', name: 'John /Smith/', 
	                surname: 'Smith', sex: 'm' ).save
	Individual.new( given: 'Erin', name: 'Erin /Smith/', 
	                surname: 'Smith', sex: 'f' ).save					
	Individual.new( given: 'Mary', name: 'Mary /Jones/', 
	                surname: 'Jones', sex: 'f' ).save
	
	jill = Individual.new( given: 'Jill', name: 'Jill /Jefferson/', 
	                surname: 'Jefferson', sex: 'f' )
    Union.new( wife_uid: jill.uid ).save
    (parents = Union.new).save
	jill.parents_uid = parents.uid
	jill.save
	
  end
  
  test "should get tree" do
	get :tree, uid: Individual.find_by_given( "John" ).uid
	assert_response :success
	individual = assigns(:individual)
	assert_select '.currentindividualcontainer  a', 'John Smith'
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
  
  ##########################################################################
  # needs to be json test
  test "names for term" do
    ###get :names_for_term, term: 'ith'
    ###p names = assigns(:names)
  end  
  
  test "depth_change" do
    get :tree, uid: Individual.find_by_given( "John" ).uid
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
		 Deathdate: '17 Mar 1987', Deathlocation: 'Rome'
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

  test "new marriage with existing person" do
    @individual = Individual.find_by_given( "John" )
	assert_equal @individual.unions.count, 0
    xhr :post, :marriage_existing, uid: @individual.uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given or surname'  	  	  
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

  test "create new spouse for existing marriage - save" do
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
	
  test "add existing spouse to existing marriage" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
    xhr :post, :add_spouse, uid: @individual.uid, uuid: @union.uid
	assert_response :success
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given or surname'   	  	  
    end  
  end
  
  test "add existing spouse to existing marriage - save" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
	@spouse = Individual.new( name: 'Marc')
	@spouse.save
	post :save_added_spouse, uid: @individual.uid, uuid: @union.uid,
	     'names-search-uid' => @spouse.uid
    assert_redirected_to root_path + @individual.uid.to_s	

    spouse = assigns(:spouse)
	assert_equal spouse.name, 'Marc'
    union = assigns(:union)	
    individual = assigns(:individual)			
	assert_equal union.wife_uid, individual.uid
	assert_equal union.husband_uid, spouse.uid
	
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

  end
  
  test "should add new child" do
    @individual = Individual.find_by_given( "Jill" )
	@union = @individual.unions[0]
    xhr :post, :add_child, uid: @individual.uid, uuid: @union.uid
    assert_select_jquery :html, '#editcontainer' do
      assert_select 'label', 'Given or surname'   	  	  
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
    @individual = Individual.find_by_given( "Jill" )
	assert_not_nil @individual.parents_uid
	
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

  test "should create new parent with union - save" do
    @individual = Individual.find_by_given( "Jill" )
	assert_not_nil @individual.parents_uid
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

end
