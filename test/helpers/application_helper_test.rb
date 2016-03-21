require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  test "pretty sometime" do
  
    assert_equal prettytime( nil ), 'sometime'
	
  end

  
end
