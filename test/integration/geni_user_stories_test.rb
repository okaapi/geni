require 'test_helper'

class GeniUserStoriesTest < ActionDispatch::IntegrationTest
  
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
    assert_select '.container a', 'Miller'   
	assert_select '.container a', 'Smith' 
	assert_select '.container a', 'Viss' 	
	assert_select '.container a', 'Walther' 		
	assert_select '.container a', 10
	
	get "/names_for_surname", surname: 'Miller'
	assert_response :success
	assert_select '.container a', 'W. M.', 2
	assert_select '.container a', 'Leon'
	assert_select '.container a', 10
	
	i = Individual.where( given: 'Walther', surname: 'Miller').order( ver: :asc).last
	get "/" + i.uid
	assert_response :success
	assert_select '.currentindividualcontainer  a', 'W. M.'
		
  end
  
  
  
  test "logged in as user get surnames, first names and tree" do

    user_login
	
    get  "/surnames" 	

    assert_response :success
    assert_select '.container a', 'Miller'   
	assert_select '.container a', 'Smith' 
	assert_select '.container a', 'Viss' 	
	assert_select '.container a', 'Walther' 		
	assert_select '.container a', 9
	
	get "/names_for_surname", surname: 'Miller'
	assert_response :success
	assert_select '.container a', 'Jack'
	assert_select '.container a', 'walther'	
	assert_select '.container a', 'Leon'
	assert_select '.container a', 9
	
	i = Individual.where( given: 'Walther', surname: 'Miller').order( ver: :asc).last
	get "/" + i.uid
	assert_response :success
	assert_select '.currentindividualcontainer  a', 'Walther Miller'
	
  end
  
  test "not logged in - trying to access user page" do
  
    # should NOT get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
    assert_equal flash[:notice], 'must be admin'
	
  end
 
  test "logged in as user - trying to access user page" do
  
    user_login
	
    # should NOT get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
    assert_equal flash[:notice], 'must be admin'
	
  end
  
  test "logged in as admin - trying to access user page" do
  
    admin_login
	
    # should get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
	assert_select 'a', 'wido_admin'
	assert_select 'td', 'arnaud@gmail.com'
	
  end  
  
  
  test "all individuals by uid" do
    admin_login
    get "/all_individuals_by_uid"   
    assert_select '.admin-table tr', 11   
    assert_select '.admin-table td', 80
    assert_select '.admin-table td', 'Joe'
    assert_select '.admin-table td', 'Walther'
    get "/all_individuals_by_uid", name_sorted: true
    get "/all_individuals_by_uid", birth_sorted: true
  end
  
  test "individuals by uid" do
    admin_login
    i = Individual.first
    get "/individual_by_uid/#{i.uid}" 
    assert_select 'table tr td p b', 16   # labels
    assert_select 'table tr td p b', 'Name:'
    assert_select 'table tr td p', /Joe Miller/    
  end 
    
  test "all unions by uid" do
    admin_login
    get "/all_unions_by_uid"
    assert_select '.admin-table tr', 8  
    assert_select '.admin-table td', 35
    assert_select '.admin-table td a', 'Walther Miller'
    assert_select '.admin-table td a', 'Laura Walther'
    get "/all_unions_by_uid", marriage_sorted: true
  end  
  
  test "unions by uid" do
    admin_login
    u = Union.first
    get "/union_by_uid/#{u.uid}" 
    assert_select 'table tr p a', "Jack Miller"  
  end  
  
  private
  
  def user_login
    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "arnaud", password: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "arnaud", password: "secret"
      assert_response :success
    end
    assert_equal flash[:notice], 'arnaud logged in'
    get "/"
    assert_response :success
  end	
  
  def admin_login
    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "wido_admin", password: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "wido_admin", password: "secret"
      assert_response :success
    end
    assert_equal flash[:notice], 'wido_admin logged in'
    get "/"
    assert_response :success  
  end
 
end
