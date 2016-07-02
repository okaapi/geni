module TreeHelper

  def sex_symbol( s )
    if !s
      '?'
    elsif s.downcase == 'm'
      "<span style='font-size:150%'>&#9794;</span>".html_safe
    elsif s.downcase == 'f'
      "<span style='font-size:150%'>&#9792;</span>".html_safe
    else
      '?'
    end
  end
    
  def gender( s )
    if !s
      ''
    elsif s.male?
      "m".html_safe
    elsif s.female?
      "f".html_safe
    else
      ''
    end
  end

  def geni_gender( s )
    if !s
      ''
    elsif s.male?
      'geni-male'
    elsif s.female?
      'geni-female'
    else
      'geni-other'
    end
  end
  
  def geni_level( l, loc )
    if l == 1
      'geni-1-'+loc
    elsif l == 2
      'geni-2-'+loc
    elsif l == 3
      'geni-3-'+loc
    else
      'geni-N-'+loc      
    end
  end

  def oppgender( s )
    if !s
      ''
    elsif s.male?
      "f".html_safe
    elsif s.female?
      "m".html_safe
    else
      ''
    end
  end

  def marriage_symbol
    "<span style='font-size:larger'>&#8734;</span>".html_safe    
  end

  def delete_symbol
    '<i  class="glyphicon glyphicon-remove-circle"></i>'.html_safe
  end
  
  def font_level( font, level )
    font - 2*level
  end
   
end
