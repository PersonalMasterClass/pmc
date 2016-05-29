class PageContentsController < ApplicationController
  before_filter :is_admin, :only => [:edit, :update] 

  def edit
    @page_contents = PageContent.find(params[:id])
  end

  def update
    @page_contents = PageContent.find(params[:id])
    if @page_contents.update(content_params)
      flash[:success] = "Content updated"
      redirect_to root_url
    else
      flash[:danger] = "invalid"
      render 'edit'
    end
  end

  private
    def is_admin
      redirect_to root_url unless current_user.admin?
    end

    def content_params
      params.require(:page_content).permit(:content)
    end

end
