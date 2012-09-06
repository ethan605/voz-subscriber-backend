module Voz::Crawl::Authentication
	extend ActiveSupport::Concern

	def self.login(username = 'enolC', password = 'dracula')
    agent = Mechanize.new
    url = 'http://vozforums.com/'
    page = agent.get url
    login_form = page.form_with action: 'login.php?do=login'
    login_form.field_with(name: 'vb_login_username').value = username
    login_form.field_with(name: 'vb_login_password').value = password
    result = agent.submit login_form
    if result.content.include?(username)
      puts "Logged in to #{url} using username: #{username}, password: #{password} sucessfully."
    end
    agent
  end
end