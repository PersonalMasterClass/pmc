class CreateInvoice
  @queue = :invoice_queue
  def self.perform(booking_id)
    booking = Booking.find(booking_id)
    unless booking.invoice!
    	Notification.notify_admin("Something went wrong with with the invoicing for booking ##{booking_id}", booking_path(@booking), :invoice_fail)
    end

	end
end