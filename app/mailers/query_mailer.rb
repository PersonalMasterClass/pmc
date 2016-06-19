class QueryMailer < ApplicationMailer
  # New enquiry mail
	def new_enquiry(user, message, reference)
  	if user.customer?
  		@name = user.customer.school_info.school_name
  	elsif user.presenter?
  		@name = user.presenter.first_name
  	else
      @name = "Admin"
      @user = user
    end
  	@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

  # Counter enquiry mail
  def counter_enquiry(user, message, reference)
    if user.customer?
      @name = user.customer.school_info.school_name
    elsif user.presenter?
      @name = user.presenter.first_name
    else
      @name = "Admin"
      @user = user
    end
    @reference = "#{root_url}#{reference}"
    mail(to: user.email, subject: message)
  end

  # Accept enquiry mail
	def accept_enquiry(user, message, reference)
  	if user.customer?
  		@name = user.customer.school_info.school_name
  	elsif user.presenter?
  		@name = user.presenter.first_name
    else
      @name = "Admin"
      @user = user
    end
  	@user = user
  	@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end

  # Declined enquiry mail
	def declined_enquiry(user, message, reference)
  	if user.customer?
  		@name = user.customer.school_info.school_name
  	elsif user.presenter?
  		@name = user.presenter.first_name
    else
      @name = "Admin"
      @user = user
    end
  	@user = user
  	@reference = "#{root_url}#{reference}"
		mail(to: user.email, subject: message)
	end
end
