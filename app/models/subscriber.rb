class Subscriber
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  before_save :ensure_authentication_token

  has_and_belongs_to_many :users

  devise :database_authenticatable,
         :registerable,
         :validatable,
         :token_authenticatable

  # Database authenticatable
  field :email
  field :encrypted_password

  validates_presence_of :email, :encrypted_password
  validates_uniqueness_of :email

  field :last_sign_in, type: Time

  ## Token authenticable
  field :authentication_token

  search_in :email

  scope :email, ->(_email) { return self.where(email: _email) }
  scope :search, ->(_email) {
    return self.full_text_search(_email, allow_empty_search: true)
  }

  json_fields \
    id: { },
  	email: { },
    auth_token: { definition: :auth_token },
  	subscribed_users: { definition: :subscribed_users }

  def auth_token
    return authentication_token
  end

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
