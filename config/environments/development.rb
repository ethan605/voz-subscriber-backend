VozSubscriberBackend::Application.configure do
	# Settings specified here will take precedence over those in config/application.rb

	# In the development environment your application's code is reloaded on
	# every request. This slows down response time but is perfect for development
	# since you don't have to restart the web server when you make code changes.
	config.cache_classes = false

	# Log error messages when you accidentally call methods on nil.
	config.whiny_nils = true

	# Show full error reports and disable caching
	config.consider_all_requests_local       = true
	config.action_controller.perform_caching = false

	# Print deprecation notices to the Rails logger
	config.active_support.deprecation = :log

	# Only use best-standards-support built into browsers
	config.action_dispatch.best_standards_support = :builtin

	# Do not compress assets
	config.assets.compress = false

	# Expands the lines which load the assets
	config.assets.debug = true

	config.action_mailer.raise_delivery_errors = true

	config.action_mailer.delivery_method = :smtp

	config.action_mailer.default_url_options = {
		:host => 'localhost:3000'
	}

	# config.action_mailer.smtp_settings = {
	# 	address: 				'smtp.google.com',
	# 	port: 					578,
	# 	domain: 				'voz.subscri.be',
	# 	user_name: 			'voz.subscriber@gmail.com',
	# 	password: 			'v0zsubscriber',
	# 	authentication: 'plain',
	# 	enable_starttls_auto: true
	# }

	config.action_mailer.smtp_settings = {
		address: 				'smtp.sendgrid.net',
		port: 					25,
		domain: 				'voz.subscri.be',
		user_name: 			'team@vinova.sg',
		password: 			'vinova01',
		authentication: 'plain'
	}
end
