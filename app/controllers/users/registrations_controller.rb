class Users::RegistrationsController < Devise::RegistrationsController
before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
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
                                 # abn_number: params["presenter"]["abn_number"]
                                 )
    # presenter.school_info:= SchoolInfo.find(params["s"])
    
    presenter.school_info = SchoolInfo.find_by(school_name: params['school_info']['school_name'])
    resource.presenter = presenter
    resource.save



    # customer.school_info = SchoolInfo.find_by(school_name: params['school_info']['school'])
    # resource.customer = customer
    # resource.save

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
        Notification.send_message(resource, "Welcome! Set your base rate!", root_path)
        Notification.notify_admin("A new registration has been submitted for approval.", admin_pending_registrations_path)
        # redirect_to new_presenter_presenter_profile_path(presenter), notice: "Whilst your account is pending approval, you can continue to complete your profile."
        flash[:warning] = "Your application has been submitted for approval. 
                           Please check your email to confirm your email."
        redirect_to root_url
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :action=>'new_presenter'
    end
  end

  def vit_validation
    # first check to see if the three parameters we use are populated
    if params[:first_name] != "" && params[:last_name] != "" && params[:vit_number] != ""
      vit = VitValidation.check_vit(params[:first_name], params[:last_name], params[:vit_number])
      render json: vit
    end
  end

  def new_customer
    # Code from Devise 
    # Params by default have two hashes; controller and action
    # If validation fails, params will have more hash values
    # if params.count > 2
    #   build_resource(params)
    # else
      build_resource({})
    # end
    set_minimum_password_length
    # resource.build_presenter
    yield resource if block_given?
    respond_with self.resource
    # resource = User.new
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
                                 # abn_number: params["customer"]["abn_number"],
                                 department: params["customer"]["department"],
                                 contact_title: params["customer"]["contact_title"])
    customer.school_info = SchoolInfo.find_by(school_name: params['school_info']['school_name'])
    resource.customer = customer
    resource.save
    # Xero.add_school_account(customer)
   # #Code from devise
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
        Notification.notify_admin("A new registration has been submitted for approval.", admin_pending_profiles_path)
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

  def contact_form
      @contact = Contact_Form.new
      render action: "contact_form"
  end

  def contact_form_create
    @contact = Contact_Form.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      flash.now[:notice] = 'Thank you for your message. We will contact you soon!'
    else
      flash.now[:error] = 'Cannot send message.'
    end
      render action: "contact_form"

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
                                                        :department, :contact_title],
                                          school_info:  [:school_name])
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
