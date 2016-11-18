class Lender < ActiveRecord::Base
  has_secure_password
  before_save do
    self.email.downcase!
  end
  validates :first_name, :last_name, presence: true
  validates :money, numericality: { greater_than: 0 }
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
  validates :email, presence: true, format: { with: EMAIL_REGEX }
  # validates :email_may_not_be_used
  has_many :histories
  has_many :borrowers, through: :histories
  def email_may_not_be_used
    email.downcase!
    if Borrower.find_by_email(email) || Lender.find_by_email(email)
      errors.add(:email, "has already been taken")
    end
  end
end
