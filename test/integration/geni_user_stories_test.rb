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

    Individual.destroy_all
    assert Individual.all.empty?
    Union.destroy_all
    assert Union.all.empty?			
  end
  
  
  test "logged in as admin - trying to access user page" do
  
    admin_login
	
    # should get users (only as admin)
    get_via_redirect "/users"
    assert_response :success
	
	assert_select 'a', 'wido_admin'
	assert_select 'td', 'arnaud@gmail.com'
	
	
=begin

new_person A1/1950

new_child/F A0/1970/Paris
new_child/M B0
new_child/M C0
remove_child B0

add_spouse B1 m. 1965
remove from marriage B1
add_spouse existing B1 change m. 1966

add mother A2/1930 m. 1940
add father B2/1931 m. 1941
=end	
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
