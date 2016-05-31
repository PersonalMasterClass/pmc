class HomeController < ApplicationController
  def index
    if current_user 
      if current_user.admin?
        # redirect_to :controller => 'users', :action => 'index'
      elsif current_user.presenter?
        redirect_to :controller => 'presenters', :action => 'index'
      elsif current_user.customer?
        redirect_to :controller => 'customers', :action => 'index'
      else
        # show homepage
      end
    end

    #TODO: Homepage content??
  end

  def about
     @aboutPMC = PageContent.find_by_name("aboutPMC")
     @aboutRosemary = PageContent.find_by_name("aboutRosemary")
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
