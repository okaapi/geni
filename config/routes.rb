Rails.application.routes.draw do
  resources :events

  resources :individuals
  get 'all_individuals_by_uid' => 'individuals#all_by_uid', as: 'all_individuals_by_uid'
  get 'individuals_by_uid/:uid' => 'individuals#by_uid', as: 'individual_by_uid'

  resources :unions
  get 'all_unions_by_uid' => 'unions#all_by_uid', as: 'all_unions_by_uid'
  get 'union_by_uid/:uid' => 'unions#by_uid', as: 'union_by_uid'

  get 'import' => 'import#index'
  post 'import/file_upload' => 'import#file_upload'
  
  get 'first_names/:surname' => 'geni#first_names', as: 'first_names'
  get 'tree/:uid' => 'geni#tree', as: 'tree'  
  
  root "geni#index", as: "root"
    
end
