class User
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  field :userid, type: Integer
  field :username
  field :title
  field :location
  field :signature
  field :join_date
  
  validates_presence_of :userid, :username
  validates_uniqueness_of :userid
  
  has_many :posts

  scope :userid, ->(_userid) { where(userid: _userid) }

  json_fields \
  	userid: { },
  	username: { }

  search_in :username

  def self.crawl(from = 1, to = 9999)
    from.upto(to) do |i|
      Crawler::UsersCrawler.new.crawl(i)
    end
  end

  def posts_json
    posts.as_json
  end

  def full_json
    {
      userid: userid,
      username: username,
      title: title,
      location: location,
      signature: signature,
      join_date: join_date,
      total_posts: post_ids.count
    }
  end
end
