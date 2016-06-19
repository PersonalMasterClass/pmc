class CreateInvoice
  @queue = :invoice_queue
  def self.perform(booking_id)
    booking = Booking.find(booking_id)
    booking.invoice!
	end
end