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
    get 'users/:id/role_change/:role' => 'users#role_change', as: 'role_change'
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
  get 'surnames' => 'geni#surnames', as: 'surnames'  
  get 'names/:surname' => 'geni#names', as: 'names' 
  get 'depth_change/:change/(:uid)' => 'geni#depth_change', as: 'depth_change' 
  get 'import' => 'geni#import', as: 'import'
  post 'file_upload' => 'geni#file_upload', as: 'file_upload'
  
  get 'edit/:uid' => 'geni#edit', as: 'edit'
  post 'save/:uid' => 'geni#save', as: 'save'  
  match 'new_marriage/:uid' => 'geni#new_marriage', as: 'new_marriage', via: [:get, :post]
  post 'save_marriage/:uid' => 'geni#save_marriage', as: 'save_marriage'  
  get 'delete_marriage/:uid/:uuid' => 'geni#delete_marriage', as: 'delete_marriage' 
  match 'add_child/:uid/:uuid' => 'geni#add_child', as: 'add_child', via: [:get, :post]  
  match 'new_child/:uid/:uuid' => 'geni#new_child', as: 'new_child', via: [:get, :post]    
  post 'save_child/:uid/:uuid' => 'geni#save_child', as: 'save_child'  
  post 'create_child/:uid/:uuid' => 'geni#create_child', as: 'create_child'    
  get 'remove_child/:uid/:puid' => 'geni#remove_child', as: 'remove_child'  
  get 'new_person' => 'geni#new_person', as: 'new_person' 
  post 'create_person' => 'geni#create_person', as: 'create_person' 
  get 'delete_parent/:uid/:puid' => 'geni#delete_parent', as: 'delete_parent'
  match 'new_father/:uid' => 'geni#new_father', as: 'new_father', via: [:get, :post]   
  match 'new_mother/:uid' => 'geni#new_father', as: 'new_mother', via: [:get, :post]   
  
  match 'search' => 'geni#search', as: 'search', via: [:get, :post]
  post 'search_results' => 'geni#search_results', as: 'search_results'  
  
  # this has to be the last one or else...
  get ':uid' => 'geni#tree', as: 'tree'  

  root "geni#surnames", as: "root"
    
end
