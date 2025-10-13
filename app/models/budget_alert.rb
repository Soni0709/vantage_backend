class BudgetAlert < ApplicationRecord
  belongs_to :budget

  ALERT_TYPES = %w[threshold_reached budget_exceeded near_limit].freeze
  SEVERITIES = %w[info warning error].freeze

  validates :alert_type, inclusion: { in: ALERT_TYPES }
  validates :severity, inclusion: { in: SEVERITIES }
  validates :message, presence: true

  scope :unread, -> { where(is_read: false) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update(is_read: true)
  end

  def acknowledge!
    update(is_acknowledged: true, is_read: true)
  end
end
