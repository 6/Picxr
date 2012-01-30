PicMixr::Application.routes.draw do
  
  root :to => "home#index"

  match "/s/:provider" => "sessions#create", :via => :post
  match "/logout" => "sessions#destroy", :as => :logout
  
  match "/iproxy/:url_or_id" => 'mixr#proxy'
  match "/iproxy/p/:url_or_id" => 'mixr#proxy'
  match "/save" => 'mixr#save', :via => :post
  match "/upload" => 'pictures#create', :via => :post
  match "/url-upload" => 'pictures#create_from_url', :via => :post
  
  # handled by backbone router
  match '/albums/:id' => 'home#index'
  match '/album/:id' => 'home#index'
  match '/tags/:id' => 'home#index'
  match '/edit/:url_or_id' => 'home#index', :as => "edit"
  match '/edit/p/:id' => 'home#index', :as => "edit_private"
  match '/upload/:type' => 'home#index', :as => "upload"
  
  match '/about' => 'static#about'
  match '/about/contact' => 'static#contact'
  match '/about/terms' => 'static#terms', :as => "terms"
  match '/about/privacy' => 'static#privacy', :as => "privacy"
  match '/about/tech' => 'static#tech', :as => "tech"

  match "/dl/p/:id" => "pictures#download"
  match "/dl/:id" => "pictures#download"
  
  match "/p/:id" => "pictures#show"
  match "/:id" => "pictures#show" # this should always be the last route
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
