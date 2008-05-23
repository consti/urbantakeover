ActionController::Routing::Routes.draw do |map|
  map.resources :spot
  map.resources :team
  map.resources :quests

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
  map.hotspots '/hotspots', :controller => 'spot', :action => 'hotspots'
  map.chat '/chat', :controller => 'chat', :action => 'index'
  
  map.sparklines "sparklines", :controller => "sparklines", :action => "index"
  map.sparklines "sparklines/:action/:id/image.png", :controller => "sparklines"
  
  map.connect '/ohai', :controller => 'dashboard', :action => 'newcomer'
  map.home '/home', :controller => 'dashboard', :action => 'member'
  map.root :controller => 'dashboard', :action => 'redirect'

  # todo: maybe we can remove those thanks to map.resource - can anyone google "rails rest"
  map.show_user '/user/:id', :controller => 'user', :action => 'show'
  map.connect '/users', :controller => 'user', :action => 'list'

  map.show_spot '/spot/:id', :controller => 'spot', :action => 'show'
  map.show_team '/team/:id', :controller => 'team', :action => 'show'
  map.teams '/teams', :controller => 'team', :action => 'list'

  map.show_city '/city/:id', :controller => 'city', :action => 'show'
  map.cities '/cities', :controller => 'city', :action => 'list'

  map.join_team '/join_team/:id', :controller => 'team', :action => 'join'
  # VERY SPECIAL ROUTE
  map.connect '/:name', :controller => 'disambiguation', :action => 'index'
  # /VERY SPECIAL ROUTE
  map.which '/which/:name', :controller => 'disambiguation', :action => 'disambiguate'
  map.show '/show/:name', :controller => 'disambiguation', :action => 'disambiguate'
  map.create_team '/team/create/:name', :controller => 'team', :action => 'create'

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
