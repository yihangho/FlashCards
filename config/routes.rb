Rails.application.routes.draw do
  get 'cards/import' => 'cards#import', :as => :import_cards
  post 'cards/import' => 'cards#upload'
  get 'cards/search/' => 'cards#search', :as => :search
  patch 'cards/rate/:id' => 'cards#rate'
  get 'pronounce/:word' => 'cards#pronounce'
  get 'todos/:id/new_card' => 'todos#new_card', :as => :new_card_from_todo
  resources :cards, :except => :destroy
  resources :todos, :except => :show
  resources :decks
  get 'statistics' => 'statistics#index'
  get 'cards/:id/statistics' => 'statistics#card'
  get 'random(/:cards(/:style))' => 'cards#random', :as => :random
  root 'cards#random'

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
