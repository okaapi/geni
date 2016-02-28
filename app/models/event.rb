class Event < ActiveRecord::Base

  def self.compare_dates( e1, e2, order )
  
    if e1 
      begin
        d1 = Date.parse( e1.date )
      rescue  
        d1 = nil
      end
    else
      d1 = nil
    end
    
    if e2 
      begin
        d2 = Date.parse( e2.date )
      rescue  
        d2 = nil
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
  
end
