class User
  include Mongoid::Document
  include Mongoid::CachedJson

  field :userid, type: Integer
  field :username
  field :title
  field :location
  field :signature
  field :join_date
  
  has_many :posts

  scope :userid, ->(_userid) { where(userid: _userid) }

  validates_presence_of :userid, :username
  validates_uniqueness_of :userid

  json_fields \
  	userid: { },
  	username: { },
    total_posts: { definition: :posts_count }

  def self.crawl(from = 1055511, to = 1055512)
    from.upto(to) do |i|
      Crawler::UsersCrawler.new.crawl(i)
    end
  end

  def posts_count
    post_ids.count
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
    }
  end
end
