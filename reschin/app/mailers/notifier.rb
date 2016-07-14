# app/mailers/notifier.rb
class Notifier < ActionMailer::Base

  include SendGrid

  default from: 'info@reschin.com'

  def new_restaurant_notifier(user, restaurant)
    sendgrid_category "New Restaurant Notifier"

    @user = user
    @restaurant = restaurant

    mail to: user.email, subject: "Welcome to our books online store"
  end

end
