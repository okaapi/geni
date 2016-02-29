module TreeHelper

  def sex_symbol( s )
    if !s
      '?'
    elsif s.downcase == 'm'
      "<span style='font-size:large'>&#9794;</span>".html_safe
    elsif s.downcase == 'f'
      "<span style='font-size:large'>&#9792;</span>".html_safe
    else
      '?'
    end
  end
  def marriage_symbol
    "<span style='font-size:large'>&#8734;</span>".html_safe
  end
  
end
