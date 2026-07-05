# Quick Integration Guide

## Step 1: Install Dependencies

```bash
cd C:\Users\Oguzhan\devkom_app
flutter pub get
```

## Step 2: Firebase Console Setup

### Firestore Rules
1. Go to Firebase Console → Firestore Database → Rules
2. Copy the rules from `SOCIAL_FEED_SETUP.md` → "Firestore Security Rules"
3. Click "Publish"

### Storage Rules
1. Go to Firebase Console → Storage → Rules
2. Copy the rules from `SOCIAL_FEED_SETUP.md` → "Firebase Storage Rules"
3. Click "Publish"

### Create Indexes
1. Go to Firestore Database → Indexes → Composite
2. Create these indexes:

**Index 1:**
- Collection: `posts`
- Fields: `isApproved` (Ascending), `createdAt` (Descending)

**Index 2:**
- Collection: `posts`
- Fields: `tags` (Array), `isApproved` (Ascending), `createdAt` (Descending)

**Index 3:**
- Collection: `post_comments`
- Fields: `postId` (Ascending), `createdAt` (Ascending)

## Step 3: Add to Your App Navigation

### Option 1: Replace existing EnhancedFeedScreen

Find where `EnhancedFeedScreen` is used in your app and replace with:

```dart
import 'package:devkom_app/screens/social/enhanced_feed_screen_v2.dart';

// In your navigation/menu
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EnhancedFeedScreenV2(),
  ),
);
```

### Option 2: Add to Bottom Navigation

```dart
// In your main screen with bottom nav
int _selectedIndex = 0;

final List<Widget> _screens = [
  HomeScreen(),
  const EnhancedFeedScreenV2(), // Add here
  ProfileScreen(),
];

BottomNavigationBar(
  currentIndex: _selectedIndex,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
)
```

### Option 3: Add to Drawer Menu

```dart
ListTile(
  leading: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4A90E2), Color(0xFF9B59B6)],
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.feed, color: Colors.white, size: 20),
  ),
  title: const Text('Social Feed'),
  subtitle: const Text('✨ DevFeed'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedFeedScreenV2(),
      ),
    );
  },
),
```

## Step 4: Test Basic Functionality

### Test 1: View Feed
1. Run the app
2. Navigate to the feed
3. Should see empty state: "🚀 Be the first to share something amazing!"

### Test 2: Create Post (Authenticated User)
1. Login as a user
2. Click the floating "Create Post" button
3. Add text, images, or PDF
4. Click "Post"
5. Should see success message
6. Post appears in feed

### Test 3: Visitor Mode
1. Logout or use visitor mode
2. Open feed
3. Should see "👁️ Viewing as Guest" badge
4. Can view and like posts
5. Comment button shows "🔒 Login to comment"
6. No "Create Post" button

### Test 4: Daily Limit
1. Login as regular user (non-PRO)
2. Create 2 posts
3. Try to create 3rd post
4. Should see "Daily limit reached" message

### Test 5: PRO User
1. Set `isPro: true` in user document in Firestore
2. Create post screen should show "⭐ PRO: Unlimited posts"
3. Can create unlimited posts

## Step 5: Add isPro Field to Users

In Firestore, add `isPro` field to user documents:

```javascript
// Example user document
{
  name: "John Doe",
  email: "john@example.com",
  role: "student",
  isPro: false, // Add this field
  // ... other fields
}
```

Or via code when user subscribes:

```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'isPro': true});
```

## Step 6: Customize Theme Colors (Optional)

If you want to change the AI theme colors, update these in the files:

**Primary Blue**: `Color(0xFF4A90E2)`
**Secondary Purple**: `Color(0xFF9B59B6)`

Files to modify:
- `lib/screens/social/enhanced_feed_screen_v2.dart`
- `lib/screens/social/create_post_screen_modern.dart`
- `lib/screens/social/post_detail_screen.dart`

## Common Issues & Solutions

### Issue 1: Posts not appearing
**Solution**: Check Firestore rules and ensure `isApproved: true` in post documents

### Issue 2: "Permission denied" on image upload
**Solution**: Verify Firebase Storage rules are deployed

### Issue 3: Link preview not working
**Solution**: Normal for some websites that block scraping. Works for most sites.

### Issue 4: Daily limit not working
**Solution**: Ensure `user_post_counts` collection has write permissions

### Issue 5: Imports not found
**Solution**: Run `flutter pub get` and restart IDE

## Production Checklist

Before deploying to production:

- [ ] Firebase Firestore rules deployed
- [ ] Firebase Storage rules deployed
- [ ] Firestore indexes created
- [ ] Tested with authenticated users
- [ ] Tested with visitors
- [ ] Tested daily post limit
- [ ] Tested PRO features
- [ ] Tested on iOS (if applicable)
- [ ] Tested on Android
- [ ] All images compressed properly
- [ ] Error handling verified
- [ ] Localization tested (Turkish/English)

## Need Help?

1. Check `SOCIAL_FEED_SETUP.md` for detailed documentation
2. Review Firebase Console for errors
3. Check app logs for error messages
4. Verify all dependencies are installed
5. Ensure minimum Flutter version (3.6.0)

## Quick Reference: File Locations

```
lib/
├── models/
│   └── post_model.dart (MODIFIED - Enhanced with new fields)
├── services/
│   └── social_feed_service.dart (NEW - Complete service layer)
├── screens/
│   └── social/
│       ├── create_post_screen_modern.dart (NEW - Modern create UI)
│       ├── enhanced_feed_screen_v2.dart (NEW - Instagram/X quality)
│       └── post_detail_screen.dart (NEW - Post details & comments)
└── utils/
    └── app_localizations.dart (MODIFIED - Added social strings)

pubspec.yaml (MODIFIED - Added http, shimmer)
SOCIAL_FEED_SETUP.md (NEW - Complete documentation)
INTEGRATION_GUIDE.md (NEW - This file)
```

---

**You're all set! 🚀**

The social feed platform is ready to use. Just follow the steps above to integrate it into your app!
