xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title 'Voz Subscriber RSS Feeds'
    xml.description "RSS Feeds for #{@feed_ref}"
    xml.link @feed_url
    xml.pubDate Time.now.rfc822

    for post in @posts
      xml.item do
        xml.title         post.title
        xml.description   "[#{post.user.username}] #{post.spoiler}"
        xml.pubDate       post.post_date.rfc822
        xml.link          post.url_for_postid
      end
    end
  end
end