require 'test_helper'

class AuthFilesCompareTest < ActionDispatch::IntegrationTest
  
  setup do

  end

=begin
  test "message" do
    puts "AUthFilesCOmpareTest turned off"
  end
=end

  test "models" do
    assert FileUtils.compare_file('app/models/user.rb','../menhardt/app/models/user.rb')
    assert FileUtils.compare_file('app/models/user_action.rb','../menhardt/app/models/user_action.rb')
    assert FileUtils.compare_file('app/models/user_session.rb','../menhardt/app/models/user_session.rb')   
    assert FileUtils.compare_file('app/models/site_map.rb','../menhardt/app/models/site_map.rb')
    
    assert FileUtils.compare_file('test/models/user_test.rb','../menhardt/test/models/user_test.rb')
    assert FileUtils.compare_file('test/models/site_map_test.rb','../menhardt/test/models/site_map_test.rb')
  end

  test "mailers and validators" do
    assert FileUtils.compare_file('app/mailers/authentication_notifier.rb',
                                  '../menhardt/app/mailers/authentication_notifier.rb')
    assert FileUtils.compare_file('app/validators/email_validator.rb',
                                  '../menhardt/app/validators/email_validator.rb')   
    assert FileUtils.compare_file('test/mailers/authentication_notifier_test.rb',
                                  '../menhardt/test/mailers/authentication_notifier_test.rb')                                                                 
  end
  
  test "fixtures" do
    assert FileUtils.compare_file('test/fixtures/users.yml','../menhardt/test/fixtures/users.yml')
    assert FileUtils.compare_file('test/fixtures/user_actions.yml','../menhardt/test/fixtures/user_actions.yml')   
    assert FileUtils.compare_file('test/fixtures/user_sessions.yml','../menhardt/test/fixtures/user_sessions.yml')   
    assert FileUtils.compare_file('test/fixtures/site_maps.yml','../menhardt/test/fixtures/site_maps.yml')                                  
  end  

  test "controllers" do
    assert FileUtils.compare_file('app/controllers/admin/users_controller.rb',
                                  '../menhardt/app/controllers/admin/users_controller.rb')  
    assert FileUtils.compare_file('app/controllers/admin/user_sessions_controller.rb',
                                  '../menhardt/app/controllers/admin/user_sessions_controller.rb') 
    assert FileUtils.compare_file('app/controllers/admin/user_actions_controller.rb',
                                  '../menhardt/app/controllers/admin/user_actions_controller.rb')    
    assert FileUtils.compare_file('app/controllers/admin/site_maps_controller.rb',
                                  '../menhardt/app/controllers/admin/site_maps_controller.rb')       
                                  
    assert FileUtils.compare_file('app/controllers/authenticate_controller.rb',
                                  '../menhardt/app/controllers/authenticate_controller.rb')     
    assert FileUtils.compare_file('app/controllers/application_controller.rb',
                                  '../menhardt/app/controllers/application_controller.rb')    
                                  
    assert FileUtils.compare_file('test/controllers/users_controller_test.rb',
                                  '../menhardt/test/controllers/users_controller_test.rb')  
    assert FileUtils.compare_file('test/controllers/user_actions_controller_test.rb',
                                  '../menhardt/test/controllers/user_actions_controller_test.rb')      
    assert FileUtils.compare_file('test/controllers/user_sessions_controller_test.rb',
                                  '../menhardt/test/controllers/user_sessions_controller_test.rb')  
    assert FileUtils.compare_file('test/controllers/authenticate_controller_test.rb',
                                  '../menhardt/test/controllers/authenticate_controller_test.rb')        
    assert FileUtils.compare_file('test/controllers/site_maps_controller_test.rb',
                                  '../menhardt/test/controllers/site_maps_controller_test.rb')   
    assert FileUtils.compare_file('test/test_helper.rb', '../menhardt/test/test_helper.rb')                                     
                                                                                                                                                                                                                                                                                                                              
  end
  
  test "views" do
                                
    assert compare_directories('app/views/authenticate', '../menhardt/app/views/authenticate')   
    assert compare_directories('app/views/authentication_notifier', '../menhardt/app/views/authentication_notifier')       

    assert compare_directories('app/views/admin/users', '../menhardt/app/views/admin/users') 
    assert compare_directories('app/views/admin/user_sessions', '../menhardt/app/views/admin/user_sessions')   
    assert compare_directories('app/views/admin/user_actions', '../menhardt/app/views/admin/user_actions') 
    assert compare_directories('app/views/admin/site_maps', '../menhardt/app/views/admin/site_maps') 
                                                 
  end
   
  test "integration" do
    assert FileUtils.compare_file('test/integration/auth_user_stories_test.rb', 
                                  '../menhardt/test/integration/auth_user_stories_test.rb')                                                                                                                                                                                                                                                                                                                                                                   
  end  
  
  test "migrations" do
    assert FileUtils.compare_file('db/migrate/20141106192626_create_users.rb',
                                  '../menhardt/db/migrate/20141106192626_create_users.rb')  
    assert FileUtils.compare_file('db/migrate/20141106192627_create_user_sessions.rb',
                                  '../menhardt/db/migrate/20141106192627_create_user_sessions.rb')  
    assert FileUtils.compare_file('db/migrate/20141106192628_create_user_actions.rb',
                                  '../menhardt/db/migrate/20141106192628_create_user_actions.rb')                                                                      
    assert FileUtils.compare_file('db/migrate/20150715210233_add_site_to_users.rb',
                                  '../menhardt/db/migrate/20150715210233_add_site_to_users.rb')  
    assert FileUtils.compare_file('db/migrate/20150715210246_add_site_to_user_sessions.rb',
                                  '../menhardt/db/migrate/20150715210246_add_site_to_user_sessions.rb')  
    assert FileUtils.compare_file('db/migrate/20150715210318_add_site_to_user_actions.rb',
                                  '../menhardt/db/migrate/20150715210318_add_site_to_user_actions.rb') 
    assert FileUtils.compare_file('db/migrate/20150723195726_create_site_maps.rb',
                                  '../menhardt/db/migrate/20150723195726_create_site_maps.rb')  
  end

  test "yaml" do
    assert FileUtils.compare_file('config/auth_mail.yml','../menhardt/config/auth_mail.yml')
  end
  
  test "assets" do
    assert file_diff('app/assets/stylesheets/application.scss',
                      '../menhardt/app/assets/stylesheets/application.scss'), "@import \"okaapi\";\n"
  end  

  private
  
  def compare_directories( d1, d2 )
    files = Dir.entries( d1 )
    files.each do |f|
      if f != '.' and f != '..'
        f1 = d1 + '/' + f
        f2 = d2 + '/' + f    
        if ! FileUtils.compare_file( f1, f2 )
          puts "#{f1} IS NOT #{f2}"
          return false
        end
      end
    end
    return true
  end
  
  def file_diff( f1, f2 )
    lines1 = lines2 = nil
    File.open(f1) { |f| lines1 = f.readlines }
    File.open(f2) { |f| lines2 = f.readlines }
    diff_string = ''
    lines1.each_with_index do |c,i|
      if lines1[i] != lines2[i]
        diff_string += lines1[i]
      end
    end
    return diff_string
  end
  
end
