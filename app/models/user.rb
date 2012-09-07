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

	scope :userid, ->(_userid) { return where(userid: _userid) }
	scope :search, ->(_username) { return full_text_search(_username, allow_empty_search: true) }

	json_fields \
		userid: { },
		username: { }

	search_in :username

	def self.crawl(from = 1, range = 10)
		from.upto(from+range) do |i|
			Crawler::UsersCrawler.new.crawl(i)
		end
	end

	def posts_json
		return posts.as_json
	end

	def full_json
		return {
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
