class User < ApplicationRecord
  has_secure_password
  
  #One-to-many relationship with transactions: one user can have many transactions and deleting a user will also delete their transactions.
  has_many :transactions, dependent: :destroy 

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: :password_required?
  
  before_save :normalize_email
  
  scope :verified, -> { where(email_verified: true) }
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end
  
  def reset_password_token_valid?
    reset_password_sent_at && reset_password_sent_at > 2.hours.ago
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def password_required?
    password_digest.blank? || password.present?
  end
end
