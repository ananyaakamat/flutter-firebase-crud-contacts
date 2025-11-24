# Firebase Setup Guide for Contacts CRUD App

Follow these steps to configure Firebase for your Contacts CRUD application.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `contacts-crud-app` (or your preferred name)
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Set up Firestore Database

1. In your Firebase project console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development (we'll add security rules later)
4. Select a location closest to your users
5. Click "Done"

## Step 3: Add Flutter App to Firebase Project

### For Android:
1. In Firebase console, click "Add app" → Android icon
2. Enter Android package name: `com.example.contacts.contacts_crud_app`
3. Enter app nickname: `Contacts CRUD Android`
4. Download `google-services.json`
5. Place the file in `android/app/` directory

### For Web:
1. In Firebase console, click "Add app" → Web icon
2. Enter app nickname: `Contacts CRUD Web`
3. Copy the Firebase configuration object
4. We'll use this in the next step

## Step 4: Install Firebase CLI and FlutterFire CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

## Step 5: Configure Flutter with Firebase

Run this command in your Flutter project root:

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select the project you created
- Generate `lib/firebase_options.dart` with your configuration
- Configure both Android and Web platforms

## Step 6: Deploy Firestore Security Rules

The project includes pre-configured security rules in `firestore.rules`. Deploy them:

```bash
# Initialize Firebase in your project (if not done)
firebase init

# Select:
# - Firestore: Configure rules and indexes files
# - Hosting: Configure files for Firebase Hosting

# Deploy security rules
firebase deploy --only firestore:rules
```

## Step 7: Configure Android (if targeting Android)

### Update android/app/build.gradle:
```gradle
android {
    compileSdk 34

    defaultConfig {
        minSdkVersion 21  // Minimum for Firebase
        targetSdkVersion 34
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

### Update android/build.gradle:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### Update android/app/build.gradle (bottom):
```gradle
apply plugin: 'com.google.gms.google-services'
```

## Step 8: Test Your Configuration

1. Run the app:
   ```bash
   flutter run -d chrome  # For web
   # or
   flutter run -d android # For Android
   ```

2. Create a test contact to verify Firestore connectivity

## Step 9: Deploy to Production

### Web Deployment:
```bash
flutter build web
firebase deploy --only hosting
```

### Android Deployment:
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## Important Security Notes

1. **Production Security Rules**: The current rules allow anonymous access. For production, implement proper authentication:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /contacts/{contactId} {
      allow read, write: if request.auth != null; // Requires authentication
    }
  }
}
```

2. **Environment Variables**: Never commit sensitive Firebase configuration to public repositories.

3. **API Keys**: Web API keys in Firebase are safe to expose as they're domain-restricted.

## Troubleshooting

### Common Issues:

1. **"No Firebase App '[DEFAULT]' has been created"**
   - Ensure `Firebase.initializeApp()` is called before using any Firebase services
   - Check that `firebase_options.dart` exists and is imported

2. **"Permission denied" errors**
   - Verify Firestore rules are deployed correctly
   - Check that the rules match your app's requirements

3. **Android build errors**
   - Ensure minimum SDK version is 21 or higher
   - Verify `google-services.json` is in the correct location

4. **Web CORS errors**
   - Ensure your domain is added to Firebase authorized domains
   - Check Firebase Hosting configuration

### Firebase Emulator (for Development):

```bash
# Install Firebase emulators
firebase init emulators

# Start emulators
firebase emulators:start

# In your Flutter app, point to local emulator (development only)
```

For development, you can use Firebase emulators to test locally without affecting production data.

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Support](https://support.google.com/firebase/)

After completing these steps, your Contacts CRUD app will be fully configured with Firebase!