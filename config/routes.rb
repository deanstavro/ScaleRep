Rails.application.routes.draw do

    # V1 of API
    namespace :api do
        namespace :v1 do

            resources :account do
                collection do
                    post :upload
                    post 'new' => 'account#create'
                    get ':p1', to: 'account#index', constraints: { p1: /[^\/]+/ }
                end
            end

            resources :lead do
                collection { post :import}
                collection do
                    post :new
                    put :edit
                end
            end

            resources :reply do
                collection do
                    post :new_reply
                end
            end

        end
    end

    # Set Root Url
    authenticated :user do
        root 'users#home'
    end 
    root to: 'homepage#index'


    # ALL ROUTES FOR USERS NOT SIGNED IN
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)
    resources :demos, only: [:new, :create]
    devise_for :users




    #ALL ROUTES FOR USERS SIGNED IN
    get 'client_reports/index'
    get 'metrics/index'
    
    resources :users

    # Nested In Client Companies
    resource :client_companies, path: '', only: [:edit, :update, :delete] do  
        resources :personas
        resources :campaigns
    end

    resources :leads do
        collection { post :import_to_campaign}
        collection { get :fields}
    end
    resources :contacts
    resources :accounts


end