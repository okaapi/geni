Rails.application.routes.draw do
  
  # these are the actions related to authentication
  get "_who_are_u" => "authenticate#who_are_u", as: 'who_are_u'
  post "_prove_it" => "authenticate#prove_it", as: 'prove_it'
  post "_about_urself" => "authenticate#about_urself", as: 'about_urself'
  get "_from_mail/(:user_token)" => "authenticate#from_mail", as: 'from_mail'
  post "_ur_secrets" => "authenticate#ur_secrets", as: "ur_secrets"
  get "_reset_mail" => "authenticate#reset_mail", as: 'reset_mail'
  get "_see_u" => "authenticate#see_u", as: 'see_u'
    
  # these should only be available to administrators...
  scope module: 'admin' do  
  
    # for authentication
    resources :users
    resources :user_actions
    resources :user_sessions  
    resources :site_maps
    
    # for administration
    resources :events
    resources :individuals
    get 'all_individuals_by_uid' => 'individuals#all_by_uid', as: 'all_individuals_by_uid'
    get 'individuals_by_uid/:uid' => 'individuals#by_uid', as: 'individual_by_uid'
    resources :unions
    get 'all_unions_by_uid' => 'unions#all_by_uid', as: 'all_unions_by_uid'
    get 'union_by_uid/:uid' => 'unions#by_uid', as: 'union_by_uid'
           
  end    

  # resources for the app
  get 'import' => 'import#index'
  post 'import/file_upload' => 'import#file_upload'
  
  get 'first_names/:surname' => 'geni#first_names', as: 'first_names'
  get ':uid' => 'geni#tree', as: 'tree'  
  root "geni#index", as: "root"
    
end
