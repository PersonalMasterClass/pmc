class Xero
	# invoice item codes
	PRESENTER_RATE = "003"
	SERVICE_FEE = "004"


	# add school as Xero contact
	def self.add_school_account(customer)
		begin
			dept = ""
			if customer.department
				dept = customer.department 
			end

			contact = connect.Contact.build(:name => "#{customer.school_info.school_name} #{dept}")

			contact.first_name = customer.first_name
			contact.last_name = customer.last_name
			contact.add_address(:type => 'STREET', :line1 => customer.school_info.address, :city => customer.school_info.town, :region => customer.school_info.state, :postal_code => customer.school_info.postcode)
			contact.add_address(:type => 'POBOX', :line1 => customer.school_info.postal_address, :city => customer.school_info.postal_town, :region => customer.school_info.postal_state, :postal_code => customer.school_info.postal_postcode)
			contact.add_phone(:type => 'DEFAULT', :number => customer.phone_number)
			contact.add_phone(:type => 'DDI', :number => customer.school_info.phone_number)
			contact.email_address = customer.user.email
			contact.account_number = customer.user.id
			contact.save
		rescue Xeroizer::ApiException => e
			return e.message
		end
	end

	# add presenter as Xero contact
	def self.add_presenter_account(presenter)
		begin
			contact = connect.Contact.build(:name => "PRESENTER: #{presenter.first_name} #{presenter.last_name}" )

			contact.first_name = presenter.first_name
			contact.last_name = presenter.last_name
			contact.email_address = presenter.user.email
			contact.account_number = presenter.user.id
			contact.add_phone(:type => 'DEFAULT', :number => presenter.phone_number)

			if(presenter.abn_number)
				contact.tax_number = presenter.abn_number
			end
			contact.save
		rescue Xeroizer::ApiException => e
			return e.message
		end
	end

	# update a presenter Xero contact
	def self.update_presenter_account(presenter)
		begin
			contact = connect.Contact.all(:where => {:account_number => presenter.user.id.to_s}).first
			contact.first_name = presenter.first_name
			contact.last_name = presenter.last_name
			contact.email_address = presenter.user.email
			contact.account_number = presenter.user.id
			contact.add_phone(:type => 'DEFAULT', :number => presenter.phone_number)

			if(presenter.abn_number)
				contact.tax_number = presenter.abn_number
			end
			contact.save
		rescue Xeroizer::ApiException => e
			return e.message
		end
		return contact
	end

		# update a school Xero contact
	def self.update_school_account(customer)
		begin
			dept = ""
			if customer.department
				dept = customer.department 
			end

			contact = connect.Contact.all(:where => {:account_number => customer.user.id.to_s}).first
			contact.name = "#{customer.school_info.school_name} #{dept}"
			contact.first_name = customer.first_name
			contact.last_name = customer.last_name
			contact.email_address = customer.user.email
			contact.account_number = customer.user.id
			contact.add_phone(:type => 'DEFAULT', :number => customer.phone_number)

			contact.save
		rescue Xeroizer::ApiException => e
			return e.message
		end
		return contact
	end

	def self.last_invoice
		return connect.Contact.all.last
	end

	def self.invoice_booking(booking)
		gateway = connect
		pay_presenter(booking, gateway)

		
	end


	# Create a Xero bill (Accounts Payable) to credit the presenter their rate
	def self.pay_presenter(booking, gateway)
		presenter_account = gateway.Contact.all(:where => {:account_number => booking.chosen_presenter.user.id.to_s}).first
		p_inv = gateway.Invoice.build(:contact => presenter_account, :line_amount_types => "Exclusive")
	
		p_inv.type = "ACCPAY"
		p_inv.date = booking.booking_date
		p_inv.invoice_number = booking.id.to_s
		p_inv.status = "DRAFT"

		p_inv.contact = presenter_account
		p_inv.add_line_item({
      :description => "#{booking.subject.name} revision session",
      :item_code => PRESENTER_RATE,
      :unit_amount => booking.rate.to_f,
      :quantity => (booking.duration_minutes / 60).to_f,
      :tax_type => "INPUT"
    })
		puts p_inv.save
    return p_inv
	end

	def self.connect
		return Xeroizer::PrivateApplication.new(Figaro.env.xero_consumer, Figaro.env.xero_secret, Figaro.env.xero_cert_location)
	end

end