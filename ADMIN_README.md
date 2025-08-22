# Rizervitoo Admin Dashboard - Access Guide

## Overview
The Rizervitoo app includes a comprehensive admin dashboard for managing travel guides, user accounts, and viewing system statistics. This guide explains how to access and use the admin features.

## Admin Access

### 🔐 Admin Login Credentials:
- **Email:** `admin@rizervitoo.dz`
- **Password:** `RizerAdmin2024!`

## 🚀 How to Access Admin Dashboard

### Method 1 - Welcome Screen Logo (Recommended):
- Open the app (starts on Welcome Screen)
- **Long press and hold** the main Rizervitoo logo (black logo in the center) for 2-3 seconds
- This will navigate you to the admin login screen
- Enter the admin credentials above

### Method 2 - Home Screen Logo (Alternative):
- Navigate to the home screen after signing in
- **Long press and hold** the Rizervitoo logo in the top-left corner for 2-3 seconds
- This will also navigate you to the admin login screen

### Method 3 - Direct URL (Web only):
- Navigate directly to: `http://127.0.0.1:50001/WSFd9wiJEb4=#/admin-login`
- Replace with your current app URL if different

### Launch the App:
```bash
flutter run -d edge
```
Or run on your preferred device/emulator.

3. **Admin Dashboard Features**
   Once logged in, you'll have access to:

## Admin Dashboard Features

### 📊 Dashboard Overview
- Real-time statistics display
- Total users count
- Total travel guides count
- System overview metrics

### 🗺️ Travel Guides Management
- **View All Guides**: Browse all published travel guides
- **Create New Guide**: Add new travel destinations
- **Edit Existing Guides**: Modify guide content, location, category
- **Delete Guides**: Remove outdated or inappropriate content
- **Publish/Unpublish**: Control guide visibility

#### Travel Guide Fields:
- Title (Arabic)
- Description/Content
- Location (City)
- Category (Cultural, Natural, Historical, etc.)
- Tags
- Publication status
- View count tracking

### 👥 User Management
- View all registered users
- Monitor user activity
- Manage user accounts
- View user profiles and statistics

## Navigation Structure

```
Admin Dashboard
├── 📊 Dashboard (Statistics)
├── 🗺️ Travel Guides
│   ├── View All Guides
│   ├── Create New Guide
│   └── Edit/Delete Guides
└── 👥 User Management
    ├── View All Users
    └── User Details
```

## Technical Details

### Database Integration
- Uses Supabase for backend operations
- Real-time data synchronization
- Secure admin authentication

### Security Features
- Admin-only access control
- Secure login system
- Protected admin routes

### Supported Platforms
- Web (Edge, Chrome, Firefox)
- Mobile (Android, iOS)
- Desktop (Windows, macOS, Linux)

## Development Setup

### Prerequisites
- Flutter SDK installed
- Supabase project configured
- Admin credentials set up in your backend

### Running the Admin Dashboard
1. Ensure your Supabase connection is configured
2. Run the Flutter app: `flutter run -d edge`
3. Navigate to admin login
4. Use admin credentials to access dashboard

## 🔧 Troubleshooting Admin Access

If you cannot access the admin login:

1. **Welcome Screen Access**: 
   - Make sure you're on the **Welcome Screen** (first screen when app opens)
   - **Long press** (hold for 2-3 seconds) the main black logo in the center
   - Don't just tap - you need to hold the logo

2. **Home Screen Access**: 
   - Navigate to the home screen after signing in as a regular user
   - **Long press** the blue logo in the top-left corner

3. **Direct URL Access**: 
   - For web, navigate directly to: `http://127.0.0.1:50001/WSFd9wiJEb4=#/admin-login`
   - Replace the URL with your current app URL if different

4. **Check Credentials**: 
   - Email: `admin@rizervitoo.dz`
   - Password: `RizerAdmin2024!`

5. **Restart App**: Try hot restarting the Flutter app if gestures aren't working

## Troubleshooting

### Common Issues
1. **Login fails**
   - Verify admin credentials in Supabase
   - Check network connection
   - Ensure Supabase project is active

2. **Data not loading**
   - Check Supabase connection
   - Verify database permissions
   - Check console for error messages

### Support
For technical support or issues with the admin dashboard, check:
- Flutter console logs
- Supabase dashboard logs
- Network connectivity

## Security Notes

⚠️ **Important Security Reminders**:
- Never share admin credentials
- Use strong passwords
- Regularly monitor admin access logs
- Keep the admin interface secure and private

---

**Last Updated**: January 2025
**Version**: 1.0.0
**Platform**: Flutter Web/Mobile