class SettingsController < ApplicationController
	before_filter :find_setting, :only => [:edit, :update]

	# Settings form
	def edit
	end

	# Update settings
	def update
		@setting.update!(setting_params)
		flash[:success] = "Settings saved."
		redirect_to root_url
	end

	private
	def setting_params
      params.require(:setting).permit(:booking, :enquiry, :system)
    end
	def find_setting
		@setting = Setting.find(params[:id])
	end
end
