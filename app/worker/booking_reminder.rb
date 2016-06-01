# Send out a reminder to all users who are interested in this booking:
# 1. Customers who are subscribed to the subject
# 2. Presenters who teach the subject
# Only send notifications to customers if the booking is shared
# Only send notifications to presenters if the booking is open (no presenter has been chosen)
class BookingReminder
  @queue = :booking_reminder_queue
  def self.perform(booking_id)
    @booking = Booking.find(booking_id)
    @message = "Cut off to apply for a #{@booking.subject.name} booking is ending in #{@booking.period} days."
		if @booking.shared?
      Notification.notify_applicable_users(@booking.creator, @booking, "customer", booking_path(@booking), @message)
    end
    if @booking.chosen_presenter.nil?
    	Notification.notify_applicable_users(@booking.creator, @booking, "presenter", booking_path(@booking), @message)
    end
	end
end