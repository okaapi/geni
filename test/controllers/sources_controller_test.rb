require 'test_helper'

module Admin

class SourcesControllerTest < ActionController::TestCase
  setup do
    @source = sources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create source" do
    assert_difference('Source.count') do
      post :create, source: { content: @source.content, filename: @source.filename, gedfile: @source.gedfile, gedraw: @source.gedraw, sid: @source.sid, title: @source.title, tree: @source.tree }
    end

    assert_redirected_to source_path(assigns(:source))
  end

  test "should show source" do
    get :show, id: @source
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @source
    assert_response :success
  end

  test "should update source" do
    patch :update, id: @source, source: { content: @source.content, filename: @source.filename, gedfile: @source.gedfile, gedraw: @source.gedraw, sid: @source.sid, title: @source.title, tree: @source.tree }
    assert_redirected_to source_path(assigns(:source))
  end

  test "should destroy source" do
    assert_difference('Source.count', -1) do
      delete :destroy, id: @source
    end

    assert_redirected_to sources_path
  end
end

end
