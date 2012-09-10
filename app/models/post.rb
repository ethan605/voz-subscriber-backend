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

  scope :postid, ->(_postid) { where(postid: _postid) }
  scope :search, ->(_search) { full_text_search(_search, allow_empty_search: true) }

  json_fields \
    username: { definition: :post_user },
  	title: { },
  	spoiler: { },
  	url: { definition: :url_for_postid }

  def self.crawl(userid)
  	Crawler::PostsCrawler.new.crawl(userid)
  end

  def post_user
    return User.find(user_id).username
  end

  def url_for_postid
  	return "http://vozforums.com/showthread.php?p=#{postid}"
  end
end
