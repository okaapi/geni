require 'test_helper'

module Admin
class IndividualsControllerTest < ActionController::TestCase
  setup do
    @individual = individuals(:one)
    # this is required so 'testsite45A67' fixtures get loaded
    ZiteActiveRecord.site( 'testsite45A67' )
    @user = users(:wido)
    admin_login_4_test
    request.host = 'testhost45A67'		
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:individuals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create individual" do
    @individual.name = 'John Doe'
    assert_difference('Individual.count') do
      post :create, params: { individual: { birth_id: @individual.birth_id, death_id: @individual.death_id, gedfile: @individual.gedfile, gedraw: @individual.gedraw, given: @individual.given, name: @individual.name, nickname: @individual.nickname, note: @individual.note, parents_uid: @individual.parents_uid, pedigree: @individual.pedigree, prefix: @individual.prefix, sex: @individual.sex, suffix: @individual.suffix, surname: @individual.surname, tree: @individual.tree, uid: @individual.uid } }
    end

    assert_redirected_to individual_path(assigns(:individual))
  end
  
  test "should create individual without any name" do
    @individual.given = @individual.surname = @individual.name = nil    
    assert_difference('Individual.count', 1) do
      post :create, params: { individual: { birth_id: @individual.birth_id, death_id: @individual.death_id, 
                                  gedfile: @individual.gedfile, gedraw: @individual.gedraw, 
                                  given: @individual.given, name: @individual.name, nickname: @individual.nickname, 
                                  note: @individual.note, parents_uid: @individual.parents_uid, 
                                  pedigree: @individual.pedigree, prefix: @individual.prefix, 
                                  sex: @individual.sex, suffix: @individual.suffix, 
                                  surname: @individual.surname, tree: @individual.tree, uid: @individual.uid } }
    end
    assert_equal assigns(:individual).errors.count, 0
    assert_equal assigns(:individual).name, "//"
    assert_redirected_to '/individuals/' + assigns(:individual).id.to_s
  end  

  test "should create individual without given and surname, derive surname" do
    @individual.name = " /Mueller/"
    @individual.given = @individual.surname =  nil
    assert_difference('Individual.count', 1) do
      post :create, params: { individual: { birth_id: @individual.birth_id, death_id: @individual.death_id, 
                                  gedfile: @individual.gedfile, gedraw: @individual.gedraw, 
                                  given: @individual.given, name: @individual.name, nickname: @individual.nickname, 
                                  note: @individual.note, parents_uid: @individual.parents_uid, 
                                  pedigree: @individual.pedigree, prefix: @individual.prefix, 
                                  sex: @individual.sex, suffix: @individual.suffix, 
                                  surname: @individual.surname, tree: @individual.tree, uid: @individual.uid } }
    end
    assert_equal assigns(:individual).errors.count, 0
    assert_equal assigns(:individual).given, ""
    assert_equal assigns(:individual).surname, "Mueller"
    assert_redirected_to '/individuals/' + assigns(:individual).id.to_s
  end  
  
  test "should create individual without given and surname, derive name" do
    @individual.name = " son / /"
    @individual.given = @individual.surname =  nil
    assert_difference('Individual.count', 1) do
      post :create, params: { individual: { birth_id: @individual.birth_id, death_id: @individual.death_id, 
                                  gedfile: @individual.gedfile, gedraw: @individual.gedraw, 
                                  given: @individual.given, name: @individual.name, nickname: @individual.nickname, 
                                  note: @individual.note, parents_uid: @individual.parents_uid, 
                                  pedigree: @individual.pedigree, prefix: @individual.prefix, 
                                  sex: @individual.sex, suffix: @individual.suffix, 
                                  surname: @individual.surname, tree: @individual.tree, uid: @individual.uid } }
    end
    assert_equal assigns(:individual).errors.count, 0
    assert_equal assigns(:individual).given, "son"
    assert_equal assigns(:individual).surname, ""
    assert_redirected_to '/individuals/' + assigns(:individual).id.to_s
  end    

  test "should show individual" do
    get :show, params: { id: @individual }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @individual }
    assert_response :success
  end

  test "should update individual" do
    @individual.name = 'John Doe'
    patch :update, params: { id: @individual, individual: { birth_id: @individual.birth_id, death_id: @individual.death_id, gedfile: @individual.gedfile, gedraw: @individual.gedraw, given: @individual.given, name: @individual.name, nickname: @individual.nickname, note: @individual.note, parents_uid: @individual.parents_uid, pedigree: @individual.pedigree, prefix: @individual.prefix, sex: @individual.sex, suffix: @individual.suffix, surname: @individual.surname, tree: @individual.tree, uid: @individual.uid } }
    assert_redirected_to individual_path(assigns(:individual))
  end
  
  test "should update individual fail" do
    @individual.given = @individual.surname = @individual.name = nil
    patch :update, params: { id: @individual, individual: { birth_id: @individual.birth_id, death_id: @individual.death_id, gedfile: @individual.gedfile, gedraw: @individual.gedraw, given: @individual.given, name: @individual.name, nickname: @individual.nickname, note: @individual.note, parents_uid: @individual.parents_uid, pedigree: @individual.pedigree, prefix: @individual.prefix, sex: @individual.sex, suffix: @individual.suffix, surname: @individual.surname, tree: @individual.tree, uid: @individual.uid } }
    assert_equal assigns(:individual).errors.count, 0 
    assert_equal assigns(:individual).name, "//"
    assert_redirected_to '/individuals/' + assigns(:individual).id.to_s
  end  

  test "should destroy individual" do
    assert_difference('Individual.count', -1) do
      delete :destroy, params: { id: @individual }
    end

    assert_redirected_to individuals_path
  end

  
end
end
