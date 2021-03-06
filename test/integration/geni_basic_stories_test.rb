require 'test_helper'

class GeniBasicStoriesTest < ActionDispatch::IntegrationTest
  
  setup do

    ZiteActiveRecord.site( 'testsite45A67' )
    @user_arnaud = users(:arnaud)
    @wido = users(:admin)
    @not_java = ! Rails.configuration.use_javascript
    # not sure why request has to be called first, but it won't work without
    request
    open_session.host! "testhost45A67"

  	assert !Individual.all.empty?
    Individual.destroy_all
    assert Individual.all.empty?
  	assert !Union.all.empty?
    Union.destroy_all
    assert Union.all.empty?			
	Import.from_gedfile('test-tree', 'test/fixtures/files/test.ged','test.ged', false)
	assert_equal Individual.all.count, 18
	assert_equal Union.all.count, 15
  end

  test "not logged in get surnames, first names and tree" do

    get  "/surnames" 	
    assert_response :success  
    assert_select '#surnames a', 'Miller'   
	assert_select '#surnames a', 'Smith' 
	assert_select '#surnames a', 'Viss' 	
	assert_select '#surnames a', 'Walther' 		
	assert_select '#surnames a', 4
	
	get "/names_for_surname", params: { surname: 'Miller' }
	assert_response :success
	assert_select '#names a', 'W. M.', 2
	assert_select '#names a', 'Leon'
	assert_select '#names a', 5
	
	i = Individual.where( given: 'Walther', surname: 'Miller').order( ver: :asc).last
	get "/" + i.uid
	assert_equal @controller.session[:display], "graph"		
	assert_response :success
	assert_match /'W. M.'/, @response.body
	#assert_select 'script', 'W. M.'

	get "/vis_change"
	assert_equal @controller.session[:display], "tree"	
	get "/" + i.uid
	assert_response :success
	assert_select '.geni-inner  a', 'W. M.'	
		
  end  
  
  test "logged in as user get surnames, first names and tree" do

    user_login( true )
	
    get  "/surnames" 	

    assert_response :success
    assert_select '#surnames a', 'Miller'   
	assert_select '#surnames a', 'Smith' 
	assert_select '#surnames a', 'Viss' 	
	assert_select '#surnames a', 'Walther' 		
	assert_select '#surnames a', 4
	
	get "/names_for_surname", params: { surname: 'Miller' }
	assert_response :success
	assert_select '#names a', 'Jack'
	assert_select '#names a', 'walther'	
	assert_select '#names a', 'Leon'
	assert_select '#names a', 5
	
	i = Individual.where( given: 'Walther', surname: 'Miller').order( ver: :asc).last
	get "/" + i.uid
	assert_equal @controller.session[:display], "graph"		
	assert_response :success
	assert_match /'.*Walther.*Miller.*'/, @response.body
	#assert_select 'script', 'Walther Miller'

	get "/vis_change"
	assert_equal @controller.session[:display], "tree"	
	get "/" + i.uid
	assert_response :success
	assert_select '.geni-inner  a', 'Walther Miller'	
	
  end
  
  
   
  test "not logged in - trying to access user page" do
  
    # should NOT get users (only as admin)
    get "/users"
	assert_response :redirect
	
    assert_equal flash[:notice], 'must be admin'
	
  end
 
  test "logged in as user - trying to access user page" do
  
    user_login( true )
	
    # should NOT get users (only as admin)
    get "/users"
    assert_response :redirect
	
    assert_equal flash[:notice], 'must be admin'
	
  end

  test "logged in as admin - trying to access user page" do
  
    admin_login( true )
	
    # should get users (only as admin)
    get "/users"
    assert_response :success
	
	assert_select 'a', 'wido_admin'
	assert_select 'td', 'arnaud@gmail.com'
	
  end  
    
  test "all individuals by uid" do
    admin_login( true )
    get "/all_individuals_by_uid"   
    assert_select '.admin-table tr', 11   
    assert_select '.admin-table td', 80
    assert_select '.admin-table td', 'Joe'
    assert_select '.admin-table td', 'Walther'
    get "/all_individuals_by_uid", params: { name_sorted: true }
    get "/all_individuals_by_uid", params: { birth_sorted: true }
  end
 
  test "individuals by uid" do
    admin_login( true )
    i = Individual.first
    get "/individual_by_uid/#{i.uid}" 
    assert_select 'table tr td p b', 17   # labels
    assert_select 'table tr td p b', 'Name:'
    assert_select 'table tr td p', /Joe Miller/   
    assert_select 'table tr td p b', 'Sources:'	
  end 
     
  test "all unions by uid" do
    admin_login( true )
    get "/all_unions_by_uid"
    assert_select '.admin-table tr', 8  
    assert_select '.admin-table td', 35
    assert_select '.admin-table td a', 'Walther Miller'
    assert_select '.admin-table td a', 'Laura Walther'
    get "/all_unions_by_uid", params: { marriage_sorted: true }
  end  
 
  test "unions by uid" do
    admin_login( true )
    u = Union.first
    get "/union_by_uid/#{u.uid}" 
    assert_select 'table tr p a', "Jack Miller"  
  end  
 
  private
  
  def user_login( not_java )
    # enters correct password and gets logged in and session is created
    if not_java
      post "/_prove_it", params: { claim: "arnaud", kennwort: "secret" }
      assert_redirected_to root_path
    else
      post "/_prove_it", xhr: true, params: { claim: "arnaud", kennwort: "secret" }
      assert_response :success
    end
    assert_equal flash[:notice], 'arnaud logged in'
    get "/"
    assert_response :success
  end	
  
  def admin_login( not_java )
    # enters correct password and gets logged in and session is created
    if not_java
      post "/_prove_it", params: { claim: "wido_admin", kennwort: "secret" }
      assert_redirected_to root_path
    else
      post "/_prove_it", xhr: true, params: { claim: "wido_admin", kennwort: "secret" }
      assert_response :success
    end
    assert_equal flash[:notice], 'wido_admin logged in'
    get "/"
    assert_response :success  
  end
 
end
