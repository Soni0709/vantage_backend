class RecurringTransaction < ApplicationRecord
  # Disable Single Table Inheritance (same issue as Transaction model)
  self.inheritance_column = :_type_disabled
  
  belongs_to :user
  
  # Validations
  validates :type, presence: true, inclusion: { in: %w[income expense] }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :frequency, presence: true, inclusion: { 
    in: %w[daily weekly monthly yearly] 
  }
  validates :start_date, presence: true
  validates :next_occurrence, presence: true
  
  # Validate end_date is after start_date if present
  validate :end_date_after_start_date
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :income, -> { where(type: 'income') }
  scope :expense, -> { where(type: 'expense') }
  scope :due, -> { active.where('next_occurrence <= ?', Date.current) }
  scope :upcoming, ->(days = 30) { 
    active.where('next_occurrence BETWEEN ? AND ?', Date.current, Date.current + days.days)
      .order(next_occurrence: :asc)
  }
  
  # Instance methods
  def calculate_next_occurrence
    case frequency
    when 'daily'
      next_occurrence + 1.day
    when 'weekly'
      next_occurrence + 1.week
    when 'monthly'
      next_occurrence + 1.month
    when 'yearly'
      next_occurrence + 1.year
    else
      next_occurrence
    end
  end
  
  def process!
    return false unless is_active && next_occurrence <= Date.current
    
    # Create a regular transaction
    transaction = user.transactions.create!(
      type: self.type,
      amount: amount,
      category: category,
      description: "#{description} (Recurring)",
      transaction_date: Date.current,
      metadata: { recurring_transaction_id: id }
    )
    
    # Update next occurrence
    new_next = calculate_next_occurrence
    
    # Check if we've passed the end date
    if end_date.present? && new_next > end_date
      update!(is_active: false)
    else
      update!(next_occurrence: new_next)
    end
    
    transaction
  end
  
  def toggle_active!
    update!(is_active: !is_active)
  end
  
  private
  
  def end_date_after_start_date
    if end_date.present? && end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
