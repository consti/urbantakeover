ActionController::Routing::Routes.draw do |map|
  map.resources :spot
  map.resources :users
  map.resources :orders

  map.settings '/settings', :controller => 'user', :action => 'settings'
  map.howto '/howto', :controller => 'claims', :action => 'howto'
  map.faq '/faq', :controller => 'claims', :action => 'faq'
  map.claim '/claim', :controller => 'claims', :action => 'new'
  map.login '/login', :controller => 'user', :action => 'login'
  map.logout '/logout', :controller => 'user', :action => 'logout'
  map.connect '/recover_password', :controller => 'user', :action => 'forgot_password'
  map.signup '/signup', :controller => 'user', :action => 'signup'
  map.settings '/settings', :controller => 'user', :action => 'settings'
  map.connect '/profile', :controller => 'user', :action => 'settings'
  map.home '/home', :controller => 'user', :action => 'home'
  map.highscore '/highscore', :controller => 'score', :action => 'index'
  map.sticker '/sticker', :controller => 'sticker', :action => 'index'
  map.stickers '/stickers', :controller => 'sticker', :action => 'index'
  map.team '/team', :controller => 'team', :action => 'index'
  map.order '/stickers', :controller => 'sticker', :action => 'index'
  
  map.root :controller => 'claims', :action => 'recent'
  
  map.connect '/:name', :controller => 'disambiguation', :action => 'index'
  map.connect '/which/:name', :controller => 'disambiguation', :action => 'disambiguate'
  map.connect '/user/:name', :controller => 'user', :action => 'show_by_name'
  map.connect '/spot/:name', :controller => 'spot', :action => 'show_by_name'
  map.connect '/team/:name', :controller => 'team', :action => 'show_by_name'


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
