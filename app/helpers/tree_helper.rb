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
  
  def text_field( field_name, field, size = nil  )
    if !size
      s = field ? ( field.length > 0 ? field.length : 3 ) : 3
    else
      s = size      
    end    
    '<div class="field">'.html_safe + 
      label_tag( field_name ) + '<div style="clear:both"></div>'.html_safe + 
              text_field_tag( field_name, field, size: s ) +
    '</div>'.html_safe          
  end
  
  def event_field( field_name, event )
    date = ( event and event.rawdate ) ? event.rawdate : ''
    location = ( event and event.location ) ? event.location : ''
    '<div class="field">'.html_safe + 
      label_tag( field_name + ' date' ) + '<div style="clear:both"></div>'.html_safe +
      text_field_tag( field_name+'date', date, size: 11 ) +
    '</div>'.html_safe + 
    '<div class="field">'.html_safe + 
      label_tag( 'location' ) + '<div style="clear:both"></div>'.html_safe +
      text_field_tag( field_name+'location', location, size: 13 ) +
    '</div>'.html_safe    
  end    
   
end
