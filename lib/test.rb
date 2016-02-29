
require "../config/environment" unless defined?(::Rails.root)

dates = [
'2 jul 2014',
'2 jul 16',
'jul 2014',
'2014 jul',
'jul 2nd 2014',
'jul 2 2014',
'nov 4 - nov 9 1821',
'BET 28 SEP AND 24 OCT 1940',
'17 1 19?',
'AFT 1880',
'1952',
'BEF 1880',
'between 1922 and 1924' ]


def parse_date( date_string )

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
      puts date
      # we check that it find the same year as us!
      if ( date.strftime('%Y').to_i == year )
        return date, year
      else
        return Date.new( year, 1, 1 )
      end
    rescue
      return Date.new( year, 1, 1 )
    end
    
  else 
    return nil, nil
  end
end

dates.each do |dstring|

  date, year = parse_date( dstring )
  puts
  puts "#{dstring} => ->#{date}<-  (guessed year; #{year})"

end 









