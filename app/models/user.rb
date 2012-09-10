class User
	include Mongoid::Document
	include Mongoid::CachedJson
	include Mongoid::Search
	
	@@request_host = "http://localhost:3000"
	attr_reader :request_host

	field :userid, type: Integer
	field :username
	field :title
	field :location
	field :signature
	field :join_date
	
	validates_presence_of :userid, :username
	validates_uniqueness_of :userid
	
	has_many :posts
	has_and_belongs_to_many :subscribers

	scope :userid, ->(_userid) { return where(userid: _userid) }
	scope :search, ->(_username) { return full_text_search(_username, allow_empty_search: true) }

	json_fields \
		userid: { },
		username: { },
		posts_url: { definition: :posts_url }

	search_in :username

	def self.crawl(from = 1, range = 10)
		from.upto(from+range) do |i|
			Crawler::UsersCrawler.new.crawl(i)
		end
	end

	def self.request_host
		return @@request_host
	end

	def self.request_host=(_request_host = "http://localrequest_host:3000")
		@@request_host = _request_host
	end

	def posts_url
		return "#{@@request_host}/voz/posts?userid=#{userid}"
	end

	def full_json
		return {
			userid: userid,
			username: username,
			title: title,
			location: location,
			signature: signature,
			join_date: join_date,
			total_posts: post_ids.count,
			posts_url: posts_url
		}
	end
end
