Rails.application.routes.draw do

    # V1 of API
    namespace :api do
        namespace :v1 do

            resources :accounts do

                collection do
                    post :upload
                    post 'account' => 'accounts#create'
                    get 'account/:p1', to: 'accounts#index', constraints: { p1: /[^\/]+/ }

                end
            end

            resources :leads do
                collection { post :import}
                collection do
                    post :new_lead
                end
            end

            resources :reply do
                collection do
                    post :new_reply
                    post :auto_reply_referral
                    post :auto_reply
                    post :referral
                    post :interested
                    post :not_interested
                    post :do_not_contact
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