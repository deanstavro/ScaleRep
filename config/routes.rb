Rails.application.routes.draw do

    # V1 of API
    namespace :api do
        namespace :v1 do

            resources :leads do
                collection { post :import}
                collection do
                    post :new_lead
                end
            end

            resources :autoreply do
                collection do
                    post :out_of_office
                    post :referral
                end
            end

            resources :referral do
                collection do
                    post :new_reply
                    post :referral
                end
            end

        end
    end

    # Set Root Url
    authenticated :user do
        root 'users#home'
    end 
    root to: 'homepage#index'

    # All routes when not signed in 
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)
    resources :demos, only: [:new, :create]
    devise_for :users

    #All Routes for Signed In User

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