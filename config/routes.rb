ActionController::Routing::Routes.draw do |map|
  map.resources :spot

  map.settings '/settings', :controller => 'user', :action => 'settings'
  map.howto '/howto', :controller => 'claims', :action => 'howto'
  map.faq '/faq', :controller => 'claims', :action => 'faq'
  map.claim '/claim', :controller => 'claims', :action => 'new'
  map.login '/login', :controller => 'user', :action => 'login'
  map.logout '/logout', :controller => 'user', :action => 'logout'
  map.connect '/recover_password', :controller => 'user', :action => 'forgot_password'
  map.signup '/signup', :controller => 'user', :action => 'signup'
  map.connect '/profile', :controller => 'user', :action => 'settings'
  map.highscore '/highscore', :controller => 'score', :action => 'index'

  map.sticker '/sticker', :controller => 'sticker', :action => 'index'
  map.stickers '/stickers', :controller => 'sticker', :action => 'index'
  map.order '/stickers', :controller => 'sticker', :action => 'index'

  map.team '/team', :controller => 'team', :action => 'index'
  map.hotspots '/hotspots', :controller => 'spot', :action => 'hotspots'
  map.chat '/chat', :controller => 'chat', :action => 'index'
  map.connect '/users', :controller => 'user', :action => 'list'
  
  map.sparklines "sparklines", :controller => "sparklines", :action => "index"
  map.sparklines "sparklines/:action/:id/image.png", :controller => "sparklines"
    
  # map.root :controller => 'claims', :action => 'recent'
  
  map.connect '/ohai', :controller => 'dashboard', :action => 'newcomer'
  map.home '/home', :controller => 'dashboard', :action => 'member'
  
  map.root :controller => 'dashboard', :action => 'redirect'
    
  map.join_team '/join_team/:id', :controller => 'team', :action => 'join'
  map.connect '/:name', :controller => 'disambiguation', :action => 'index'
  map.which '/which/:name', :controller => 'disambiguation', :action => 'disambiguate'
  map.show '/show/:name', :controller => 'disambiguation', :action => 'disambiguate'
  map.show_user '/user/:name', :controller => 'user', :action => 'show_by_name'
  map.show_spot '/spot/:name', :controller => 'spot', :action => 'show_by_name'
  map.show_team '/team/:name', :controller => 'team', :action => 'show_by_name'


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
