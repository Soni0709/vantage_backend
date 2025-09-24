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
  
  puts "Test user created: #{user.email} / password123" if user.persisted?
  
  # Create an admin user
  admin = User.find_or_create_by(email: 'admin@vantage.com') do |u|
    u.first_name = 'Admin'
    u.last_name = 'User'
    u.password = 'admin123'
    u.email_verified = true
  end
  
  puts "Admin user created: #{admin.email} / admin123" if admin.persisted?
end
