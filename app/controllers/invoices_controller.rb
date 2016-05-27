class InvoicesController < ApplicationController
	before_filter :check_if_user
  def index
  	all_data = []
  	x = current_user.invoices
  	x.each do |inv|
  		all_data << Hash[:invoice => inv, :booking => Booking.find(inv.reference)]
  	end
  	@outstanding = all_data#.reject{|i| i[:invoice].amount_due - i[:invoice].amount_credited - i[:invoice].amount_paid > 0}
  	@paid = x - @outstanding
  end

  def show
  	invoice = Xero.connect.Invoice.find(params['id'])
  	if invoice.contact.account_number.to_i == current_user.id || current_user.admin?
  		send_data invoice.pdf, filename: "#{params['id']}.pdf", type: :pdf 
  	else
  		redirect_to invoices_path
  	end
  end

  private
  def check_if_user
  	if !current_user
  		redirect_to root_path
  	end
  end
end
