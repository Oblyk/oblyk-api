# frozen_string_literal: true

class User < ApplicationRecord
  include Geolocable
  include Slugable

  has_secure_password
  has_one_attached :avatar
  has_one_attached :banner
  has_many :follows, as: :followable
  has_many :subscribes, class_name: 'Follow', foreign_key: :user_id
  has_many :conversation_messages
  has_many :conversation_users
  has_many :conversations, through: :conversation_users
  has_many :tick_lists
  has_many :photos
  has_many :gym_administrators
  has_many :gyms, through: :gym_administrators

  validates :first_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, on: :create
  validates :genre, inclusion: { in: %w[male female] }, allow_blank: true
  validates :language, inclusion: { in: %w[fr en] }

  validates :avatar, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def send_reset_password_instructions
    token = SecureRandom.base36
    self.reset_password_token = token
    self.reset_password_token_expired_at = Time.zone.now + 30.minutes
    save!

    UserMailer.with(user: self, token: token).reset_password.deliver_now
  end

  def subscribes_to_a
    json_follows = []
    subscribes.each do |follow|
      json_follows << {
        id: follow.id,
        followable_type: follow.followable_type,
        followable_id: follow.followable_id,
        accepted: follow.accepted?
      }
    end
    json_follows
  end
end
