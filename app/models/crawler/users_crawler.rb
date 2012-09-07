class Crawler::UsersCrawler < Crawler::Crawler
	# Override method
	def crawl(userid)
		puts "\n\nCrawling user with id #{userid}"

		@@auth_agent = Crawler::Crawler.login if !@@auth_agent
		@url = 'http://vozforums.com/member.php?u='

		begin
			perform_crawler(userid)
		rescue Mechanize::ResponseCodeError => e
			puts "#{e}"
			return
		end
	end

	def perform_crawler(userid)
		puts "Crawling users with url: #{@url}#{userid}"
		page = @@auth_agent.get("#{@url}#{userid}")
		doc = Nokogiri::HTML(page.content)

		user = User.find_or_initialize_by(userid: userid)

		info = doc.css('#main_userinfo table').first
		user.username = info.css('h1').text.strip
		user.title = info.css('h2').text.strip

		info = doc.css('#collapseobj_aboutme .alt1 .profilefield_category dl dd')
		user.location = (info.count > 0) ? info.first.text.strip : '<no location>'
		user.signature = (info.count > 0) ? info.last.text.strip : '<no signature>'

		info = doc.css('#collapseobj_stats_mini .alt1 dl dd')

		info = info.at(info.count-2)
		user.join_date = info.text

		user.save

		puts "crawled user: #{user.username} id: #{user.userid}"
		Crawler::PostsCrawler.new.crawl(userid)
	end
end