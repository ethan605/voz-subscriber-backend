class Voz::User
  include Mongoid::Document
  include Mongoid::CachedJson

  include Voz::Crawl

  field :vozid, type: Integer
  field :username

  scope :vozid, ->(x) { where(vozid: x) }

  validates_presence_of :vozid, :username
  validates_uniqueness_of :vozid

  json_fields \
  	vozid: { },
  	username: { }
end
