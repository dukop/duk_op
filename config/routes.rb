DetSker::Application.routes.draw do
  resources :posts

  devise_for :user
  match 'users/:id' => 'user#destroy', via: :delete, as: :admin_destroy_user
  root 'calendar#index'
  resources :events, except: [:index] do
    resources :comments, except: [:new, :delete]
  end
  resources :event_series, controller: :event_series do
    delete 'delete_events', on: :member
  end
  # events has no index - instead it should redirect to calendar index with params
  get 'events', to: redirect(path: '/')

  resources :categories
  resources :locations
  resources :users, controller: :user do
    patch 'make_admin', on: :member
  end
  resources :comments

  get 'news' => 'posts#index'
  get 'anonymous_user/new' => 'anonymous_user#new'
  match '/anonymous_user' => 'anonymous_user#create', via: :post
  scope 'admin', controller: :admin do
    get :dashboard, as: :admin_dashboard
    get :series, as: :admin_series
    get :analytics, as: :admin_analytics
    scope 'analytics', controller: :admin do
      get 'timeseries', as: :analytics_timeseries
      get 'events', as: :analytics_events
    end
  end

  get 'feed' => 'calendar#index', :constraints => { :format => "rss" }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
