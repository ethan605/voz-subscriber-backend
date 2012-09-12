class Crawler::Crawler
	# Mechanize agent for loggin in forums
	@@auth_agent = nil
	attr_reader :auth_agent

	def self.auth_agent
		return @@auth_agent
	end

	def self.auth_agent=(agent = nil)
		@@auth_agent = agent
	end

	# Login forums to search data
	def self.login(username = 'enolC', password = 'dracula')
		@@auth_agent = Mechanize.new
		url = 'http://vozforums.com/'
		page = @@auth_agent.get url
		login_form = page.form_with action: 'login.php?do=login'
		login_form.field_with(name: 'vb_login_username').value = username
		login_form.field_with(name: 'vb_login_password').value = password
		result = @@auth_agent.submit login_form
		
		if result.content.include?(username)
			puts "Logged in to #{url} using username: #{username}, password: #{password} sucessfully."
		end

		return @@auth_agent
	end

	# Method to be overriden
	def crawl
	end

	def ensure_authen
		begin
			yield
		rescue Mechanize::ResponseCodeError => e
			puts "#{e}"
			puts "Waiting 3 seconds to continue"
			sleep(3)
			begin
				yield
			rescue Exception => e
				puts "#{e}"
				puts "Aborted"
			end
		end
	end
end