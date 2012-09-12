xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title 'Voz Subscriber RSS Feeds'
    xml.description "RSS Feeds for #{@feed_ref}"
    xml.link @feed_url
    xml.pubDate Time.now.rfc822

    if @posts
      for post in @posts
        xml.item do
          xml.userid        post.user.userid
          xml.title         "[#{post.user.username}] #{post.title}"
          xml.description   post.spoiler
          xml.pubDate       post.post_date.rfc822
          xml.link          post.url_for_postid
        end
      end
    end
  end
end