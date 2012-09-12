class Subscriber
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  has_and_belongs_to_many :users

  devise :database_authenticatable,
         :recoverable,
         :registerable,
         :validatable,
         :timeoutable,
         :token_authenticatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email, :encrypted_password
  validates_uniqueness_of :email
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Trackable
  # field :sign_in_count,      :type => Integer, :default => 0
  # field :current_sign_in_at, :type => Time
  # field :last_sign_in_at,    :type => Time
  # field :current_sign_in_ip, :type => String
  # field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

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
