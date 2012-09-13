class Crawler::PostsCrawler < Crawler::Crawler
  # Override method
  def crawl(userid)
    puts "\nCrawling posts with userid #{userid}"

    # Bind mutex with current crawling userid
    bind_mutex(userid)

    @@auth_agent = Crawler::Crawler.login if !@@auth_agent
    @url = 'http://vozforums.com/search.php?do=finduser&u='
    @user_db_id = User.userid(userid).first.id
    
    ensure_authen do
      page = @@auth_agent.get("#{@url}#{userid}")

      # In case of no post found with this userid
      if (page.content.include?('Sorry - no matches. Please try some different terms.'))
        release_mutex
        return
      end

      doc = Nokogiri::HTML(page.content)
      info = doc.css('.pagenav .tborder .alt1 .smallfont')
      page_count = (info.count > 0) ? info.last[:href][/&page=[0-9]+/][/[0-9]+/].to_i : 1
      @url = "#{page.uri}&page="

      1.upto(page_count) do |i|
        ensure_authen do
          puts "Crawling posts with url: #{@url}#{i}"
          perform_crawler(i, userid)
        end
      end
    end

    release_mutex
  end

  def perform_crawler(index, userid)
    page = @@auth_agent.get("#{@url}#{index}")

    # If Mechanize agent's cookie or search session is expired
    if page.content.include?('You are not logged in') ||
       page.content.include?('Sorry - no matches. Please try some different terms.')
      @@auth_agent = Crawler::Crawler.login
      page = @@auth_agent.get("#{@url}#{userid}")
      page = @@auth_agent.get("#{page.uri}&page=#{index}")
    end

    retrieve_data_from_page(page)

  end

  def retrieve_data_from_page(page)
    doc = Nokogiri::HTML(page.content)
    results = doc.css('#inlinemodform').first

    post_dates = []
    results.css('.tborder .thead .inlineimg').each do |a|
      post_date_str = a.next.text.strip
      
      begin
        post_date = post_date_str.to_time
      rescue ArgumentError => e
        post_date = Time.now if post_date_str.include?('Today')
        post_date = Time.now - 1.day if post_date_str.include?('Yesterday')
        post_time = post_date_str[/[:0-9]+/].split(':').map! {|x| x.to_i}
        post_date.change(hour: post_time[0], min: post_time[1])
      end

      post_dates << post_date
    end

    results.css('.tborder .alt2 .smallfont a').each_with_index do |a, i|
      postid = a[:href][/#[^#]*/][/[0-9]+/].to_i

      next if Post.postid(postid).count > 0

      post = Post.find_or_initialize_by(postid: postid)
      post.post_date = post_dates[i]
      post.title = a.text
      post.spoiler = a.next.next.next.text
      post.spoiler = post.spoiler.gsub(/[\r\t\n]/, '').strip
      post.user_id = @user_db_id
      post.save
    end
  end
end