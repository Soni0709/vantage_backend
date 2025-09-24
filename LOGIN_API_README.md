# Vantage Backend - Login API

A Ruby on Rails API for user authentication using JWT tokens, designed to work with your React frontend.

## 🚀 Quick Setup

1. **Install dependencies**:
   ```bash
   bundle install
   ```

2. **Setup database**:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Start the server**:
   ```bash
   rails server -p 3001
   ```

## 📚 API Endpoints

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/v1/auth/login` | User login | ❌ |
| POST | `/api/v1/auth/register` | User registration | ❌ |
| DELETE | `/api/v1/auth/logout` | User logout | ✅ |
| GET | `/api/v1/auth/profile` | Get user profile | ✅ |
| PUT | `/api/v1/auth/profile` | Update user profile | ✅ |
| POST | `/api/v1/auth/forgot_password` | Request password reset | ❌ |
| PUT | `/api/v1/auth/reset_password` | Reset password | ❌ |

## 🔐 API Usage Examples

### Login
```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "test@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "full_name": "John Doe",
      "email_verified": true,
      "preferences": {},
      "created_at": "2025-01-20T10:30:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### Register
```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "auth": {
      "email": "newuser@example.com",
      "password": "password123",
      "first_name": "Jane",
      "last_name": "Smith"
    }
  }'
```

### Get Profile (Protected Route)
```bash
curl -X GET http://localhost:3001/api/v1/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Update Profile
```bash
curl -X PUT http://localhost:3001/api/v1/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "first_name": "Updated",
      "last_name": "Name"
    }
  }'
```

## 🧪 Test Users

The following test users are created automatically in development:

- **Email**: `test@example.com` | **Password**: `password123`
- **Email**: `admin@vantage.com` | **Password**: `admin123`

## 🛡️ Security Features

- ✅ **JWT Authentication**: Stateless token-based auth
- ✅ **Password Hashing**: Using bcrypt
- ✅ **UUID Primary Keys**: Enhanced security
- ✅ **Email Validation**: Proper format checking
- ✅ **CORS Configuration**: Ready for frontend integration
- ✅ **Password Reset**: Token-based reset flow
- ✅ **Input Validation**: Comprehensive parameter validation

## 🏗️ Architecture

### Key Components

1. **JsonWebToken Service** (`lib/json_web_token.rb`)
   - Handles JWT encoding/decoding
   - 24-hour token expiration
   - HS256 algorithm

2. **User Model** (`app/models/user.rb`)
   - Secure password handling
   - Email normalization
   - Validation rules
   - Reset token management

3. **AuthenticationService** (`app/services/authentication_service.rb`)
   - Login logic encapsulation
   - Clean error handling
   - Service object pattern

4. **Auth Controller** (`app/controllers/api/v1/auth_controller.rb`)
   - RESTful authentication endpoints
   - Consistent JSON responses
   - Proper HTTP status codes

### Database Schema

```ruby
create_table :users, id: :uuid do |t|
  t.string :email, null: false, index: { unique: true }
  t.string :first_name, null: false
  t.string :last_name, null: false
  t.string :password_digest, null: false
  t.boolean :email_verified, default: false
  t.string :reset_password_token
  t.datetime :reset_password_sent_at
  t.jsonb :preferences, default: {}
  t.timestamps
end
```

## 🌐 Frontend Integration

### Redux RTK Query Example

```typescript
// store/api/authApi.ts
export const authApi = createApi({
  reducerPath: 'authApi',
  baseQuery: fetchBaseQuery({
    baseUrl: 'http://localhost:3001/api/v1/auth',
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    login: builder.mutation<LoginResponse, LoginRequest>({
      query: (credentials) => ({
        url: '/login',
        method: 'POST',
        body: { auth: credentials },
      }),
    }),
    register: builder.mutation<RegisterResponse, RegisterRequest>({
      query: (userData) => ({
        url: '/register',
        method: 'POST',
        body: { auth: userData },
      }),
    }),
  }),
});
```

## 🔧 Configuration

### Environment Variables
- `RAILS_ENV`: Application environment
- `DATABASE_PASSWORD`: Production database password
- `FRONTEND_URL`: Frontend URL for CORS (production)

### CORS Configuration
Currently configured for:
- `http://localhost:3000` (React)
- `http://localhost:5173` (Vite)

## 🐛 Error Handling

The API returns consistent error responses:

```json
{
  "success": false,
  "message": "Login failed",
  "errors": ["Invalid email or password"]
}
```

### Common HTTP Status Codes
- `200`: Success
- `201`: Created (registration)
- `401`: Unauthorized (invalid credentials/token)
- `422`: Unprocessable Entity (validation errors)
- `404`: Not Found (invalid endpoints)

## 📝 TODO

- [ ] Email verification system
- [ ] Password reset email templates
- [ ] Rate limiting
- [ ] Token blacklisting for logout
- [ ] OAuth integration (Google, GitHub)
- [ ] Account lockout after failed attempts
- [ ] Audit logging

## 🤝 Contributing

1. Follow Ruby style guidelines
2. Write tests for new features
3. Update documentation
4. Ensure security best practices

## 📊 Next Steps

Your Login API is now ready! Next you might want to:

1. **Test the endpoints** using the provided curl commands
2. **Integrate with your React frontend**
3. **Add protected routes** for your application features
4. **Implement email verification**
5. **Set up error monitoring**

---

**Happy coding!** 🎉
