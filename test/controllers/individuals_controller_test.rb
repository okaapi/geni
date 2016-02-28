require 'test_helper'

class IndividualsControllerTest < ActionController::TestCase
  setup do
    @individual = individuals(:one)
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
    assert_difference('Individual.count') do
      post :create, individual: { birth_id: @individual.birth_id, changed_ged: @individual.changed_ged, death_id: @individual.death_id, gedfile: @individual.gedfile, gedraw: @individual.gedraw, given: @individual.given, name: @individual.name, nickname: @individual.nickname, note: @individual.note, parents_uid: @individual.parents_uid, pedigre: @individual.pedigre, prefix: @individual.prefix, sex: @individual.sex, suffix: @individual.suffix, surname: @individual.surname, tree: @individual.tree, uid: @individual.uid }
    end

    assert_redirected_to individual_path(assigns(:individual))
  end

  test "should show individual" do
    get :show, id: @individual
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @individual
    assert_response :success
  end

  test "should update individual" do
    patch :update, id: @individual, individual: { birth_id: @individual.birth_id, changed_ged: @individual.changed_ged, death_id: @individual.death_id, gedfile: @individual.gedfile, gedraw: @individual.gedraw, given: @individual.given, name: @individual.name, nickname: @individual.nickname, note: @individual.note, parents_uid: @individual.parents_uid, pedigre: @individual.pedigre, prefix: @individual.prefix, sex: @individual.sex, suffix: @individual.suffix, surname: @individual.surname, tree: @individual.tree, uid: @individual.uid }
    assert_redirected_to individual_path(assigns(:individual))
  end

  test "should destroy individual" do
    assert_difference('Individual.count', -1) do
      delete :destroy, id: @individual
    end

    assert_redirected_to individuals_path
  end
end
