require 'test_helper'

module Admin

class SourceRefsControllerTest < ActionController::TestCase
  setup do
    @source_ref = source_refs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:source_refs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create source_ref" do
    assert_difference('SourceRef.count') do
      post :create, params: { source_ref: { individual_uid: @source_ref.individual_uid, source_id: @source_ref.source_id, union_uid: @source_ref.union_uid } }
    end

    assert_redirected_to source_ref_path(assigns(:source_ref))
  end

  test "should show source_ref" do
    get :show, params: { id: @source_ref }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @source_ref }
    assert_response :success
  end

  test "should update source_ref" do
    patch :update, params: { id: @source_ref, source_ref: { individual_uid: @source_ref.individual_uid, source_id: @source_ref.source_id, union_uid: @source_ref.union_uid } }
    assert_redirected_to source_ref_path(assigns(:source_ref))
  end

  test "should destroy source_ref" do
    assert_difference('SourceRef.count', -1) do
      delete :destroy, params: { id: @source_ref }
    end

    assert_redirected_to source_refs_path
  end
end

end