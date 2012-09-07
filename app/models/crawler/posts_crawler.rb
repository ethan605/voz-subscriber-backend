class Crawler::PostsCrawler < Crawler::Crawler
	# Override method
	def crawl(userid)
		puts "Crawling posts with userid #{userid}\n"

		agent = Crawler::Crawler.login
		url = 'http://vozforums.com/search.php?do=finduser&u='
		page = agent.get(url + "#{userid}")

		# In case of no post found with this userid
		return if (page.content.include?("Sorry - no matches. Please try some different terms."))

		doc = Nokogiri::HTML(page.content)
		info = doc.css('.pagenav .tborder .alt1 .smallfont')
		page_count = (info.count > 0) ? info.last[:href][/&page=[0-9]+/][/[0-9]+/].to_i : 1
		url = page.uri.to_s + '&page='

		1.upto(page_count) do |i|
			puts "Crawling posts with url: " + url + "#{i}\n\n"
			
			page = agent.get(url + "#{i}")
			doc = Nokogiri::HTML(page.content)
			results = doc.css('#inlinemodform').first
			results.css('.tborder .alt2 .smallfont a').each do |a|
				postid = a[:href][/#[^#]*/][/[0-9]+/].to_i
				
				break if postid < Post.max_postid
				
				post = Post.find_or_initialize_by(postid: postid)
				post.title = a.text
				post.spoiler = a.next.next.next.text
				post.spoiler = post.spoiler.gsub(/[\r\t\n]/, '').strip
				post.user_id = User.userid(userid).first._id
				post.save
			end
		end
	end
end