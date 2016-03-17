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
  
end
