class Budget < ApplicationRecord
  belongs_to :user
  has_many :budget_alerts, dependent: :destroy

  PERIODS = %w[weekly monthly quarterly yearly custom].freeze

  validates :category, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :period, presence: true, inclusion: { in: PERIODS }
  validates :start_date, presence: true
  validates :alert_threshold, numericality: { 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100 
  }
  
  validate :end_date_after_start_date

  scope :active, -> { where(is_active: true) }
  scope :by_period, ->(period) { where(period: period) }
  scope :by_category, ->(category) { where(category: category) }

  # Calculate spent amount for this budget period
  def spent
    @spent ||= calculate_spent
  end

  # Calculate remaining amount
  def remaining
    amount - spent
  end

  # Calculate percentage used
  def percentage_used
    return 0 if amount.zero?
    (spent / amount * 100).round(2)
  end

  # Check if budget is exceeded
  def exceeded?
    spent > amount
  end

  # Get effective end date based on period
  def effective_end_date
    return end_date if end_date.present?
    
    case period
    when 'weekly'
      start_date + 7.days
    when 'monthly'
      start_date + 1.month
    when 'quarterly'
      start_date + 3.months
    when 'yearly'
      start_date + 1.year
    else
      start_date + 1.month
    end
  end

  private

  def calculate_spent
    user.transactions
        .expense
        .where(category: category)
        .where('transaction_date >= ? AND transaction_date <= ?', 
               start_date, effective_end_date)
        .sum(:amount)
  end

  def end_date_after_start_date
    if end_date.present? && end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
