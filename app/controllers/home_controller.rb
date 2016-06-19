class HomeController < ApplicationController
  skip_before_filter :profile_created?
  def index
    if current_user 
      if current_user.admin?
        redirect_to :controller => 'users', :action => 'index'
      elsif current_user.presenter?
        redirect_to :controller => 'presenters', :action => 'index'
      elsif current_user.customer?
        redirect_to :controller => 'customers', :action => 'index'
      else
        # show homepage
      end
    end

  end

  ## Static pages ##
  def about
     @aboutPMC = PageContent.find_by_name("aboutPMC")
  end

  def contact
    @contact = PageContent.find_by_name("contact")
  end

  def dmca
    @dmca = PageContent.find_by_name("dmca")
  end

  def earnings
    @earnings = PageContent.find_by_name("earnings")
  end

  def privacy
    @privacy = PageContent.find_by_name("privacy")
  end 

  def terms
    @terms = PageContent.find_by_name("terms")
  end

end
