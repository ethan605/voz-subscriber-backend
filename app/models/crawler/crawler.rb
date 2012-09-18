class Crawler::Crawler
	# Mechanize agent for loggin in forums
	@@auth_agent = nil

	# Thread safe mutex for user crawling
	@@current_crawling_userids = []

	attr_reader :mutex

	def self.mutex
		return @@current_crawling_userids
	end

	def bind_mutex(userid)
		@@current_crawling_userids << userid
		puts "mutex = #{@@current_crawling_userids}"
	end

	def release_mutex(userid)
		puts "release mutex binding with #{userid}"
		@@current_crawling_userids - [userid]
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