# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create a test user for development
if Rails.env.development?
  user = User.find_or_create_by(email: 'test@example.com') do |u|
    u.first_name = 'John'
    u.last_name = 'Doe'
    u.password = 'password123'
    u.email_verified = true
  end
  
  puts "Test user: #{user.email} / password123"
  
  # Create an admin user
  admin = User.find_or_create_by(email: 'admin@vantage.com') do |u|
    u.first_name = 'Admin'
    u.last_name = 'User'
    u.password = 'admin123'
    u.email_verified = true
  end
  
  puts "Admin user: #{admin.email} / admin123"
  
  # Create sample transactions for test user
  if user.transactions.empty?
    puts "Creating sample transactions..."
    
    # Income transactions
    user.transactions.create!([
      {
        type: 'income',
        amount: 5000.00,
        category: 'Salary',
        description: 'Monthly salary payment',
        transaction_date: Date.current,
        payment_method: 'Bank Transfer'
      },
      {
        type: 'income',
        amount: 500.00,
        category: 'Freelance',
        description: 'Website design project',
        transaction_date: Date.current - 2.days,
        payment_method: 'PayPal'
      },
      {
        type: 'income',
        amount: 150.00,
        category: 'Investment',
        description: 'Dividend payment',
        transaction_date: Date.current - 5.days,
        payment_method: 'Bank Transfer'
      }
    ])
    
    # Expense transactions
    user.transactions.create!([
      {
        type: 'expense',
        amount: 1200.00,
        category: 'Rent',
        description: 'Monthly rent payment',
        transaction_date: Date.current - 1.day,
        payment_method: 'Bank Transfer'
      },
      {
        type: 'expense',
        amount: 45.50,
        category: 'Food',
        description: 'Grocery shopping at Walmart',
        transaction_date: Date.current,
        payment_method: 'Credit Card'
      },
      {
        type: 'expense',
        amount: 80.00,
        category: 'Transportation',
        description: 'Gas and parking',
        transaction_date: Date.current - 3.days,
        payment_method: 'Debit Card'
      },
      {
        type: 'expense',
        amount: 120.00,
        category: 'Utilities',
        description: 'Electricity and water bill',
        transaction_date: Date.current - 7.days,
        payment_method: 'Auto-pay'
      },
      {
        type: 'expense',
        amount: 35.00,
        category: 'Entertainment',
        description: 'Movie tickets',
        transaction_date: Date.current - 4.days,
        payment_method: 'Credit Card'
      }
    ])
    
    puts "Created #{user.transactions.count} sample transactions"
    puts "  - Income: #{user.transactions.income.count} transactions"
    puts "  - Expense: #{user.transactions.expense.count} transactions"
    puts "  - Total Income: $#{user.transactions.income.sum(:amount)}"
    puts "  - Total Expense: $#{user.transactions.expense.sum(:amount)}"
  else
    puts "Transactions already exist, skipping..."
  end
  
  # Create sample recurring transactions for test user
  if user.recurring_transactions.empty?
    puts "Creating sample recurring transactions..."
    
    user.recurring_transactions.create!([
      {
        type: 'income',
        amount: 5000.00,
        category: 'Salary',
        description: 'Monthly salary',
        frequency: 'monthly',
        start_date: Date.current.beginning_of_month,
        next_occurrence: (Date.current + 1.month).beginning_of_month,
        is_active: true
      },
      {
        type: 'expense',
        amount: 1200.00,
        category: 'Rent',
        description: 'Monthly rent payment',
        frequency: 'monthly',
        start_date: Date.current.beginning_of_month,
        next_occurrence: (Date.current + 1.month).beginning_of_month,
        is_active: true
      },
      {
        type: 'expense',
        amount: 50.00,
        category: 'Utilities',
        description: 'Internet subscription',
        frequency: 'monthly',
        start_date: Date.current,
        next_occurrence: Date.current + 1.month,
        is_active: true
      },
      {
        type: 'expense',
        amount: 15.00,
        category: 'Entertainment',
        description: 'Netflix subscription',
        frequency: 'monthly',
        start_date: Date.current - 10.days,
        next_occurrence: Date.current + 20.days,
        is_active: true
      },
      {
        type: 'expense',
        amount: 100.00,
        category: 'Health',
        description: 'Gym membership',
        frequency: 'monthly',
        start_date: Date.current.beginning_of_month,
        next_occurrence: (Date.current + 1.month).beginning_of_month,
        is_active: false
      }
    ])
    
    puts "Created #{user.recurring_transactions.count} recurring transactions"
    puts "  - Active: #{user.recurring_transactions.active.count}"
    puts "  - Inactive: #{user.recurring_transactions.inactive.count}"
    puts "  - Income: #{user.recurring_transactions.income.count}"
    puts "  - Expense: #{user.recurring_transactions.expense.count}"
  else
    puts "Recurring transactions already exist, skipping..."
  end
  
  # Create sample budgets for test user
  if user.budgets.empty?
    puts "Creating sample budgets..."
    
    user.budgets.create!([
      {
        category: 'Food',
        amount: 5000.00,
        period: 'monthly',
        start_date: Date.current.beginning_of_month,
        alert_threshold: 80,
        alert_enabled: true,
        is_active: true
      },
      {
        category: 'Transportation',
        amount: 2000.00,
        period: 'monthly',
        start_date: Date.current.beginning_of_month,
        alert_threshold: 75,
        alert_enabled: true,
        is_active: true
      },
      {
        category: 'Entertainment',
        amount: 1500.00,
        period: 'monthly',
        start_date: Date.current.beginning_of_month,
        alert_threshold: 90,
        alert_enabled: true,
        is_active: true
      },
      {
        category: 'Utilities',
        amount: 3000.00,
        period: 'monthly',
        start_date: Date.current.beginning_of_month,
        alert_threshold: 85,
        alert_enabled: true,
        is_active: true
      },
      {
        category: 'Health',
        amount: 2500.00,
        period: 'quarterly',
        start_date: Date.current.beginning_of_quarter,
        alert_threshold: 80,
        alert_enabled: true,
        is_active: true
      }
    ])
    
    puts "Created #{user.budgets.count} budgets"
    puts "  - Active: #{user.budgets.active.count}"
    puts "  - Total budgeted: ₹#{user.budgets.sum(:amount)}"
  else
    puts "Budgets already exist, skipping..."
  end
end
