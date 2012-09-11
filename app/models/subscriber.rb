class Subscriber
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  has_and_belongs_to_many :users

  field :email
  field :password

  validates_presence_of :email, :password
  validates_uniqueness_of :email

  search_in :email

  scope :email, ->(_email) { return self.where(email: _email) }
  scope :search, ->(_email) {
    return self.full_text_search(_email, allow_empty_search: true)
  }

  json_fields \
  	id: { },
  	email: { },
  	subscribed_users: { definition: :subscribed_users }

  def subscribed_users
  	return users.as_json
  end

  def subscribed_posts
    return nil if users.count == 0
    user_ids = []
    users.each { |u| user_ids << u.id }
    return Post.user_ids(user_ids)
  end
end
