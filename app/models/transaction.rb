class Transaction < ApplicationRecord
  # Disable Single Table Inheritance
  self.inheritance_column = :_type_disabled
  
  belongs_to :user
  
  # Validations
  validates :type, presence: true, inclusion: { in: %w[income expense] }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :transaction_date, presence: true
  
  # Scopes (shortcuts for common queries)
  scope :income, -> { where(type: 'income') }
  scope :expense, -> { where(type: 'expense') }
  scope :recent, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :by_date_range, ->(start_date, end_date) { 
    where(transaction_date: start_date..end_date) 
  }
  scope :by_category, ->(category) { where(category: category) }
  scope :this_month, -> { 
    where(transaction_date: Date.current.beginning_of_month..Date.current.end_of_month) 
  }
  
  # Helper methods
  def income?
    type == 'income'
  end
  
  def expense?
    type == 'expense'
  end
end