class HomeController < ApplicationController
  def index
    if current_user 
      if current_user.admin?
        redirect_to :controller => 'users', :action => 'index'
      elsif current_user.presenter?
        redirect_to :controller => 'presenters', :action => 'index'
      elsif current_user.customer?
        redirect_to :controller => 'customers', :action => 'index'
      else
        # do nothing
      end
    end
  end
end
