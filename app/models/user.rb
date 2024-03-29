class User < ActiveRecord::Base
#  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password
  
  has_many :microposts, :dependent => :destroy
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships #:source => :follower
  
  
  email_regex = /\A[\w\+\-\.]+@[a-z\d\-\.]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
    :length => {:maximum => 50}
  validates :email, :presence => true,
    :format => {:with => email_regex},
    :uniqueness => {:case_sensitive => false}
  validates :password,
#    :presence => true,
#    :confirmation => true,
    :length => {:within => 6..40}

#  before_save :encrypt_password
  
  
  def has_password?(submitted_password)
    !!authenticate(submitted_password)
#    encrypt(submitted_password) == encrypted_password
  end
  
  # return user given email and password.
  # return nil, if email or password isn't right
  def self.authenticate(email, password)
    (user = find_by_email(email)) && user.authenticate(password) ? user : nil
  end

#  def self.authenticate_with_salt(id, cookie_salt)
#    user = find_by_id(id)
#    (user && user.salt == cookie_salt) ? user : nil
#  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  private

=begin  
    def encrypt_password
      self.salt = make_salt() if new_record?
      self.encrypted_password = encrypt(password)
    end
  
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
=end
end
# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  admin           :boolean         default(FALSE)
#  password_digest :string(255)
#

