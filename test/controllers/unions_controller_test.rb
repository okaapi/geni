require 'test_helper'

module Admin
class UnionsControllerTest < ActionController::TestCase
  setup do
    @union = unions(:one)
    # this is required so 'testsite45A67' fixtures get loaded
    ZiteActiveRecord.site( 'testsite45A67' )
    @user = users(:wido)
    admin_login_4_test
    request.host = 'testhost45A67'	
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:unions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create union" do

    assert_difference('Union.count') do
      post :create, params: { union: { divorce_id: @union.divorce_id, marriage_id: @union.marriage_id, 
                                       note: @union.note, tree: @union.tree, uid: @union.uid } }
    end

    assert_redirected_to union_path(assigns(:union))
  end
  
  test "should create union fail" do
    assert_difference('Union.count', 0) do
      @union.husband_uid = @union.wife_uid = 10
      post :create, params: { union: { divorce_id: @union.divorce_id, husband_uid: @union.husband_uid, marriage_id: @union.marriage_id, note: @union.note, tree: @union.tree, uid: @union.uid, wife_uid: @union.wife_uid } }
    end
    assert_equal assigns(:union).errors.count, 1    
    assert_response :success
  end  

  test "should show union" do
    get :show, params: { id: @union }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @union }
    assert_response :success
  end

  test "should update union" do
    patch :update, params: { id: @union, union: { divorce_id: @union.divorce_id, marriage_id: @union.marriage_id, 
                                                  note: @union.note, tree: @union.tree, uid: @union.uid } }
    assert_redirected_to union_path(assigns(:union))
  end
  
  test "should update union fail" do
    @union.husband_uid = @union.wife_uid = 10
    patch :update, params: { id: @union, union: { divorce_id: @union.divorce_id, husband_uid: @union.husband_uid, marriage_id: @union.marriage_id, note: @union.note, tree: @union.tree, uid: @union.uid, wife_uid: @union.wife_uid } }
    assert_equal assigns(:union).errors.count, 1    
    assert_response :success    
  end  
  
  test "should destroy union" do
    assert_difference('Union.count', -1) do
      delete :destroy, params: { id: @union }
    end

    assert_redirected_to unions_path
  end
end
end
