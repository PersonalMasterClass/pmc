class UserMailer < ApplicationMailer

	# Send email to all admins regarding a new registration
  def registration_mail(admin)
    # @user = user
    @url  = '/admin/pending_registrations'
		mail(to: admin.email, subject: 'Presenter Registration Requires Approval.')
  end

end
