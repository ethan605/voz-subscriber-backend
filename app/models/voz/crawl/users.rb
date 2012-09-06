module Voz::Crawl::Users
	extend ActiveSupport::Concern

	included do
		include Voz::Crawl::Authentication
	end

	module ClassMethods
		def crawl_users(userid = 1055511, pages = 10)
			agent = Voz::Crawl::Authentication.login
  		page = agent.get("http://vozforums.com/search.php?do=finduser&u=#{userid}")
  		url = page.uri.to_s + '&page='

  		1.upto(pages) do |i|
  			page = agent.get(url + "#{i}")
  			puts url + "#{i}"
	  		doc = Nokogiri::HTML(page.content)
	  		search_results = doc.css('#inlinemodform').first
	  		search_results.css('.tborder .alt2 .smallfont a').each do |a|
	  			puts a[:href][/#[^#]*/][/[0-9]+/]
	  		end
  		end
		end
	end
end