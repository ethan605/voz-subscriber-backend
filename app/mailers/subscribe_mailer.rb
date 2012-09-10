class SubscribeMailer < ActionMailer::Base
	default from: "subscribe@voz.subscri.be"

	def welcome_email(subscriber)
		mail(to: subscriber.email, subject: 'Welcome to Voz Subscriber')
	end
end
