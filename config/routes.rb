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
    get 'users/:id/edit_login_details' => 'users#edit_login_details', as: 'user_edit_login_details'
    get 'users/:id/enquiries' => 'users#enquiries', as: "user_enquiries"
    post 'users/update_login_details' => 'users#update_login_details', as: 'user_update_login_details'
  
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
    get 'registration/submit_form' => 'users/registrations#submit_form' 
    get 'registration/contact_form' => 'users/registrations#contact_form'  
    post 'registration/contact_form_create' => 'users/registrations#contact_form_create'

    get 'customers/:id/edit' => 'customers#edit', as: "edit_customer"
    patch 'customers/:id/update' => 'customers#update'

    get 'customers/:id/edit/contact_form' => 'customers#contact_form'
    post 'customers/:id/update/contact_form_create' => 'customers#contact_form_create'
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
  get 'bookings/choose_presenter/:presenter_id/:booking_id' => 'bookings#choose_presenter', as: "bookings_choose"
  get 'bookings/:id/gethelp' =>'bookings#get_help', as: 'bookings_help'
  get 'bookings/:id/cancelhelp' => 'bookings#cancel_help', as:"cancel_bookings_help"
  post 'booking/:id/join' => "bookings#join", as: "bookings_join" 
  patch 'booking/:id/cancel_booking' => "bookings#cancel_booking", as: "bookings_cancel"
  patch 'booking/:id/cancel_bid/' => "bookings#cancel_bid", as: "bookings_bid_cancel"
  patch 'booking/:id/leave_booking/' => "bookings#leave_booking", as: "bookings_leave"
  get 'bookings/past' => "bookings#past", as: "past_bookings"
  resources :bookings

  get 'booking/new_from_enquiry/:id' => 'bookings#new_from_enquiry', as: "new_from_enquiry"
  post 'booking/create_from_enquiry' => 'bookings#create_from_enquiry', as: "create_from_enquiry"

  resources :presenters, :only =>[:create, :edit, :update, :destroy, :index] do
    resource :presenter_profile, as: 'profile'
    resources :availabilities
    resources :subjects
    get 'edit_subjects' => 'presenters#edit_subjects'
    post 'edit_subjects/' => 'presenters#add_subject'
    
    
    post 'remove_subject' => 'presenters#remove_subject'

    get 'edit_details' => 'presenters#edit_details', as: "edit_details"
#    get 'presenters/:id/edit_details' => 'presenters#edit_details', as: "edit_details"
    patch 'update_details' => 'presenters#update_details', as: "update_details"

  end
  # get 'rate' => 'presenters#rate'
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
  resources :page_contents, :only => [:edit, :update, :index, :show]

  #Static Pages
  get 'aboutus' => 'home#about'
  get 'contactus' => 'home#contact'
  get 'termsofuse' => 'home#terms'
  get 'earningsnotice' => 'home#earnings'
  get 'dmca' => 'home#dmca'
  get 'privacypolicy' => 'home#privacy'

  resources :enquiries, :only => [:index, :new, :create, :show] do
    patch '/accept' => 'enquiries#accept'
    get '/booked' => 'enquiries#booked', as: "booked"
    patch '/decline' => 'enquiries#decline'
  end

  resources :settings, :only => [:edit, :update]
end
