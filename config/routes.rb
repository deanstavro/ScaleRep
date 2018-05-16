Rails.application.routes.draw do
  
  # V1 of API
  namespace :api do
    namespace :v1 do


      resources :leads do
        collection { post :import}
        collection do
          post :new_lead
          #post :all_metrics
        end
      end

      resources :metrics do
        collection do
          post :all_metrics
        end
      end

      #resources :campaigns, except: [:new, :edit] do
      #  collection do
      #    post :new_campaigns
      #  end
      #end


    end
  end


  get 'lead_list/index'

  get 'lead_list/edit'

  get 'client_reports/index'

  get 'reports/index'

  

  get 'metrics/index'

  #get 'client_companies/edit'

  #patch 'client_companies/update'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  authenticated :user do
    root 'users#home'
  end

  root to: 'homepage#index' #'visitors#index'

  devise_for :users
  resources :users
    
  resources :client_companies do
    resource :personas
    resources :campaigns
  end
  
  resources :leads do
    collection { post :import_to_campaign}
    collection { get :fields}
  end

  




end
