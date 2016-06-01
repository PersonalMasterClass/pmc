Rails.application.routes.draw do

  get 'invoices/index'

root 'home#index'

#Embed resque frontend
mount Resque::Server.new, :at => "admin/resque"
mount ResqueWeb::Engine => 'admin/resque'

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
  
  #resources :customers, only: [:index, :show], as: "schools" 
  get 'presenters' => 'presenters#index'
  get 'schools' => 'customers#index', as: "customers"
  get 'school/:id' => 'customers#show', as: "customer"

  # invoices
  get 'invoices' => 'invoices#index'
  get 'invoices/download/:id' => 'invoices#show', as: 'invoice_download'

  get 'presenter' => 'presenters#index'

  devise_scope :user do
    get 'registration/presenters' => 'users/registrations#new_presenter'
    post 'registration/presenters' => 'users/registrations#create_presenter'
    #TODO: customers to schools
    get 'registration/schools' => 'users/registrations#new_customer', as: "registration_customers"
    post 'registration/schools' => 'users/registrations#create_customer' #as: "registrations_customers"
    get 'registration/vit_validation' => 'users/registrations#vit_validation'
  end


  get "/school_info/find" => 'school_info#find'

  get "school_info/:id" => 'school_info#show', as: 'school_info'

  #get "school_info" => 'school_info#show' 

  get "/subjects/find" => 'subjects#find'
  get "/subscribe/index" => 'subjects#subscriptions', as: "subscriptions"
  get "/subscribe/new" => 'subjects#new_subscription', as: "subscriptions_new"
  post "/subscribe/remove/:id" => 'subjects#unsubscribe', as: "unsubscribe"
  post "/subscribe/create" => 'subjects#subscribe', as: "subscribe"
  resources :subjects do
    get "/presenters" => 'subjects#view_presenters'
  end

  get 'bookings/open' => 'bookings#open'
  get 'bookings/bid/:id' => 'bookings#bid', as: "bookings_bid"
  post 'bookings/set_bid/' => 'bookings#set_bid', as: "bookings_set_bid"
  get 'bookings/choose_presenter/:presenter_id' => 'bookings#choose_presenter', as: "bookings_choose"
  get 'bookings/:id/gethelp' =>'bookings#get_help', as: 'bookings_help'
  post 'booking/:id/join' => "bookings#join", as: "bookings_join" 
  patch 'booking/:id/cancel_booking' => "bookings#cancel_booking", as: "bookings_cancel"
  patch 'booking/:id/cancel_bid/' => "bookings#cancel_bid", as: "bookings_bid_cancel"
  patch 'booking/:id/leave_booking/' => "bookings#leave_booking", as: "bookings_leave"
  resources :bookings
  resources :presenters, :only =>[:create, :edit, :update, :destroy] do
    resource :presenter_profile, as: 'profile'
    resources :availabilities
    resources :subjects
    get 'edit_subjects' => 'presenters#edit_subjects'
    post 'edit_subjects/' => 'presenters#add_subject'
    get 'rate' => 'presenters#rate'
    
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
  post 'set_rate' => 'presenters#set_rate', as: "set_rate"
  resources :page_contents, :only => [:edit, :update]

  get 'legal' => 'home#legal'
  resources :enquiries, :only => [:index, :new, :create, :show] do
    patch '/accept' => 'enquiries#accept'
    get '/booked' => 'enquiries#booked', as: "booked"
    patch '/decline' => 'enquiries#decline'
  end
end
