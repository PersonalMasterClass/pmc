	class Xero
	# invoice item codes
	PRESENTER_RATE = "003"
	SERVICE_FEE = "001"

	# set an initial accounting ref to the user id.
	def self.set_accounting_ref(user)
		user.accounting_ref = connect.Contact.all.last.contact_id
		user.save
	end

	# add school as Xero contact
	def self.add_school_account(customer)
		if customer.nil?
			return false
		end
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
			
			if contact.save
				set_accounting_ref(customer.user)
				return true
			end
			# contact.account_number = customer.user.accounting_ref
		rescue Xeroizer::ApiException => e
			# Create a new accounting reference is there is a clash in the accounting system
			if e.message.include? "ValidationException"
				return false
			end
		end
	end

	# add presenter as Xero contact
	def self.add_presenter_account(presenter)
		if presenter.nil?
			return false
		end
		
		begin
			gateway = connect
			if !gateway
				return false
			end
			contact = gateway.Contact.build(:name => "PRESENTER: #{presenter.first_name} #{presenter.last_name} #{presenter.vit_number}" )


			contact.first_name = presenter.first_name
			contact.last_name = presenter.last_name
			contact.email_address = presenter.user.email
			# contact.account_number = presenter.user.accounting_ref
			contact.add_phone(:type => 'DEFAULT', :number => presenter.phone_number)

			if(presenter.abn_number)
				contact.tax_number = presenter.abn_number
			end
			
			if contact.save
				set_accounting_ref presenter.user
			end
		rescue Xeroizer::ApiException => e
			if e.message.include? "ValidationException"
				return false
			end
		end
		return true
	end

	# update a presenter Xero contact
	def self.update_presenter_account(presenter)
		if presenter.nil?
			return false
		end

		begin
			
			if !connect
				return false
			end
			contact = connect.Contact.all(:where => {:contact_id => presenter.user.accounting_ref}).first
			
			if contact.nil?
				return add_presenter_account(presenter)
			end
			
			contact.first_name = presenter.first_name
			contact.last_name = presenter.last_name
			contact.email_address = presenter.user.email
			# contact.account_number = presenter.user.accounting_ref
			contact.add_phone(:type => 'DEFAULT', :number => presenter.phone_number)

			if(presenter.abn_number)
				contact.tax_number = presenter.abn_number
			end
			contact.save
		rescue Xeroizer::ApiException => e
			return e.message
		end
		return true
	end

		# update a school Xero contact
	def self.update_school_account(customer)
		if customer.nil?
			return false
		end
		begin
			dept = ""
			if customer.department
				dept = customer.department 
			end
			gateway = connect

			if !gateway
				return false
			end
			
			contact = gateway.Contact.all(:where => {:contact_id => customer.user.accounting_ref.to_s}).first

			if contact.nil?
				add_school_account(customer)
			end

			contact.name = "#{customer.school_info.school_name} #{dept}"
			contact.first_name = customer.first_name
			contact.last_name = customer.last_name
			contact.email_address = customer.user.email
			# contact.account_number = customer.user.accounting_ref
			contact.add_phone(:type => 'DEFAULT', :number => customer.phone_number)

			contact.save
		rescue Xeroizer::ApiException => e
			return e.message
		end
		return true
	end

	# Get invoices from the accounting system for view. 
	def self.get_invoices(user)
		gateway = connect
		
		if !gateway
			return []
		end

		if user.accounting_ref.nil?
			if user.customer? 
				add_school_account(user.customer)
			else
			 add_presenter_account(user.presenter)
			end

			# if it is still nil, there is a xero issue. 
			if user.accounting_ref.nil?
				return []
			end
		end
		
		account = gateway.Contact.all(:where =>{:contact_id => user.accounting_ref}).first
		# 'Contact.ContactID.ToString()=="cd09aa49-134d-40fb-a52b-b63c6a91d712"'
		search = 'Contact.ContactID.ToString() == "' + user.accounting_ref + '"'
		x=  gateway.Invoice.all(:where => search)
		return x
		# return x.reject{|i| i.status != "AUTHORISED"  || i.status != "PAID"}
		
	end

	# Generate invoices for all parties involved in a booking.
	def self.invoice_booking(booking)
		gateway = connect
		if !gateway
			return false
		end

		pay_presenter(booking, gateway)

		unless booking.shared?
			charge_school(booking, gateway, booking.creator, 100)
		else
			# Calculate each schools share and bill them
			total = booking.total_students.to_f
			booking.booked_customers.each do |school|
				charge_school(booking, gateway, school.customer, (school.number_students.to_f / total * 100).ceil)
			end
		end
		return true
	end

	# Bill a school based on contribution
	def self.charge_school(booking, gateway, customer, share)
		if customer.user.accounting_ref.nil?
			add_school_account(customer)
		end
		billable_minutes = booking.duration_minutes.to_f / 100 * share
		account = gateway.Contact.all(:where =>{:contact_id => customer.user.accounting_ref}).first

		inv = gateway.Invoice.build(:contact => account, :line_amount_types => "Exclusive")

		inv.type = "ACCREC"
		inv.date = booking.booking_date
		inv.reference = booking.id.to_s
		inv.status = "DRAFT"

		inv.add_line_item({
      :description => "#{booking.subject.name} revision session",
      :item_code => PRESENTER_RATE,
      :unit_amount => booking.rate.to_f,
      :quantity => (billable_minutes / 60).to_f,
      # :tax_type => "INPUT"
    })

    inv.add_line_item({
    	:item_code => SERVICE_FEE,
    	:quantity => 1
    	})
    inv.save
	end	

	# Create a Xero bill (Accounts Payable) to credit the presenter their rate
	def self.pay_presenter(booking, gateway)
		if booking.chosen_presenter.user.accounting_ref.nil?
			add_presenter_account(booking.chosen_presenter)
		end
		presenter_account = gateway.Contact.all(:where => {:contact_id => booking.chosen_presenter.user.accounting_ref.to_s}).first

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
		p_inv.save
    return p_inv
	end

	def self.connect
		if Figaro.env.xero_consumer.nil? || Figaro.env.xero_secret.nil? || Figaro.env.xero_cert_location.nil?
			return false
		end
		return Xeroizer::PrivateApplication.new(Figaro.env.xero_consumer, Figaro.env.xero_secret, Figaro.env.xero_cert_location)
	end

end