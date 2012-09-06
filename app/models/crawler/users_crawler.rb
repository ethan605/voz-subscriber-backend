class Crawler::UsersCrawler < Crawler::Crawler
	# Override method
	def crawl(userid)
		puts "Crawling user with id #{userid}"

		agent = Crawler::Crawler.login
		url = 'http://vozforums.com/member.php?u='

		page = agent.get(url + "#{userid}")
		puts "Crawling users with url: #{url}#{userid}"
		doc = Nokogiri::HTML(page.content)

		user = User.find_or_initialize_by(userid: userid)

		info = doc.css('#main_userinfo table').first
		user.username = info.css('h1').text.strip
		user.title = info.css('h2').text.strip

		info = doc.css('#collapseobj_aboutme .alt1 .profilefield_category dl dd')
		user.location = (info.count > 0) ? info.first.text.strip : '<no location>'
		user.signature = (info.count > 0) ? info.last.text.strip : '<no signature>'

		info = doc.css('#collapseobj_stats_mini .alt1 dl dd')

		if info.count == 2
			info = info.first
		else
			if info.count == 3
				info = info.at(1)
			end
		end

		user.join_date = info.text

		user.save

		Crawler::PostsCrawler.new.crawl(userid)
	end
end