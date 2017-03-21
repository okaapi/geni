require 'test_helper'

class TreeHelperTest < ActionView::TestCase
  
  test "sex symbol" do
  
    assert_equal sex_symbol( nil ), '?'
    assert_equal sex_symbol( 'F' ), "<span style='font-size:150%'>&#9792;</span>"
    assert_equal sex_symbol( 'f' ), "<span style='font-size:150%'>&#9792;</span>"	
    assert_equal sex_symbol( 'M' ), "<span style='font-size:150%'>&#9794;</span>"
    assert_equal sex_symbol( 'm' ), "<span style='font-size:150%'>&#9794;</span>"
    assert_equal sex_symbol( 'X' ), '?'
	
  end
  
  test "delete, marriage symbols" do
    assert_equal delete_symbol, 
	  "<i  class=\"glyphicon glyphicon-remove-circle\"></i>"
	assert_equal marriage_symbol, "<span style='font-size:larger'>&#8734;</span>"
  end
  
end
