class Users::RegistrationsController < Devise::RegistrationsController
before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
  autocomplete :school_info, :school_name, :full => true

  def new_presenter
    # Code from Devise 
    build_resource({})
    set_minimum_password_length
    # resource.build_presenter
    yield resource if block_given?
    respond_with self.resource

  end

  def create_presenter
    build_resource(sign_up_params)
    resource.user_type = :presenter
    resource.status = :pending
    # Populate presenter obj
    presenter = Presenter.create(phone_number: params["presenter"]["phone_number"], 
                                 first_name: params["presenter"]["first_name"],
                                 last_name: params["presenter"]["last_name"], 
                                 vit_number: params["presenter"]["vit_number"], 
                                 abn_number: params["presenter"]["abn_number"])
    resource.presenter = presenter
    resource.save


    # Code from devise
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        # This loop should never run 
        # User is never immediately authenticated, admin manually authenticates user.
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        # Send notification to admin
        Notification.new_registration
        # redirect_to new_presenter_presenter_profile_path(presenter), notice: "Whilst your account is pending approval, you can continue to complete your profile."
        flash[:warning] = "Your application has been submitted for approval. 
                           Please check your email to confirm your email."
        redirect_to root_url
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :new_presenter
    end
  end

  def new_customer
    # Code from Devise 
    build_resource({})
    set_minimum_password_length
    # resource.build_presenter
    yield resource if block_given?
    respond_with self.resource

  end

  def create_customer
    build_resource(sign_up_params)
    resource.user_type = :customer
    resource.status = :pending
    # Populate customer obj
    customer = Customer.create(phone_number: params["customer"]["phone_number"], 
                                 first_name: params["customer"]["first_name"],
                                 last_name: params["customer"]["last_name"], 
                                 vit_number: params["customer"]["vit_number"], 
                                 abn_number: params["customer"]["abn_number"],
                                 department: params["customer"]["department"],
                                 contact_title: params["customer"]["contact_title"])
    resource.customer = customer
    resource.save


    #Code from devise
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        # This loop should never run 
        # User is never immediately authenticated, admin manually authenticates user.
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        # Send notification to admin
        Notification.new_registration
        flash[:warning] = "Your application has been submitted for approval. 
                           Please check your email to confirm your email."
        redirect_to root_url
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :new_customer
    end
  end

  def approve_registration

  end
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end
  def after_sign_up_path_for(resource)
    admin_index_path
  end
  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up, presenter: [:user_id, :phone_number, :first_name, 
                                                         :last_name, :vit_number, :abn_number],
                                             customer: [:user_id, :phone_number, :first_name, 
                                                        :last_name, :vit_number, :abn_number,
                                                        :department, :contact_title]) 
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
