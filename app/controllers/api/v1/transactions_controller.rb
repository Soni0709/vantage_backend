class Api::V1::TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update, :destroy]
  
  # GET /api/v1/transactions
  def index
    @transactions = current_user.transactions.recent
    
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
    transactions = current_user.transactions.this_month
    
    total_income = transactions.income.sum(:amount)
    total_expense = transactions.expense.sum(:amount)
    
    # Category breakdown
    category_summary = transactions.group(:category, :type).sum(:amount)
    
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
        balance: (total_income - total_expense).to_f,
        transaction_count: transactions.count,
        income_by_category: income_by_category,
        expense_by_category: expense_by_category
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
end
