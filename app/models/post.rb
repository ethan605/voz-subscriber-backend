class Post
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  belongs_to :user

  field :postid, type: Integer
  field :post_date, type: Time
  field :title
  field :spoiler

  validates_presence_of :postid, :title
  validates_uniqueness_of :postid

  search_in :title, :spoiler

  scope :postid, ->(_postid) { return self.where(postid: _postid) }
  scope :user_ids, ->(_user_ids) { return self.in(user_id: _user_ids ) }
  scope :search, ->(_search) {
    return self.full_text_search(_search, allow_empty_search: true)
  }

  json_fields \
    username: { definition: :post_user },
  	title: { },
  	spoiler: { },
    post_date: { definition: :post_date_rfc },
  	url: { definition: :url_for_postid }

  def self.crawl(userid)
  	Crawler::PostsCrawler.new.crawl(userid)
  end

  def post_date_rfc
    return self.post_date.rfc822
  end

  def post_user
    return User.find(user_id).username
  end

  def url_for_postid
  	return "http://vozforums.com/showthread.php?p=#{postid}"
  end
end
