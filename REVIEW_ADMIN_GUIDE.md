# Review Management Admin Guide

## Overview
I've added a comprehensive review management system to the admin dashboard that allows you to approve or reject user reviews before they become visible to the public.

## What's New

### 1. Admin Review Management Screen
- **Location**: Admin Dashboard → "إدارة التقييمات" card
- **Features**:
  - View all pending reviews (قيد المراجعة)
  - View all approved reviews (المقبولة)
  - Approve reviews with one click
  - Reject reviews with confirmation dialog
  - See detailed review information including ratings

### 2. Review Statistics in Dashboard
The admin dashboard now shows:
- **Total Reviews** (التقييمات): Total number of reviews in the system
- **Pending Reviews** (قيد المراجعة): Reviews waiting for approval
- **Verified Reviews** (التقييمات المقبولة): Approved reviews

### 3. Review Workflow
1. **User submits review** → Review is created with `is_verified = false`
2. **Admin reviews** → Admin can see review in "قيد المراجعة" tab
3. **Admin decides**:
   - **Approve** → Review becomes visible to public (`is_verified = true`)
   - **Reject** → Review is deleted from database

## How to Use

### Step 1: Access Review Management
1. Log into admin dashboard using credentials from `ADMIN_README.md`
2. Click on "إدارة التقييمات" (Review Management) card
3. You'll see two tabs:
   - **قيد المراجعة**: Pending reviews needing approval
   - **المقبولة**: Already approved reviews

### Step 2: Review Pending Reviews
- Each review card shows:
  - Guest name and avatar
  - Star rating (overall + detailed ratings)
  - Review title and comment
  - Accommodation name
  - Submission date
  - **Approve** (قبول) and **Reject** (رفض) buttons

### Step 3: Approve or Reject
- **To Approve**: Click "قبول" → Confirm in dialog → Review becomes public
- **To Reject**: Click "رفض" → Confirm in dialog → Review is permanently deleted

### Step 4: Monitor Approved Reviews
- Switch to "المقبولة" tab to see all approved reviews
- These reviews are visible to users in the app

## Technical Details

### Database Changes
- Reviews are created with `is_verified = false` by default
- Only reviews with `is_verified = true` are shown to public users
- Admin can change this status through the management interface

### Files Added/Modified
- ✅ `lib/screens/admin_reviews_screen.dart` - New review management screen
- ✅ `lib/services/admin_service.dart` - Added review management methods
- ✅ `lib/screens/admin_dashboard_screen.dart` - Added review management card and statistics
- ✅ `lib/services/review_service.dart` - Added debug logging for troubleshooting

### Admin Service Methods Added
- `getPendingReviews()` - Get reviews waiting for approval
- `getVerifiedReviews()` - Get approved reviews
- `approveReview(reviewId)` - Approve a review
- `rejectReview(reviewId)` - Reject/delete a review
- `getReviewStats()` - Get review statistics for dashboard

## Review Process Flow

```
User submits review
       ↓
Review saved with is_verified = false
       ↓
Admin sees review in "قيد المراجعة" tab
       ↓
Admin clicks "قبول" or "رفض"
       ↓
If approved: is_verified = true (visible to public)
If rejected: Review deleted permanently
```

## Important Notes

1. **Review Visibility**: Only approved reviews (`is_verified = true`) are shown to users in the app
2. **Permanent Deletion**: Rejected reviews are permanently deleted, not just hidden
3. **Real-time Updates**: The pending count updates immediately after approval/rejection
4. **Review Content**: Admin can see full review content including detailed ratings before making decisions

## Troubleshooting

If you don't see any reviews:
1. Check that users have submitted reviews after checkout dates
2. Verify the database RLS policies are updated (run `fix_review_functionality.sql`)
3. Check debug logs in the Flutter console for any errors

## Security

- Only admin users (admin@rizervitoo.dz) can access review management
- All review operations are logged and secured through Supabase RLS
- Users cannot bypass the approval process

---

The review management system ensures quality control over user-generated content while providing a smooth workflow for administrators to moderate reviews efficiently.