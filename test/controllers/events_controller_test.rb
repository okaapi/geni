require 'test_helper'

module Admin
class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
    # this is required so 'testsite45A67' fixtures get loaded
    ZiteActiveRecord.site( 'testsite45A67' )
    @user = users(:wido)
    admin_login_4_test
    request.host = 'testhost45A67'	
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      @event.location = 'Paris'
      post :create, params: { event: { rawdate: @event.rawdate,  location: @event.location,  text: @event.text } }
    end
    assert_equal assigns(:event).errors.count, 0
    assert_redirected_to event_path(assigns(:event))
  end
  
  test "should not create event" do
    assert_difference('Event.count', 0) do
      @event.location = @event.rawdate = nil
      post :create, params: { event: { rawdate: @event.rawdate,  location: @event.location,  text: @event.text } }
    end
    assert_equal assigns(:event).errors.count, 1    
    assert_response :success
  end  

  test "should show event" do
    get :show, params: { id: @event }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { id: @event }
    assert_response :success
  end

  test "should update event" do
    @event.rawdate = '2 oct 1959'
    patch :update, params: { id: @event, event: { rawdate: @event.rawdate, location: @event.location, text: @event.text } }
    assert_redirected_to event_path(assigns(:event))
  end
  
  test "should not update event" do
    @event.location = @event.rawdate = nil
    patch :update, params: { id: @event, event: { rawdate: @event.rawdate, location: @event.location, text: @event.text } }
    assert_response :success
    assert_equal assigns(:event).errors.count, 1
  end  

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, params: { id: @event }
    end

    assert_redirected_to events_path
  end
end
end