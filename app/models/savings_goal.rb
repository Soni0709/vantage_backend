class SavingsGoal < ApplicationRecord
  belongs_to :user

  STATUSES = %w[active completed paused].freeze

  validates :name, presence: true
  validates :target_amount, presence: true, numericality: { greater_than: 0 }
  validates :current_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :paused, -> { where(status: 'paused') }

  # Calculate progress percentage
  def progress_percentage
    return 0 if target_amount.zero?
    ((current_amount / target_amount) * 100).round(2)
  end

  # Calculate remaining amount
  def remaining_amount
    target_amount - current_amount
  end

  # Check if goal is reached
  def reached?
    current_amount >= target_amount
  end

  # Add amount to savings
  def add_amount(amount)
    self.current_amount += amount
    self.status = 'completed' if reached?
    save
  end

  # Check if deadline passed
  def overdue?
    deadline.present? && deadline < Date.current && !reached?
  end
end
