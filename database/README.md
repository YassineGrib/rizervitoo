# Rizervitoo Database Setup

This directory contains the database schema and migration scripts for the Rizervitoo travel booking application.

## Database Structure

The database consists of the following main tables:

### Core Tables

1. **profiles** - User profiles extending Supabase auth.users
2. **accommodations** - Hotels, houses, apartments, and other lodging options
3. **bookings** - Reservation management
4. **reviews** - Guest feedback and ratings
5. **messages** - Communication between guests and hosts
6. **travel_guides** - Algerian destination guides

## Schema Files

- `01_profiles.sql` - User profiles with Arabic localization
- `02_accommodations.sql` - Accommodation listings with geolocation
- `03_bookings.sql` - Booking system with availability checking
- `04_reviews.sql` - Review system with automatic rating updates
- `05_messages.sql` - Messaging system between users
- `06_travel_guides.sql` - Travel destination guides

## Migration to Supabase

### Prerequisites

1. **Supabase Account**: Create an account at [supabase.com](https://supabase.com)
2. **Supabase CLI**: Install the Supabase CLI
   ```bash
   npm install -g supabase
   ```

### Step 1: Create a New Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `rizervitoo`
   - **Database Password**: Choose a strong password
   - **Region**: Choose closest to Algeria (Europe West recommended)
5. Click "Create new project"

### Step 2: Get Project Credentials

Once your project is created:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Project ID**: `your-project-id`
   - **anon/public key**: `eyJ...` (for client-side)
   - **service_role key**: `eyJ...` (for admin operations)

### Step 3: Update Flutter App Configuration

Update your `lib/main.dart` with the new credentials:

```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co',
  anonKey: 'your-anon-key-here',
);
```

### Step 4: Run Database Migrations

#### Option A: Using Supabase Dashboard (Recommended)

1. Go to **SQL Editor** in your Supabase dashboard
2. Copy and paste the content of each schema file in order:
   - `01_profiles.sql`
   - `02_accommodations.sql`
   - `03_bookings.sql`
   - `04_reviews.sql`
   - `05_messages.sql`
   - `06_travel_guides.sql`
3. Run each script by clicking "Run"

#### Option B: Using Supabase CLI

1. Initialize Supabase in your project:
   ```bash
   supabase init
   ```

2. Link to your remote project:
   ```bash
   supabase link --project-ref your-project-id
   ```

3. Copy migration files to Supabase migrations folder:
   ```bash
   cp database/schema/*.sql supabase/migrations/
   ```

4. Push migrations to Supabase:
   ```bash
   supabase db push
   ```

### Step 5: Configure Row Level Security (RLS)

The schema files automatically enable RLS and create appropriate policies. Verify in your Supabase dashboard:

1. Go to **Authentication** → **Policies**
2. Ensure all tables have appropriate policies enabled
3. Test policies with different user roles

### Step 6: Set Up Storage (Optional)

For image uploads (accommodation photos, user avatars):

1. Go to **Storage** in Supabase dashboard
2. Create buckets:
   - `avatars` (for user profile pictures)
   - `accommodations` (for accommodation photos)
   - `reviews` (for review images)
   - `travel-guides` (for destination photos)

3. Set up storage policies for each bucket

### Step 7: Test the Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Test user registration and authentication
3. Verify that user profiles are created automatically
4. Test the database operations through your app

## Database Features

### Automatic Triggers

- **User Profile Creation**: Automatically creates a profile when a user registers
- **Rating Updates**: Automatically updates accommodation ratings when reviews are added
- **Timestamp Updates**: Automatically updates `updated_at` fields
- **Read Receipts**: Automatically sets `read_at` timestamp for messages

### Security Features

- **Row Level Security (RLS)**: Enabled on all tables
- **User Isolation**: Users can only access their own data
- **Host Permissions**: Accommodation owners can manage their properties
- **Booking Validation**: Prevents double bookings and invalid date ranges

### Performance Optimizations

- **Indexes**: Strategic indexes on frequently queried columns
- **Generated Columns**: Calculated fields like `total_nights` in bookings
- **Views**: Pre-joined views for common queries

## Sample Data

The migration includes sample travel guides for popular Algerian destinations:
- قصبة الجزائر (Casbah of Algiers)
- تيمقاد (Timgad)
- الهقار (Hoggar Mountains)
- تيبازة (Tipaza)

## Troubleshooting

### Common Issues

1. **Extension Errors**: Ensure PostGIS extension is enabled in Supabase
2. **Permission Errors**: Check RLS policies and user authentication
3. **Foreign Key Errors**: Run schema files in the correct order
4. **Date Format Errors**: Ensure proper date formatting in your Flutter app

### Getting Help

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Community](https://github.com/supabase/supabase/discussions)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)

## Next Steps

After setting up the database:

1. Implement data models in Flutter
2. Create service classes for database operations
3. Add proper error handling
4. Implement offline caching
5. Set up push notifications
6. Add analytics and monitoring

---

**Note**: Remember to keep your Supabase credentials secure and never commit them to version control. Use environment variables or Flutter's secure storage for production apps.