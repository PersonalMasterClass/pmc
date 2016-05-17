Rails.application.routes.draw do

root 'home#index'
  devise_for :users,
              controllers: {
                registrations: 'users/registrations',
                sessions: 'users/sessions',
                passwords: 'users/passwords',
                confirmations: 'users/confirmations'
              }

    get 'admin/approve_user/:id' => 'users#approve_user', as: "admin_approve_user"
    get 'admin/suspend_user/:id' => 'users#suspend_user', as: "admin_suspend_user"
    get 'admin/' => 'users#index'
    get 'admin/pending_registrations' => 'users#registrations'
    get 'users/:id' => 'users#show', as: "user"
  
  resources :customers, only: [:index, :show]
  devise_scope :user do
    get 'registration/presenters' => 'users/registrations#new_presenter'
    post 'registration/presenters' => 'users/registrations#create_presenter'
    get 'registration/customers' => 'users/registrations#new_customer'
    post 'registration/customers' => 'users/registrations#create_customer'
    get 'registration/vit_validation' => 'users/registrations#vit_validation'
  end


  get "/school_info/find" => 'school_info#find'

  get "/subjects/find" => 'subjects#find'
  resources :subjects do
    get "/presenters" => 'subjects#view_presenters'
  end

  get 'bookings/open' => 'bookings#open'
  get 'bookings/bid/:id' => 'bookings#bid', as: "bookings_bid"
  post 'bookings/set_bid/' => 'bookings#set_bid', as: "bookings_set_bid"
  get 'bookings/choose_presenter/:presenter_id' => 'bookings#choose_presenter', as: "bookings_choose"
  resources :bookings
  
  resources :presenters do
    resource :presenter_profile, as: 'profile'
    resources :availabilities
    resources :subjects
    get 'edit_subjects' => 'presenters#edit_subjects'
    post 'edit_subjects' => 'presenters#add_subject'
    get 'rate' => 'presenters#rate'
    post 'set_rate' => 'presenters#set_rate'
    post 'remove_subject' => 'presenters#remove_subject'
  end
  get 'presenter/:presenter_id/presenter_profile/approve' => 'presenter_profiles#approve',  as: 'approve_presenter_profile'
  
  get 'profiles/search' => 'search#index'

  resource :availability
  
  get 'admin/pending_profiles' => 'presenter_profiles#pending', as: 'admin_pending_profiles'

  get '/notif_read' => 'application#notif_read'

  get 'admin/suspended_users' => 'users#suspended_users', as: 'admin_suspended_users'

  get 'admin/schools' => 'users#customers', as: 'admin_customers'

  get 'admin/presenters' => 'users#presenters', as: 'admin_presenters'

  resources :notifications, only: :index
  
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
