# Firebase Setup Instructions

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore Database

## Android Setup

1. In Firebase Console, go to Project Settings > General
2. Under "Your apps", click on Android icon
3. Register your app with package name: `com.example.ragfree_plus_flutter` (or your actual package name)
4. Download `google-services.json`
5. Place it in `android/app/` directory

## iOS Setup

1. In Firebase Console, go to Project Settings > General
2. Under "Your apps", click on iOS icon
3. Register your app with your bundle ID
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

## Firestore Security Rules

Set up these security rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

## Admin Credentials

The admin login is hardcoded with these credentials:
- **Email**: `admin@ragfree.com`
- **Password**: `Admin@123`

**Important**: Change these credentials in production by modifying the `adminLogin` method in `lib/services/auth_service.dart`.

## User Roles

- **Student**: Auto-approved, can register and login immediately
- **Parent**: Auto-approved, can register and login immediately
- **Counsellor**: Requires admin approval before login
- **Warden**: Requires admin approval before login
- **Police**: Requires admin approval before login
- **Admin**: Hardcoded login only

## Testing the Implementation

1. Run `flutter pub get` to install dependencies
2. Set up Firebase configuration files (see above)
3. Run the app
4. Register as a student/parent (should work immediately)
5. Register as police/counsellor/warden (will show approval pending screen)
6. Login as admin (use hardcoded credentials)
7. Go to "Manage Users" > "Pending" tab
8. Approve or reject pending users

