class Post
  include Mongoid::Document
  include Mongoid::CachedJson

  belongs_to :user

  field :postid, type: Integer
  field :title
  field :spoiler

  validates_presence_of :postid, :title
  validates_uniqueness_of :postid

  json_fields \
  	title: { },
  	spoiler: { },
  	url: { definition: :url_for_postid }

  def self.crawl(userid)
  	Crawler::PostsCrawler.new.crawl(userid)
  end

  def url_for_postid
  	"http://vozforums.com/showthread.php?p=#{postid}"
  end
end
