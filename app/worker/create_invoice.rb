class CreateInvoice
  @queue = :invoice_queue
  # Background job for invoicing a booking
  def self.perform(booking_id)
    booking = Booking.find(booking_id)
    if booking.chosen_presenter.present?
	    unless booking.invoice!
	    	Notification.notify_admin("Something went wrong with with the invoicing for booking ##{booking_id}", booking_path(@booking), :invoice_fail)
	    end
	  end

	end
end