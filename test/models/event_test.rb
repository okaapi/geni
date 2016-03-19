require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "parse dates" do
	e = Event.new( rawdate: "2 jul 2014" )
	assert_equal e.date, "2 Jul 2014"
	e = Event.new( rawdate: "2 jul 16" )
	assert_equal e.date, nil
	e = Event.new( rawdate: "jul 2014" )
	assert_equal e.date, "1 Jul 2014"
	e = Event.new( rawdate: "2014 jul" )
	assert_equal e.date, "1 Jul 2014"
	e = Event.new( rawdate: "jul 2nd 2014" )
	assert_equal e.date, "2 Jul 2014"
	e = Event.new( rawdate: "jul 2 2014" )
	assert_equal e.date, "2 Jul 2014"
	e = Event.new( rawdate: "nov 4 - nov 9 1821" )
	assert_equal e.date, "1821"
	e = Event.new( rawdate: "BET 28 SEP AND 24 OCT 1940" )
	assert_equal e.date, "1940"
	e = Event.new( rawdate: "17 1 19?" )
	assert_equal e.date, nil
	e = Event.new( rawdate: "AFT 1880" )
	assert_equal e.date, "1880"
	e = Event.new( rawdate: "1952" )
	assert_equal e.date, "1952"
	e = Event.new( rawdate: "BEF 1880" )
	assert_equal e.date, "1880"
	e = Event.new( rawdate: "between 1922 and 1924" )
	assert_equal e.date, "1922"

  end
  
  test "dates" do
    e = Event.new( rawdate: "2 oct 1959")
	assert_equal e.date_as_datetime, Date.new( 1959, 10, 2 )
    e = Event.new( rawdate: "bla 1959")
	assert_equal e.date_as_datetime, Date.new( 1959, 1, 1 )
  end
  
  test "compare dates" do
 
    e1 = Event.new( rawdate: "2 oct 1959")
	e2 = Event.new( rawdate: "1959-10-2")
    assert_equal Event.compare_dates( e1, e2, true ), 0
	
    e1 = Event.new( rawdate: "2 oct 1959")
	e2 = Event.new( rawdate: "3 oct 1959")
    assert_equal Event.compare_dates( e1, e2, true ), -1
	assert_equal Event.compare_dates( e1, e2, false ), 1
	
	e3 = Event.new( rawdate: "bla bla")
    assert_equal Event.compare_dates( e1, e3, true ), -1
	assert_equal Event.compare_dates( e1, e3, false ), -1	

    e4 = Event.new()
    assert_equal Event.compare_dates( e1, e4, true ), -1
	assert_equal Event.compare_dates( e4, e1, false ), 1
	assert_equal Event.compare_dates( e4, e4, false ), 0
	
	e5 = Event.new( rawdate: "bla bla 1950")
    assert_equal Event.compare_dates( e1, e5, true ), 1
	assert_equal Event.compare_dates( e5, e1, false ), 1
	
	assert_equal Event.compare_dates( e5, nil, false ), -1	
	assert_equal Event.compare_dates( nil, e5, false ), 1		
	assert_equal Event.compare_dates( nil, nil, false ), 0
	
  end
  
end
