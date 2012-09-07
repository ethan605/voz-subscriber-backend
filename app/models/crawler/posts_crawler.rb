class Crawler::PostsCrawler < Crawler::Crawler
	# Override method
	def crawl(userid)
		puts "Crawling posts with userid #{userid}"

		agent = Crawler::Crawler.login
		url = 'http://vozforums.com/search.php?do=finduser&u='
		page = agent.get(url + "#{userid}")

		# In case of no post found with this userid
		return if (page.content.include?("Sorry - no matches. Please try some different terms."))

		doc = Nokogiri::HTML(page.content)
		info = doc.css('.pagenav .tborder .alt1 .smallfont')
		page_count = (info.count > 0) ? info.last[:href][/&page=[0-9]+/][/[0-9]+/].to_i : 1
		url = page.uri.to_s + '&page='

		1.upto(1) do |i|
			page = agent.get(url + "#{i}")
			puts "Crawling posts with url: " + url + "#{i}"
			doc = Nokogiri::HTML(page.content)
			search_results = doc.css('#inlinemodform').first
			search_results.css('.tborder .alt2 .smallfont a').each do |a|
				post = Post.find_or_initialize_by(postid: a[:href][/#[^#]*/][/[0-9]+/])
				post.title = a.text
				post.spoiler = a.next.next.next.text
				post.spoiler = post.spoiler.gsub(/[\r\t\n]/, '').strip
				post.user_id = User.userid(userid).first._id
				post.save
			end
		end
	end
end