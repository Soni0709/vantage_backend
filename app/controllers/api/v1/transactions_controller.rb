class Api::V1::TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update, :destroy]
  
  # GET /api/v1/transactions
  def index
    @transactions = current_user.transactions.recent
    
    # Apply filters from query parameters
    @transactions = apply_filters(@transactions)
    
    render json: {
      success: true,
      message: 'Transactions retrieved successfully',
      data: {
        transactions: @transactions.map { |t| transaction_response(t) }
      }
    }
  end
  
  # GET /api/v1/transactions/summary
def summary
  # Current month transactions
  current_month_transactions = current_user.transactions.this_month
  
  total_income = current_month_transactions.income.sum(:amount)
  total_expense = current_month_transactions.expense.sum(:amount)
  current_balance = (total_income - total_expense).to_f
  
  # Previous month transactions
  previous_month_transactions = current_user.transactions.previous_month
  
  previous_income = previous_month_transactions.income.sum(:amount)
  previous_expense = previous_month_transactions.expense.sum(:amount)
  previous_balance = (previous_income - previous_expense).to_f
  
  # Category breakdown (current month)
  category_summary = current_month_transactions.group(:category, :type).sum(:amount)
  
  income_by_category = {}
  expense_by_category = {}
  
  category_summary.each do |(category, type), amount|
    if type == 'income'
      income_by_category[category] = amount.to_f
    else
      expense_by_category[category] = amount.to_f
    end
  end
  
  render json: {
    success: true,
    message: 'Summary retrieved successfully',
    data: {
      total_income: total_income.to_f,
      total_expense: total_expense.to_f,
      balance: current_balance,
      transaction_count: current_month_transactions.count,
      income_by_category: income_by_category,
      expense_by_category: expense_by_category,
      previous_month_summary: {
        total_income: previous_income.to_f,
        total_expense: previous_expense.to_f,
        balance: previous_balance
      }
    }
  }
end
  
  # GET /api/v1/transactions/:id
  def show
    render json: {
      success: true,
      message: 'Transaction retrieved successfully',
      data: {
        transaction: transaction_response(@transaction)
      }
    }
  end
  
  # POST /api/v1/transactions
  def create
    @transaction = current_user.transactions.new(transaction_params)
    
    if @transaction.save
      render json: {
        success: true,
        message: 'Transaction created successfully',
        data: {
          transaction: transaction_response(@transaction)
        }
      }, status: :created
    else
      render_error(@transaction.errors.full_messages, 'Failed to create transaction')
    end
  end
  
  # PUT /api/v1/transactions/:id
  def update
    if @transaction.update(transaction_params)
      render json: {
        success: true,
        message: 'Transaction updated successfully',
        data: {
          transaction: transaction_response(@transaction)
        }
      }
    else
      render_error(@transaction.errors.full_messages, 'Failed to update transaction')
    end
  end
  
  # DELETE /api/v1/transactions/:id
  def destroy
    @transaction.destroy
    render json: {
      success: true,
      message: 'Transaction deleted successfully'
    }
  end
  
  private
  
  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_error(['Transaction not found'], 'Not found', :not_found)
  end
  
  def transaction_params
    params.require(:transaction).permit(
      :type,
      :amount,
      :category,
      :description,
      :transaction_date,
      :payment_method,
      metadata: {}
    )
  end
  
  def transaction_response(transaction)
    {
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount.to_f,
      category: transaction.category,
      description: transaction.description,
      transaction_date: transaction.transaction_date,
      payment_method: transaction.payment_method,
      metadata: transaction.metadata,
      created_at: transaction.created_at,
      updated_at: transaction.updated_at
    }
  end
  
  # Apply filters from query parameters
  def apply_filters(transactions)
    begin
      # Filter by type (income/expense)
      if params[:type].present?
        transactions = transactions.where(type: params[:type])
        Rails.logger.info "✅ Applied type filter: #{params[:type]}"
      end
      
      # Filter by category
      if params[:category].present?
        transactions = transactions.where(category: params[:category])
        Rails.logger.info "✅ Applied category filter: #{params[:category]}"
      end
      
      # Filter by start date
      if params[:start_date].present?
        begin
          start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
          transactions = transactions.where('transaction_date >= ?', start_date.beginning_of_day)
          Rails.logger.info "✅ Applied start_date filter: #{params[:start_date]}"
        rescue => e
          Rails.logger.warn "⚠️ Invalid start_date format: #{params[:start_date]} - #{e.message}"
        end
      end
      
      # Filter by end date
      if params[:end_date].present?
        begin
          end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
          transactions = transactions.where('transaction_date <= ?', end_date.end_of_day)
          Rails.logger.info "✅ Applied end_date filter: #{params[:end_date]}"
        rescue => e
          Rails.logger.warn "⚠️ Invalid end_date format: #{params[:end_date]} - #{e.message}"
        end
      end
      
      # Filter by minimum amount
      if params[:min_amount].present?
        min_amount = params[:min_amount].to_f
        transactions = transactions.where('amount >= ?', min_amount)
        Rails.logger.info "✅ Applied min_amount filter: #{min_amount}"
      end
      
      # Filter by maximum amount
      if params[:max_amount].present?
        max_amount = params[:max_amount].to_f
        transactions = transactions.where('amount <= ?', max_amount)
        Rails.logger.info "✅ Applied max_amount filter: #{max_amount}"
      end
      
      # Filter by search (description, category)
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        # Use ILIKE for PostgreSQL, LIKE for others
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
          transactions = transactions.where(
            'description ILIKE ? OR category ILIKE ?',
            search_term,
            search_term
          )
        else
          transactions = transactions.where(
            'description LIKE ? OR category LIKE ?',
            search_term,
            search_term
          )
        end
        Rails.logger.info "✅ Applied search filter: #{params[:search]}"
      end
      
      Rails.logger.info "📊 Total transactions after filters: #{transactions.count}"
      
      transactions
    rescue => e
      Rails.logger.error "❌ Error applying filters: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Return unfiltered transactions on error
      current_user.transactions.recent
    end
  end
end