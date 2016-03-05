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
	Import.from_gedfile('test-tree', 'test/integration/test.ged','test.ged', false)
	assert_equal Individual.all.count, 18
	assert_equal Union.all.count, 15
  end


  test "not logged in get surnames, first names and tree" do

    get  "/" 	
    assert_response :success
    assert_select '.container a', 'Menhardt'   
	assert_select '.container a', 'Vieser' 
	assert_select '.container a', 'Wipplinger' 	
	assert_select '.container a', 'Walther' 		
	assert_select '.container a', 9
	
	get "/names/Menhardt"
	assert_response :success
	assert_select '.container a', 'W. M.', 2
	assert_select '.container a', 'Lars'
	assert_select '.container a', 8
	
	i = Individual.where( given: 'Wido', surname: 'Menhardt').order( ver: :asc).last
	get "/" + i.uid
	assert_response :success
	assert_select '.marriageview  a', 'W. M.'
	
	
  end
  
  
  
  test "logged in as user get surnames, first names and tree" do

    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "arnaud", xylophone: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "arnaud", xylophone: "secret"
      assert_response :success
    end
    assert_equal flash[:notice], 'arnaud logged in'
    get "/"
    assert_response :success
	
    get  "/" 	
    assert_response :success
    assert_select '.container a', 'Menhardt'   
	assert_select '.container a', 'Vieser' 
	assert_select '.container a', 'Wipplinger' 	
	assert_select '.container a', 'Walther' 		
	assert_select '.container a', 8
	
	get "/names/Menhardt"
	assert_response :success
	assert_select '.container a', 'Wido'
	assert_select '.container a', 'walther'	
	assert_select '.container a', 'Lars'
	assert_select '.container a', 7
	
	i = Individual.where( given: 'Wido', surname: 'Menhardt').order( ver: :asc).last
	get "/" + i.uid
	assert_response :success
	assert_select '.marriageview  a', 'Wido Menhardt'
	
	
  end
  
  test "not logged in - trying to access user page" do
  
    # should NOT get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
    assert_equal flash[:notice], 'must be admin'
	
  end
 
  test "logged in as user - trying to access user page" do
  
    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "arnaud", xylophone: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "arnaud", xylophone: "secret"
      assert_response :success
    end
    assert_equal flash[:notice], 'arnaud logged in'
    get "/"
    assert_response :success
	
    # should NOT get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
    assert_equal flash[:notice], 'must be admin'
	
  end
  
  test "logged in as admin - trying to access user page" do
  
    # enters correct password and gets logged in and session is created
    if @not_java
      post "/_prove_it", claim: "wido_admin", xylophone: "secret"
      assert_redirected_to root_path
    else
      xhr :post, "/_prove_it", claim: "wido_admin", xylophone: "secret"
      assert_response :success
    end
    assert_equal flash[:notice], 'wido_admin logged in'
    get "/"
    assert_response :success
	
    # should get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
	assert_select 'a', 'wido_admin'
	assert_select 'td', 'arnaud@gmail.com'
	
  end  
 
end
