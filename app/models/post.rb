class Post
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  belongs_to :user

  field :postid, type: Integer
  field :title
  field :spoiler

  validates_presence_of :postid, :title
  validates_uniqueness_of :postid

  search_in :title, :spoiler

  scope :search, ->(_search) { full_text_search(_search, allow_empty_search: true) }

  json_fields \
  	title: { },
  	spoiler: { },
  	url: { definition: :url_for_postid }

  def self.crawl(userid)
  	Crawler::PostsCrawler.new.crawl(userid)
  end

  def self.max_postid
    max_post = Post.all.order_by([[:postid, :desc]]).first
    
    return max_post.postid if max_post
    return 0
  end

  def url_for_postid
  	return "http://vozforums.com/showthread.php?p=#{postid}"
  end
end
