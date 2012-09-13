class Subscriber
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  AUTH_EXPIRE_TIME = 30.minutes

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

  field :auth_expire_date, type: Time, default: ->{ AUTH_EXPIRE_TIME.from_now }

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
    auth_expire_date: { definition: :auth_expire_date_rfc },
  	subscribed_users: { definition: :subscribed_users }

  # Override method
  def reset_authentication_token!
    self.auth_expire_date = AUTH_EXPIRE_TIME.from_now
    super
  end

  def auth_token
    return self.authentication_token
  end

  def validate_authentication?(auth_token)
    # binding.pry
    return auth_token == self.authentication_token &&
           self.auth_expire_date > Time.now
  end

  def auth_expire_date_rfc
    return self.auth_expire_date.rfc822
  end

  def subscribed_users
  	return users.as_json
  end

  def subscribed_posts
    return nil if self.users.count == 0
    user_ids_array = []
    self.users.each { |u| user_ids_array << u.id }
    return Post.user_ids(user_ids_array)
  end
end
