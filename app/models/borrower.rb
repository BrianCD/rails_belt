class Borrower < ActiveRecord::Base
  has_secure_password
  before_save do
    self.email.downcase!
  end
  validates :first_name, :last_name, :purpose, :description, presence: true
  validates :goal, numericality: { greater_than: 0 }
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
  validates :email, presence: true, format: { with: EMAIL_REGEX }
  validates_each :email, on: :create do |record, name, email|
    record.errors.add(name, "has already been taken") if Borrower.find_by_email(email.downcase) || Lender.find_by_email(email.downcase)
  end
  has_many :histories
  has_many :lenders, through: :histories
  def get_raised
    histories.reduce(0) {|total, loan| total + loan.amount}
  end
end
