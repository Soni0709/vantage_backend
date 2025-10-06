class Api::V1::RecurringTransactionsController < ApplicationController
  before_action :set_recurring_transaction, only: [:show, :update, :destroy, :toggle]
  
  # GET /api/v1/recurring_transactions
  def index
    @recurring_transactions = current_user.recurring_transactions.order(created_at: :desc)
    
    # Apply filters
    @recurring_transactions = @recurring_transactions.where(is_active: params[:is_active]) if params[:is_active].present?
    @recurring_transactions = @recurring_transactions.where(type: params[:type]) if params[:type].present?
    
    render json: {
      success: true,
      message: 'Recurring transactions retrieved successfully',
      data: {
        recurring_transactions: @recurring_transactions.map { |rt| recurring_transaction_response(rt) }
      }
    }
  end
  
  # GET /api/v1/recurring_transactions/upcoming
  def upcoming
    days = params[:days]&.to_i || 30
    @upcoming = current_user.recurring_transactions.upcoming(days)
    
    render json: {
      success: true,
      message: 'Upcoming recurring transactions retrieved',
      data: {
        recurring_transactions: @upcoming.map { |rt| recurring_transaction_response(rt) }
      }
    }
  end
  
  # GET /api/v1/recurring_transactions/:id
  def show
    render json: {
      success: true,
      data: {
        recurring_transaction: recurring_transaction_response(@recurring_transaction)
      }
    }
  end
  
  # POST /api/v1/recurring_transactions
  def create
    @recurring_transaction = current_user.recurring_transactions.new(recurring_transaction_params)
    
    # Set next_occurrence to start_date if not provided
    @recurring_transaction.next_occurrence ||= @recurring_transaction.start_date
    
    if @recurring_transaction.save
      render json: {
        success: true,
        message: 'Recurring transaction created successfully',
        data: {
          recurring_transaction: recurring_transaction_response(@recurring_transaction)
        }
      }, status: :created
    else
      render_error(@recurring_transaction.errors.full_messages, 'Failed to create recurring transaction')
    end
  end
  
  # PUT /api/v1/recurring_transactions/:id
  def update
    if @recurring_transaction.update(recurring_transaction_params)
      render json: {
        success: true,
        message: 'Recurring transaction updated successfully',
        data: {
          recurring_transaction: recurring_transaction_response(@recurring_transaction)
        }
      }
    else
      render_error(@recurring_transaction.errors.full_messages, 'Failed to update')
    end
  end
  
  # DELETE /api/v1/recurring_transactions/:id
  def destroy
    @recurring_transaction.destroy
    render json: {
      success: true,
      message: 'Recurring transaction deleted successfully'
    }
  end
  
  # PATCH /api/v1/recurring_transactions/:id/toggle
  def toggle
    @recurring_transaction.toggle_active!
    render json: {
      success: true,
      message: "Recurring transaction #{@recurring_transaction.is_active? ? 'activated' : 'paused'}",
      data: {
        recurring_transaction: recurring_transaction_response(@recurring_transaction)
      }
    }
  end
  
  # POST /api/v1/recurring_transactions/process_due
  def process_due
    due_transactions = current_user.recurring_transactions.due
    processed = []
    errors = []
    
    due_transactions.each do |rt|
      begin
        transaction = rt.process!
        processed << {
          recurring_transaction_id: rt.id,
          transaction_id: transaction.id,
          amount: transaction.amount
        }
      rescue => e
        errors << {
          recurring_transaction_id: rt.id,
          error: e.message
        }
      end
    end
    
    render json: {
      success: errors.empty?,
      message: "Processed #{processed.count} recurring transactions",
      data: {
        processed: processed,
        errors: errors,
        processed_count: processed.count,
        error_count: errors.count
      }
    }
  end
  
  private
  
  def set_recurring_transaction
    @recurring_transaction = current_user.recurring_transactions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error(['Recurring transaction not found'], 'Not found', :not_found)
  end
  
  def recurring_transaction_params
    params.require(:recurring_transaction).permit(
      :type,
      :amount,
      :description,
      :category,
      :frequency,
      :start_date,
      :end_date,
      :next_occurrence,
      :is_active,
      config: {}
    )
  end
  
  def recurring_transaction_response(rt)
    {
      id: rt.id,
      type: rt.type,
      amount: rt.amount.to_f,
      description: rt.description,
      category: rt.category,
      frequency: rt.frequency,
      start_date: rt.start_date,
      end_date: rt.end_date,
      next_occurrence: rt.next_occurrence,
      is_active: rt.is_active,
      config: rt.config,
      created_at: rt.created_at,
      updated_at: rt.updated_at
    }
  end
end
