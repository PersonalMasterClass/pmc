class UserMailer < ApplicationMailer

  def registration_mail(user,admin)
    @admin = admin
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Presenter Registration Requires Approval.')
  end
end
