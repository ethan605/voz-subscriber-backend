class Subscriber
  include Mongoid::Document
  include Mongoid::CachedJson
  include Mongoid::Search

  HASH_CONVERTER = {
    '[\[\]{},\s\\"=\>]+' => '|',
    '(^\||\|$)' => ''
  }

  has_and_belongs_to_many :users

  devise :database_authenticatable,
         :registerable,
         :validatable

  # Database authenticatable
  field :email
  field :encrypted_password
  field :private_key

  validates_presence_of :email, :encrypted_password
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

  def self.convert_params(params)
    return nil unless params

    message = params.to_s
    HASH_CONVERTER.each do |k, v|
      message.gsub!(/#{k}/, v)
    end

    return message
  end

  # Overriden save
  def save
    self.private_key = Digest::SHA2.new.update(self.email).to_s
    super
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
