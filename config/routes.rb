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
    get 'all_individuals_by_uid' => 'individuals#all_individuals_by_uid', as: 'all_individuals_by_uid'
    get 'individual_by_uid/:uid' => 'individuals#individual_by_uid', as: 'individual_by_uid'
    resources :unions
    get 'all_unions_by_uid' => 'unions#all_unions_by_uid', as: 'all_unions_by_uid'
    get 'union_by_uid/:uid' => 'unions#union_by_uid', as: 'union_by_uid'
           
  end    

  # resources for the app
  get 'surnames' => 'geni#surnames', as: 'surnames'  
  get 'names_for_surname' => 'geni#names_for_surname', as: 'names_for_surname'     
  get 'names_for_term' => 'geni#names_for_term', as: 'names_for_term' 
  get 'depth_change/:change/(:uid)' => 'geni#depth_change', as: 'depth_change' 
  get 'import' => 'geni#import', as: 'import'
  post 'file_upload' => 'geni#file_upload', as: 'file_upload'
  
  get 'edit/:uid' => 'geni#edit', as: 'edit'
  get 'union_edit/:uuid/:uid' => 'geni#union_edit', as: 'union_edit'
  post 'save/:uid' => 'geni#save', as: 'save'  
  post 'union_save/:uid/:uuid' => 'geni#union_save', as: 'union_save'   
  
  match 'marriage_new/:uid' => 'geni#marriage_new', as: 'marriage_new', via: [:get, :post]
  post 'save_marriage_new/:uid' => 'geni#save_marriage_new', as: 'save_marriage_new'  
  match 'marriage_existing/:uid' => 'geni#marriage_existing', as: 'marriage_existing', via: [:get, :post]
  post 'save_marriage_existing/:uid' => 'geni#save_marriage_existing', as: 'save_marriage_existing'    
  get 'delete_marriage/:uid/:uuid' => 'geni#delete_marriage', as: 'delete_marriage' 

  match 'add_spouse/:uid/(:uuid)' => 'geni#add_spouse', as: 'add_spouse', via: [:get, :post]  
  match 'new_spouse/:uid/:uuid' => 'geni#new_spouse', as: 'new_spouse', via: [:get, :post]    
  post 'save_added_spouse/:uid/:uuid' => 'geni#save_added_spouse', as: 'save_added_spouse'  
  post 'create_new_spouse/:uid/:uuid' => 'geni#create_new_spouse', as: 'create_new_spouse'   
  get 'remove_spouse/:uid/:uuid' => 'geni#remove_spouse', as: 'remove_spouse'  
	
  match 'add_child/:uid/:uuid' => 'geni#add_child', as: 'add_child', via: [:get, :post]  
  match 'new_child/:uid/:uuid' => 'geni#new_child', as: 'new_child', via: [:get, :post]    
  post 'save_added_child/:uid/:uuid' => 'geni#save_added_child', as: 'save_added_child'  
  post 'create_new_child/:uid/:uuid' => 'geni#create_new_child', as: 'create_new_child'    
  get 'remove_child/:uid/:puid' => 'geni#remove_child', as: 'remove_child'  
  
  get 'new_person' => 'geni#new_person', as: 'new_person' 
  post 'create_person' => 'geni#create_person', as: 'create_person' 
  
  get 'remove_parent/:uid/:puid' => 'geni#remove_parent', as: 'remove_parent'
  match 'new_parent/:uid/:sex/(:uuid)' => 'geni#new_parent', as: 'new_parent', via: [:get, :post]    
  match 'create_new_parent/:uid/(:uuid)' => 'geni#create_new_parent', as: 'create_new_parent', via: [:get, :post]  
  
  match 'search' => 'geni#search', as: 'search', via: [:get, :post]
  post 'search_results' => 'geni#search_results', as: 'search_results'  
  
  # this has to be the last one or else...
  get ':uid' => 'geni#tree', as: 'tree'  

  root "geni#surnames", as: "root"
    
end
