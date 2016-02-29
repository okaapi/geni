module ApplicationHelper
  def js?
    Rails.configuration.use_javascript
  end
  def prettytime( t )
    if t
      t.getlocal.strftime("%H:%M %m-%d-%Y")
    else
      'sometime'
    end
  end
  def is_user?
    ( @current_user and 
      ( @current_user.role == 'user' or
       @current_user.role == 'admin' ) )
  end
  def is_admin?
    ( @current_user and @current_user.role == 'admin' )
  end  
end
