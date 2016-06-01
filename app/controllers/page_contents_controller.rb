class PageContentsController < ApplicationController
  before_filter :is_admin, :only => [:edit, :update, :index, :show] 

  def edit
    @page_contents = PageContent.find(params[:id])
  end

  def update
    @page_contents = PageContent.find(params[:id])
    if @page_contents.update(content_params)
      flash[:success] = "Content updated"
      redirect_to @page_contents.url
    else
      flash[:danger] = "invalid"
      render 'edit'
    end
  end

  # Show all editable page content
  def index
    @about = PageContent.find_by_name("aboutPMC")
    @contact = PageContent.find_by_name("contact")
    @dmca = PageContent.find_by_name("dmca")
    @earnings = PageContent.find_by_name("earnings")
    @privacy = PageContent.find_by_name("privacy")
    @terms = PageContent.find_by_name("terms")
    @help = PageContent.find_by_name("profile-help")
  end

  def show
    @content = PageContent.find(params[:id])
  end

  private
    def is_admin
      redirect_to root_url unless current_user.admin?
    end

    def content_params
      params.require(:page_content).permit(:content)
    end

end
