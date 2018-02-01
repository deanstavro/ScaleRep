Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  root to: 'homepage#index' #'visitors#index'
  
  get '/just_sold', to: 'localmarket#index'
  get '/agent', to: 'homepage#agent'
  devise_for :users
  resources :users



end
