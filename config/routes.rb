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

            resources :salesforce do
                collection do
                    post :authentication
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
                    post :email_open
                    post :email_sent
                    post :email_reply
                end
            end

        end
    end


    # SET ROOT URLS
    authenticated :user do
        root 'metrics#index'
    end
    root to: 'homepage#index'


    # ALL ROUTES FOR USERS NOT SIGNED IN
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)
    resources :demos, only: [:new, :create]
    devise_for :users


    #ALL ROUTES FOR USERS SIGNED IN
    get 'metrics', to: 'metrics#index'
    # Nested In Client Companies
    resource :client_companies, path: '', only: [:edit, :update, :delete] do
      resources :personas do
        collection { put :archive}
      end
      resources :campaigns do
        collection {put :archive}
      end
    end
    resources :leads do
      collection { post :import_blacklist}
      collection { post :update_reply_from_portal}
      collection { get :fields}
      collection { post :import_to_current_campaign}
      collection { post :update_lead_import}
    end
    
    resources :contacts
    resources :accounts
    resources :campaign
    resources :users
    resources :data_uploads do
      collection { post :campaign_data}
      collection { get :show_data_list}
    end
    resources :salesforces do
        collection {put :toggle}
    end

    match 'auth/:provider/callback', to: 'salesforces#web_authentication', via: [:get, :post]
    match 'auth/:provider/setup', to: 'salesforces#setup', via: [:get, :post]
    match 'auth/failure', to: 'salesforces#index', via: [:get, :post]
end
