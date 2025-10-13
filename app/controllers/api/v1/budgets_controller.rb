class Api::V1::BudgetsController < ApplicationController
  before_action :set_budget, only: [:show, :update, :destroy]

  # GET /api/v1/budgets
  def index
    @budgets = current_user.budgets
    @budgets = @budgets.by_category(params[:category]) if params[:category].present?
    @budgets = @budgets.by_period(params[:period]) if params[:period].present?
    @budgets = @budgets.where(is_active: params[:is_active]) if params[:is_active].present?

    render json: {
      success: true,
      message: 'Budgets retrieved successfully',
      data: {
        budgets: @budgets.map { |b| serialize_budget(b) }
      }
    }
  end

  # GET /api/v1/budgets/:id
  def show
    render json: {
      success: true,
      message: 'Budget retrieved successfully',
      data: {
        budget: serialize_budget(@budget)
      }
    }
  end

  # POST /api/v1/budgets
  def create
    @budget = current_user.budgets.new(budget_params)

    if @budget.save
      render json: {
        success: true,
        message: 'Budget created successfully',
        data: {
          budget: serialize_budget(@budget)
        }
      }, status: :created
    else
      render_error(@budget.errors.full_messages, 'Failed to create budget')
    end
  end

  # PUT /api/v1/budgets/:id
  def update
    if @budget.update(budget_params)
      # Check if alert should be triggered
      check_and_create_alerts(@budget)
      
      render json: {
        success: true,
        message: 'Budget updated successfully',
        data: {
          budget: serialize_budget(@budget)
        }
      }
    else
      render_error(@budget.errors.full_messages, 'Failed to update budget')
    end
  end

  # DELETE /api/v1/budgets/:id
  def destroy
    @budget.destroy
    render json: {
      success: true,
      message: 'Budget deleted successfully'
    }
  end

  # GET /api/v1/budgets/summary
  def summary
    budgets = current_user.budgets.active
    
    total_budgeted = budgets.sum(:amount).to_f
    total_spent = budgets.sum(&:spent).to_f
    total_remaining = budgets.sum(&:remaining).to_f
    
    render json: {
      success: true,
      message: 'Budget summary retrieved successfully',
      data: {
        total_budgeted: total_budgeted,
        total_spent: total_spent,
        total_remaining: total_remaining,
        budget_count: budgets.count,
        exceeded_count: budgets.count(&:exceeded?),
        average_utilization: calculate_average_utilization(budgets),
        by_category: budgets.map { |b| serialize_category_summary(b) }
      }
    }
  end

  # GET /api/v1/budgets/alerts
  def alerts
    alerts = BudgetAlert.joins(:budget)
                       .where(budgets: { user_id: current_user.id })
                       .recent

    alerts = alerts.unread if params[:is_read] == 'false'
    alerts = alerts.by_severity(params[:severity]) if params[:severity].present?

    render json: {
      success: true,
      message: 'Budget alerts retrieved successfully',
      data: {
        alerts: alerts.map { |a| serialize_alert(a) }
      }
    }
  end

  # POST /api/v1/budgets/refresh
  def refresh
    # Recalculate all budgets and check for alerts
    current_user.budgets.find_each do |budget|
      budget.reload
      check_and_create_alerts(budget)
    end

    render json: {
      success: true,
      message: 'Budgets refreshed successfully'
    }
  end

  # PATCH /api/v1/budgets/:id/alerts/:alert_id/read
  def mark_alert_read
    alert = BudgetAlert.joins(:budget)
                      .where(budgets: { user_id: current_user.id })
                      .find(params[:alert_id])
    
    alert.mark_as_read!
    
    render json: {
      success: true,
      message: 'Alert marked as read'
    }
  rescue ActiveRecord::RecordNotFound
    render_error(['Alert not found'], 'Not found', :not_found)
  end

  # PATCH /api/v1/budgets/:id/alerts/:alert_id/acknowledge
  def acknowledge_alert
    alert = BudgetAlert.joins(:budget)
                      .where(budgets: { user_id: current_user.id })
                      .find(params[:alert_id])
    
    alert.acknowledge!
    
    render json: {
      success: true,
      message: 'Alert acknowledged'
    }
  rescue ActiveRecord::RecordNotFound
    render_error(['Alert not found'], 'Not found', :not_found)
  end

  private

  def set_budget
    @budget = current_user.budgets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error(['Budget not found'], 'Not found', :not_found)
  end

  def budget_params
    params.require(:budget).permit(
      :category, :amount, :period, :start_date, :end_date,
      :alert_threshold, :alert_enabled, :is_active
    )
  end

  def serialize_budget(budget)
    {
      id: budget.id,
      user_id: budget.user_id,
      category: budget.category,
      amount: budget.amount.to_f,
      period: budget.period,
      start_date: budget.start_date,
      end_date: budget.end_date,
      effective_end_date: budget.effective_end_date,
      spent: budget.spent.to_f,
      remaining: budget.remaining.to_f,
      percentage_used: budget.percentage_used,
      is_exceeded: budget.exceeded?,
      alert_threshold: budget.alert_threshold,
      alert_enabled: budget.alert_enabled,
      is_active: budget.is_active,
      created_at: budget.created_at,
      updated_at: budget.updated_at
    }
  end

  def serialize_category_summary(budget)
    {
      category: budget.category,
      budgeted: budget.amount.to_f,
      spent: budget.spent.to_f,
      remaining: budget.remaining.to_f,
      percentage_used: budget.percentage_used,
      is_exceeded: budget.exceeded?,
      transaction_count: calculate_transaction_count(budget)
    }
  end

  def serialize_alert(alert)
    {
      id: alert.id,
      budget_id: alert.budget_id,
      type: alert.alert_type,
      severity: alert.severity,
      message: alert.message,
      category: alert.budget.category,
      budget_amount: alert.budget_amount&.to_f,
      spent_amount: alert.spent_amount&.to_f,
      percentage_used: alert.percentage_used&.to_f,
      timestamp: alert.created_at,
      is_read: alert.is_read,
      is_acknowledged: alert.is_acknowledged
    }
  end

  def check_and_create_alerts(budget)
    return unless budget.alert_enabled

    percentage = budget.percentage_used

    # Budget exceeded
    if percentage >= 100 && !alert_exists?(budget, 'budget_exceeded')
      create_alert(budget, 'budget_exceeded', 'error')
    # Threshold reached
    elsif percentage >= budget.alert_threshold && !alert_exists?(budget, 'threshold_reached')
      severity = percentage >= 90 ? 'warning' : 'info'
      create_alert(budget, 'threshold_reached', severity)
    end
  end

  def alert_exists?(budget, alert_type)
    budget.budget_alerts.where(alert_type: alert_type).where('created_at > ?', 24.hours.ago).exists?
  end

  def create_alert(budget, alert_type, severity)
    message = case alert_type
    when 'budget_exceeded'
      "Budget for #{budget.category} exceeded! Spent ₹#{budget.spent.to_f} of ₹#{budget.amount.to_f}"
    when 'threshold_reached'
      "Budget for #{budget.category} reached #{budget.percentage_used}%"
    end

    budget.budget_alerts.create!(
      alert_type: alert_type,
      severity: severity,
      message: message,
      budget_amount: budget.amount,
      spent_amount: budget.spent,
      percentage_used: budget.percentage_used
    )
  end

  def calculate_average_utilization(budgets)
    return 0 if budgets.empty?
    (budgets.sum(&:percentage_used) / budgets.count).round(2)
  end

  def calculate_transaction_count(budget)
    current_user.transactions
               .where(type: 'expense', category: budget.category)
               .where('transaction_date >= ? AND transaction_date <= ?',
                     budget.start_date, budget.effective_end_date)
               .count
  end
end
