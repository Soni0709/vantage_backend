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
end
