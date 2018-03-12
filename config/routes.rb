Rails.application.routes.draw do
  get 'lead_list/index'

  get 'lead_list/edit'

  get 'client_reports/index'

  get 'reports/index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: 'homepage#index' #'visitors#index'

  # get '/loreta', to: 'localmarket#index'
  # get '/agent', to: 'homepage#agent'
  devise_for :users
  resources :users



end
