class Api::V1::SavingsGoalsController < ApplicationController
  before_action :set_savings_goal, only: [:show, :update, :destroy, :add_amount]

  # GET /api/v1/savings_goals
  def index
    @savings_goals = current_user.savings_goals.order(created_at: :desc)
    @savings_goals = @savings_goals.where(status: params[:status]) if params[:status].present?

    render json: {
      success: true,
      message: 'Savings goals retrieved successfully',
      data: {
        savings_goals: @savings_goals.map { |sg| serialize_savings_goal(sg) }
      }
    }
  end

  # GET /api/v1/savings_goals/:id
  def show
    render json: {
      success: true,
      message: 'Savings goal retrieved successfully',
      data: {
        savings_goal: serialize_savings_goal(@savings_goal)
      }
    }
  end

  # POST /api/v1/savings_goals
  def create
    @savings_goal = current_user.savings_goals.new(savings_goal_params)

    if @savings_goal.save
      render json: {
        success: true,
        message: 'Savings goal created successfully',
        data: {
          savings_goal: serialize_savings_goal(@savings_goal)
        }
      }, status: :created
    else
      render_error(@savings_goal.errors.full_messages, 'Failed to create savings goal')
    end
  end

  # PUT /api/v1/savings_goals/:id
  def update
    if @savings_goal.update(savings_goal_params)
      render json: {
        success: true,
        message: 'Savings goal updated successfully',
        data: {
          savings_goal: serialize_savings_goal(@savings_goal)
        }
      }
    else
      render_error(@savings_goal.errors.full_messages, 'Failed to update savings goal')
    end
  end

  # DELETE /api/v1/savings_goals/:id
  def destroy
    @savings_goal.destroy
    render json: {
      success: true,
      message: 'Savings goal deleted successfully'
    }
  end

  # PATCH /api/v1/savings_goals/:id/add_amount
  def add_amount
    amount = params[:amount].to_f

    if amount <= 0
      return render_error(['Amount must be greater than 0'], 'Invalid amount')
    end

    if @savings_goal.add_amount(amount)
      render json: {
        success: true,
        message: 'Amount added successfully',
        data: {
          savings_goal: serialize_savings_goal(@savings_goal)
        }
      }
    else
      render_error(@savings_goal.errors.full_messages, 'Failed to add amount')
    end
  end

  # GET /api/v1/savings_goals/summary
  def summary
    goals = current_user.savings_goals
    
    total_target = goals.sum(:target_amount).to_f
    total_saved = goals.sum(:current_amount).to_f
    total_remaining = total_target - total_saved

    render json: {
      success: true,
      message: 'Savings goals summary retrieved successfully',
      data: {
        total_target: total_target,
        total_saved: total_saved,
        total_remaining: total_remaining,
        overall_progress: total_target > 0 ? ((total_saved / total_target) * 100).round(2) : 0,
        goals_count: goals.count,
        active_count: goals.active.count,
        completed_count: goals.completed.count,
        goals: goals.map { |g| serialize_savings_goal(g) }
      }
    }
  end

  private

  def set_savings_goal
    @savings_goal = current_user.savings_goals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error(['Savings goal not found'], 'Not found', :not_found)
  end

  def savings_goal_params
    params.require(:savings_goal).permit(
      :name, :target_amount, :current_amount, :deadline, :status, :description
    )
  end

  def serialize_savings_goal(goal)
    {
      id: goal.id,
      user_id: goal.user_id,
      name: goal.name,
      target_amount: goal.target_amount.to_f,
      current_amount: goal.current_amount.to_f,
      remaining_amount: goal.remaining_amount.to_f,
      progress_percentage: goal.progress_percentage,
      deadline: goal.deadline,
      status: goal.status,
      description: goal.description,
      is_reached: goal.reached?,
      is_overdue: goal.overdue?,
      created_at: goal.created_at,
      updated_at: goal.updated_at
    }
  end
end
