# Quick Start Guide - Devkom Social Feed

## 🚀 Get Started in 3 Steps

### Step 1: Deploy Firebase Rules (5 min)

#### Firestore Rules
```bash
# Go to: Firebase Console → Firestore Database → Rules
# Copy and paste the rules from SOCIAL_FEED_SETUP.md section "Firestore Security Rules"
# Click "Publish"
```

#### Storage Rules
```bash
# Go to: Firebase Console → Storage → Rules
# Copy and paste the rules from SOCIAL_FEED_SETUP.md section "Firebase Storage Rules"
# Click "Publish"
```

#### Create Indexes
```bash
# Go to: Firebase Console → Firestore Database → Indexes → Composite
# Click "Create Index" for each of these:

Index 1:
- Collection: posts
- Fields: isApproved (Ascending), createdAt (Descending)

Index 2:
- Collection: posts
- Fields: tags (Array), isApproved (Ascending), createdAt (Descending)

Index 3:
- Collection: post_comments
- Fields: postId (Ascending), createdAt (Ascending)
```

---

### Step 2: Add to Your App (10 min)

#### Import the Screen
```dart
import 'package:devkom_app/screens/social/enhanced_feed_screen_v2.dart';
```

#### Add to Navigation
Choose one:

**Option A: Drawer Menu**
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

**Option B: Bottom Navigation**
```dart
final List<Widget> _screens = [
  HomeScreen(),
  const EnhancedFeedScreenV2(), // Add here
  ProfileScreen(),
];
```

**Option C: Direct Navigation**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EnhancedFeedScreenV2(),
  ),
);
```

---

### Step 3: Test It! (5 min)

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Navigate to Social Feed**
   - You should see the empty state

3. **Create a post**
   - Login as a user
   - Click the "Create Post" button
   - Add text and/or media
   - Click "Post"

4. **Verify it works**
   - Post appears in feed
   - Can like the post
   - Can comment on the post
   - Can delete own post

---

## 📸 Visual Guide

### Main Feed Screen
```
╔════════════════════════════════════╗
║  ✨ DevFeed        🔍  🔔         ║
║  ┌──────────────────────────────┐ ║
║  │ 🔥 Trending  🤖 AI  💻 Code  │ ║
║  └──────────────────────────────┘ ║
╠════════════════════════════════════╣
║  ┌──────────────────────────────┐ ║
║  │ 👤 John Doe    🎓     2h ago │ ║
║  │ Check out my new robot! 🤖   │ ║
║  │ #robotics #coding            │ ║
║  │ [Image Gallery]              │ ║
║  │ ❤️ 24  💬 5  ⚡ Share        │ ║
║  └──────────────────────────────┘ ║
║                                    ║
║  [More posts...]                   ║
║                                    ║
║               [➕ Create Post]     ║
╚════════════════════════════════════╝
```

### Create Post Screen (Bottom Sheet)
```
╔════════════════════════════════════╗
║  👤 Create Post            Cancel  ║
║  ┌──────────────────────────────┐ ║
║  │ ✨ 2 posts remaining today   │ ║
║  └──────────────────────────────┘ ║
║  ┌──────────────────────────────┐ ║
║  │ What's on your mind? 🚀      │ ║
║  │                              │ ║
║  │                              │ ║
║  └──────────────────────────────┘ ║
║  🔗 Add a link (optional)         ║
║  ┌──────────────────────────────┐ ║
║  │ [Image Preview 1] [2] [3]    │ ║
║  └──────────────────────────────┘ ║
║  📸 Images  📄 PDF     [Post] ➤  ║
╚════════════════════════════════════╝
```

### Post Detail Screen
```
╔════════════════════════════════════╗
║  ← Post Details                    ║
╠════════════════════════════════════╣
║  ┌──────────────────────────────┐ ║
║  │ 👤 John Doe         2h ago   │ ║
║  │ My awesome robot project!    │ ║
║  │ #robotics #coding #ai        │ ║
║  │ ❤️ 24 likes  💬 5 comments   │ ║
║  └──────────────────────────────┘ ║
║  ┌─ 💬 Comments ──────────────┐  ║
║  │ 👤 Jane: Great work! 🎉     │  ║
║  │ 👤 Bob: Love it!            │  ║
║  └──────────────────────────────┘ ║
║  👤 [Add a comment...]   [➤]      ║
╚════════════════════════════════════╝
```

---

## 🎯 Common Use Cases

### 1. Create Text Post
```dart
// User clicks FAB → enters text → clicks Post
// Result: Text-only post appears in feed
```

### 2. Create Post with Images
```dart
// User clicks FAB → enters text → clicks 📸 Images
// → selects 1-5 images → clicks Post
// Result: Post with image gallery appears in feed
```

### 3. Create Post with PDF
```dart
// User clicks FAB → enters text → clicks 📄 PDF
// → selects PDF file → clicks Post
// Result: Post with PDF preview appears in feed
```

### 4. Create Post with Link
```dart
// User clicks FAB → enters text → adds URL → clicks Post
// Result: Post with link preview card appears in feed
```

### 5. Like a Post
```dart
// Method 1: Click heart icon
// Method 2: Double-tap image
// Result: Heart animation, like count increases
```

### 6. Comment on Post
```dart
// Click 💬 icon → opens Post Detail
// Enter comment → click send
// Result: Comment appears in real-time
```

### 7. Filter Posts
```dart
// Click filter chip (🔥 Trending, 🤖 AI, etc.)
// Result: Shows posts with that tag only
```

---

## 🔧 Configuration

### Set PRO Status
```dart
// In Firestore, update user document:
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'isPro': true});
```

### Customize Colors
Edit these values in the screen files:
```dart
// Primary Blue
Color(0xFF4A90E2)

// Secondary Purple
Color(0xFF9B59B6)
```

### Adjust Daily Limits
Edit in `social_feed_service.dart`:
```dart
const dailyLimit = 2; // Change to desired limit
```

---

## 🆘 Troubleshooting

### No posts showing
✅ Check Firestore rules are deployed
✅ Ensure posts have `isApproved: true`
✅ Check Firebase Console for errors

### Can't upload images
✅ Check Storage rules are deployed
✅ Verify app has camera/storage permissions
✅ Check file size limits (5MB for images)

### Daily limit not working
✅ Ensure `user_post_counts` collection exists
✅ Check `isPro` field in user document
✅ Verify Firestore rules allow writes

### Link preview not loading
✅ Normal for some websites
✅ Check internet connection
✅ Verify URL is accessible

---

## 📚 Full Documentation

For detailed documentation, see:
- **SOCIAL_FEED_SETUP.md** - Complete technical docs
- **INTEGRATION_GUIDE.md** - Detailed integration steps
- **SOCIAL_FEED_SUMMARY.md** - Implementation summary

---

## ✅ Checklist

Before going live:
- [ ] Firebase Firestore rules deployed
- [ ] Firebase Storage rules deployed
- [ ] Firestore indexes created (3 indexes)
- [ ] Tested creating posts
- [ ] Tested with visitors
- [ ] Tested daily limits
- [ ] Tested on iOS (if applicable)
- [ ] Tested on Android
- [ ] Localization verified

---

## 🎉 You're Done!

Your social feed is ready to use. Enjoy! 🚀

Questions? Check the documentation files or Firebase Console logs.
