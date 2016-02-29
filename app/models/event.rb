class Event < ActiveRecord::Base

  def date
    d, y = Event.parse_date( self.rawdate )
    if d
      d.strftime("%-d %b %Y")
    elsif y
      y.to_s
    else
      nil
    end
  end
  
  def date_as_datetime
    d, y = Event.parse_date( self.rawdate )
    if d
      return d
    elsif y
      return Date.new( y, 1, 1 )
    else
      nil
    end
  end  
  
  def self.compare_dates( e1, e2, order )
  
    if e1
      d1, y1 = Event.parse_date( e1.rawdate )
      if !d1 and y1
        d1 = Date.new( y1, 1, 1 )
      end
    else
      d1 = nil
    end
      
    if e2
      d2, y2 = Event.parse_date( e2.rawdate )
      if !d2 and y2
        d2 = Date.new( y2, 1, 1 )
      end
    else
      d2 = nil
    end              
    
    if d1 and d2
      return ( order ? d1 <=> d2 : d2 <=> d1 )
    elsif d1
      return -1
    elsif d2
      return 1
    else 
      return 0
    end
    
  end

  def self.parse_date( date_string )

	  year = date = nil
	  if date_string 
	
	    # first we guess at a year
	    # if there is no year, Date.parse will assume it's
	    # the current year, and that's (almost) always wrong
	    if /(\d\d\d\d)/ =~ date_string
	      year = Regexp.last_match(1).to_i
	    else
	      return nil, nil
	    end      
	    # if the year is known, we try to parse it...
	    begin
	      date = Date.parse( date_string )
	      # we check that it find the same year as us!
	      if ( date.strftime('%Y').to_i == year )
	        return date, year
	      else
	        return nil, year
	      end
	    rescue
	      return nil, year
	    end
	    
	  else 
	    return nil, nil
	  end
	  
  end
  
end
