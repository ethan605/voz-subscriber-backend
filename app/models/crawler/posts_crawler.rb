class Crawler::PostsCrawler < Crawler::Crawler
	# Override method
	def crawl(userid)
		puts "\nCrawling posts with userid #{userid}"

		@@auth_agent = Crawler::Crawler.login if !@@auth_agent
		@url = 'http://vozforums.com/search.php?do=finduser&u='
		@user_db_id = User.userid(userid).first._id
		
		ensure_authen do
			page = @@auth_agent.get("#{@url}#{userid}")

			# In case of no post found with this userid
			return if (page.content.include?("Sorry - no matches. Please try some different terms."))

			doc = Nokogiri::HTML(page.content)
			info = doc.css('.pagenav .tborder .alt1 .smallfont')
			page_count = (info.count > 0) ? info.last[:href][/&page=[0-9]+/][/[0-9]+/].to_i : 1
			@url = "#{page.uri}&page="

			1.upto(page_count) do |i|
				puts "Crawling posts with url: #{@url}#{i}"
				
				ensure_authen do
					perform_crawler(i, userid)
				end
			end
		end
	end

	def perform_crawler(index, userid)
		page = @@auth_agent.get("#{@url}#{index}")

		if page.content.include?('You are not logged in')
			@@auth_agent = Crawler::Crawler.login
			page = @@auth_agent.get("#{@url}#{userid}")
		end

		doc = Nokogiri::HTML(page.content)
		results = doc.css('#inlinemodform').first
		begin
			results.css('.tborder .alt2 .smallfont a').each do |a|
				postid = a[:href][/#[^#]*/][/[0-9]+/].to_i
				post = Post.find_or_initialize_by(postid: postid)
				post.title = a.text
				post.spoiler = a.next.next.next.text
				post.spoiler = post.spoiler.gsub(/[\r\t\n]/, '').strip
				post.user_id = @user_db_id
				post.save
			end
		rescue NoMethodError => e
			puts "#{e}"
			return
		end
	end
end