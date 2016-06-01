class InvoicesController < ApplicationController
	before_filter :check_if_user
  def index
  	all_data = []
  	all_invoices = current_user.invoices
  	all_invoices.each do |inv|
      if inv.type == "ACCPAY"
        # account receivable has booking number as invoice number
        bkg_ref = inv.invoice_number.to_i
      else
        # account payable has booking as reference
        bkg_ref = inv.reference.to_i
      end
      if bkg_ref == 0
        next
      end
  	  all_data  << Hash[:invoice => inv, :booking => Booking.find(bkg_ref)]
  	end
    all_data.reject{|i| i[:booking].nil?}
    @outstanding = all_data.reject{|i| i[:invoice].status != "AUTHORISED"}
  	# @outstanding = all_data.reject{|i| i[:invoice].amount_due - i[:invoice].amount_credited - i[:invoice].amount_paid <= 0}
  	@paid = all_data.reject{|i| i[:invoice].status != "PAID"}

    
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
