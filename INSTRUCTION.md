# Flutter Firebase CRUD - Complete Setup Instructions

This document provides step-by-step instructions to set up the Flutter Firebase CRUD Contacts application from scratch. The app supports both **Android** and **Web** platforms with Firebase Firestore as the backend database.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installing Firebase CLI](#installing-firebase-cli)
3. [Creating Firebase Project](#creating-firebase-project)
4. [Adding Android App](#adding-android-app)
5. [Adding Web App](#adding-web-app)
6. [Flutter Project Setup](#flutter-project-setup)
7. [FlutterFire Configuration](#flutterfire-configuration)
8. [Firestore Database Setup](#firestore-database-setup)
9. [Android Configuration](#android-configuration)
10. [Web Configuration](#web-configuration)
11. [Running the App Locally](#running-the-app-locally)
12. [Deploying to Firebase Hosting](#deploying-to-firebase-hosting)
13. [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have the following installed:

- **Flutter SDK**: 3.24.3 or higher
- **Dart SDK**: 3.5.3 or higher
- **Android Studio** with Android SDK (for Android development)
  - **Android SDK**: API level 34 (Android 14)
  - **Android Build Tools**: 34.0.0 or higher
  - **Android NDK**: 25.1.8937393 (automatically installed)
- **Java Development Kit (JDK)**: 11 or higher
- **Visual Studio Code** or **Android Studio** (recommended IDEs)
- **Node.js**: 16.0 or higher (for Firebase CLI)
- **Google Chrome** (for web development)
- **Git** (for version control)

**Android Setup Verification:**

```bash
# Check Android SDK path
echo $ANDROID_HOME  # macOS/Linux
echo %ANDROID_HOME%  # Windows

# Verify Android SDK tools
sdkmanager --list
```

Verify your Flutter installation:

```bash
flutter doctor
```

## Installing Firebase CLI

### 1. Set up development environment

**Set Android SDK environment variables:**

**Windows:**

```bash
# Add to System Environment Variables
ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools
```

**macOS/Linux:**

```bash
# Add to ~/.bashrc or ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
```

### 2. Install Firebase CLI globally

```bash
npm install -g firebase-tools
```

### 2. Verify installation

```bash
firebase --version
```

### 3. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

**Add Dart pub global to PATH:**

- Windows: Add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH
- macOS/Linux: Add `~/.pub-cache/bin` to PATH

### 4. Login to Firebase

```bash
firebase login
```

This will open your browser for Google authentication. Sign in with your Google account.

## Creating Firebase Project

### 1. Create a new Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `crud-contacts` (or your preferred name)
4. Choose whether to enable Google Analytics (optional)
5. Click **"Create project"**

### 2. Note your Project ID

After creation, note your **Project ID** from the Firebase Console. You'll need this for configuration.

**Important:** Your project ID will be used in:

- `firebase.json` configuration
- Web hosting URL: `https://your-project-id.web.app`
- Android app configuration
- Firestore database rules

### 3. Enable required Firebase services

1. **Firestore Database**: Go to Build → Firestore Database → Create database
2. **Firebase Hosting**: Go to Build → Hosting → Get started
3. **Authentication** (optional): Go to Build → Authentication → Get started

**Note:** We'll configure these in detail in later sections.

## Adding Android App

### 1. Register Android app in Firebase Console

1. In your Firebase project, click **"Add app"** → **Android**
2. Enter the following details:
   - **Android package name**: `com.example.contacts.contacts_crud_app`
   - **App nickname**: `Contacts CRUD Android` (optional)
   - **Debug signing certificate SHA-1**: (generate using command below)

### 2. Generate SHA-1 certificate fingerprint

For debug builds:

```bash
cd android
./gradlew signingReport
```

Or use keytool directly:

**On Windows:**

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**On macOS/Linux:**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**If keytool is not found, use full path:**

```bash
# Windows (adjust path based on your Java installation)
"C:\Program Files\Java\jdk-11.0.x\bin\keytool.exe" -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA-1** fingerprint and paste it in the Firebase Console.

### 3. Download google-services.json

1. Click **"Download google-services.json"**
2. Place the file in: `android/app/google-services.json`

## Adding Web App

### 1. Register Web app in Firebase Console

1. In your Firebase project, click **"Add app"** → **Web**
2. Enter the following details:
   - **App nickname**: `Contacts CRUD Web`
   - **Firebase Hosting**: Check this option
3. Register the app and note the Firebase configuration object

### 2. Note Web Configuration

Save the Firebase config object for later use:

```javascript
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef",
};
```

## Flutter Project Setup

### 1. Clone or create the Flutter project

If cloning from GitHub:

```bash
git clone https://github.com/ananyaakamat/flutter-firebase-crud-contacts.git
cd flutter-firebase-crud-contacts/contacts_crud_app
```

If creating from scratch:

```bash
flutter create contacts_crud_app
cd contacts_crud_app
```

### 2. Add Firebase dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Firebase dependencies
  firebase_core: ^3.15.2
  cloud_firestore: ^5.6.12

  # UI and Form dependencies
  flutter_form_builder: ^9.4.1
  form_builder_validators: ^11.0.0

  # State management and utilities
  provider: ^6.1.2
  intl: ^0.19.0
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Initialize Firebase in your app

Update your `lib/main.dart` to initialize Firebase:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/contact_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
      child: MaterialApp(
        title: 'CRUD Firebase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

### 4. Initialize Firebase in your app

Update your `lib/main.dart` to initialize Firebase:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/contact_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
      child: MaterialApp(
        title: 'CRUD Firebase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
```

## FlutterFire Configuration

### 1. Configure FlutterFire

Run the FlutterFire CLI to automatically configure your platforms:

```bash
flutterfire configure
```

This will:

- Prompt you to select your Firebase project
- Ask which platforms to configure (select Android and Web)
- Generate `lib/firebase_options.dart`
- Update platform-specific configuration files

### 2. Select platforms

When prompted, select:

- ✅ Android
- ✅ Web
- ❌ iOS (unless needed)
- ❌ macOS (unless needed)
- ❌ Windows (unless needed)

## Firestore Database Setup

### 1. Create Firestore Database

1. Go to Firebase Console → **Build** → **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select your preferred location
5. Click **"Done"**

### 2. Update Firestore Security Rules

Go to **Firestore Database** → **Rules** and update with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Rules for contacts collection
    match /contacts/{contactId} {
      // Allow reads for all users
      allow read: if true;

      // Allow writes only if the data is valid
      allow write: if validateContact(request.resource.data);

      // Allow deletes for all users
      allow delete: if true;
    }
  }

  // Validation function for contact data
  function validateContact(data) {
    return data.keys().hasAll(['name', 'contactNumber', 'createdAt', 'updatedAt', 'createdBy']) &&
           data.keys().hasOnly(['name', 'contactNumber', 'createdAt', 'updatedAt', 'createdBy']) &&
           // Name validation: string, max 40 chars, letters and spaces only
           data.name is string &&
           data.name.size() > 0 &&
           data.name.size() <= 40 &&
           data.name.matches('[A-Za-z ]+') &&
           // Contact number validation: string, exactly 10 digits
           data.contactNumber is string &&
           data.contactNumber.size() == 10 &&
           data.contactNumber.matches('[0-9]{10}') &&
           // Timestamps should be server timestamps
           data.createdAt is timestamp &&
           data.updatedAt is timestamp &&
           // CreatedBy should be a string
           data.createdBy is string;
  }
}
```

Click **"Publish"** to save the rules.

## Android Configuration

### 1. Update Android Gradle files

**File: `android/settings.gradle`**

Add the Google Services plugin:

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.3.2" apply false
    // START: FlutterFire Configuration
    id "com.google.gms.google-services" version "4.3.15" apply false
    // END: FlutterFire Configuration
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false
}
```

**File: `android/app/build.gradle`**

Add the plugin at the top:

```gradle
plugins {
    id "com.android.application"
    // START: FlutterFire Configuration
    id 'com.google.gms.google-services'
    // END: FlutterFire Configuration
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}
```

### 2. Update Android Gradle Plugin version

**File: `android/gradle/wrapper/gradle-wrapper.properties`**

Update the distributionUrl:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.6-all.zip
```

### 3. Verify google-services.json placement

Ensure `google-services.json` is in the correct location:

```
android/
  app/
    google-services.json  ← Must be here
    build.gradle
```

### 4. Update Android manifest (Optional)

**File: `android/app/src/main/AndroidManifest.xml`**

Update the app label:

```xml
<application
    android:label="CRUD Firebase"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

## Web Configuration

### 1. Initialize Firebase for Web

```bash
firebase init hosting
```

When prompted:

- **Select Firebase project**: Choose your created project
- **Public directory**: Enter `build/web`
- **Configure as SPA**: Yes
- **Overwrite index.html**: No

### 2. Update firebase.json

Ensure your `firebase.json` looks like this:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 3. Update web/index.html

Ensure the title and meta tags are updated:

```html
<title>CRUD Firebase</title>
<meta
  name="description"
  content="CRUD Firebase - Contact management application with real-time sync."
/>
<meta name="apple-mobile-web-app-title" content="CRUD Firebase" />
```

## Running the App Locally

### 1. Test Android version

Connect an Android device or start an emulator, then run:

```bash
flutter run
```

Or specify the device:

```bash
flutter run -d <device-id>
```

### 2. Test Web version

```bash
flutter run -d chrome
```

Or with a specific port:

```bash
flutter run -d chrome --web-port=8080
```

### 3. Build for testing

**Android Debug APK:**

```bash
flutter build apk --debug
```

**Web Build:**

```bash
flutter build web --release
```

## Deploying to Firebase Hosting

### 1. Build web version

```bash
flutter build web --release
```

### 2. Deploy to Firebase Hosting

```bash
firebase deploy --only hosting
```

### 3. Deploy Firestore rules and indexes

```bash
firebase deploy --only firestore
```

### 4. Deploy everything

```bash
firebase deploy
```

### 5. Access your deployed app

After deployment, your app will be available at:

```
https://your-project-id.web.app
```

## Troubleshooting

### Setting up Core Project Files

If you're creating the project from scratch, you'll need to create these essential files:

#### Contact Model (`lib/models/contact.dart`)

```dart
class Contact {
  final String id;
  final String name;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Contact({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactNumber': contactNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map, String id) {
    return Contact(
      id: id,
      name: map['name'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? 'anonymous',
    );
  }
}

class ContactValidator {
  static String? getNameErrorMessage(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    if (name.length > 40) return 'Name must be 40 characters or less';
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(name)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? getContactNumberErrorMessage(String number) {
    if (number.trim().isEmpty) return 'Contact number is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(number)) {
      return 'Contact number must be exactly 10 digits';
    }
    return null;
  }
}
```

#### Contact Service (`lib/services/contact_service.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';

class ContactService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'contacts';

  static Stream<List<Contact>> getContactsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Contact.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> createContact(String name, String contactNumber) async {
    await _firestore.collection(_collection).add({
      'name': name.trim(),
      'contactNumber': contactNumber.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': 'user',
    });
  }

  static Future<void> updateContact(
      String id, String name, String contactNumber) async {
    await _firestore.collection(_collection).doc(id).update({
      'name': name.trim(),
      'contactNumber': contactNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteContact(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  static Future<bool> isContactDuplicate(String name, String contactNumber,
      {String? excludeId}) async {
    Query query = _firestore.collection(_collection);

    if (excludeId != null) {
      query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
    }

    final nameQuery = await query.where('name', isEqualTo: name.trim()).get();
    final numberQuery = await query
        .where('contactNumber', isEqualTo: contactNumber.trim())
        .get();

    return nameQuery.docs.isNotEmpty || numberQuery.docs.isNotEmpty;
  }
}
```

**Note:** For the complete UI components (ContactProvider, HomeScreen, widgets), refer to the GitHub repository or build them step by step following Flutter best practices.

### Common Issues & Solutions

## Troubleshooting

### Common Android Issues

**1. Build failures with Android SDK 34+ (JdkImageTransform errors)**

This is a critical issue that occurs with newer Android SDK versions. The error typically shows:

```
e: Daemon compilation failed: Could not connect to Kotlin compile daemon
java.lang.RuntimeException: Could not connect to Kotlin compile daemon
```

**Root Cause:** Gradle wrapper and Android Gradle Plugin version mismatch with Android SDK 34+.

**Complete Solution:**

**Step 1:** Update Gradle wrapper version
File: `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.6-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

**Step 2:** Update Android Gradle Plugin version
File: `android/settings.gradle`

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.3.2" apply false
    // START: FlutterFire Configuration
    id "com.google.gms.google-services" version "4.3.15" apply false
    // END: FlutterFire Configuration
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false
}
```

**Step 3:** Verify Android configuration
File: `android/app/build.gradle`

```gradle
android {
    namespace = "com.example.contacts.contacts_crud_app"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    defaultConfig {
        applicationId = "com.example.contacts.contacts_crud_app"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

**Step 4:** Clean and rebuild

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

**Expected Results:**

- Build time: ~60-120 seconds (depending on system)
- APK size: ~45MB for debug build
- Successful installation on Android devices
- Both debug and release builds working
- AAB generation successful for Play Store

**2. Google Services plugin errors**

- Verify `google-services.json` is in `android/app/`
- Check that Google Services plugin is added to both `settings.gradle` and `app/build.gradle`

**3. SHA-1 certificate issues**

- Regenerate SHA-1 using the keytool command
- Add SHA-1 to Firebase Console → Project Settings → General → Android apps

**4. Kotlin compilation daemon issues**

If you encounter Kotlin compilation errors after the above fix:

```bash
# Stop all Gradle daemons
./gradlew --stop

# Clean everything
flutter clean
cd android
./gradlew clean
cd ..

# Rebuild
flutter pub get
flutter build apk --debug
```

**5. NDK compatibility issues**

Ensure NDK version compatibility:

- NDK Version: 25.1.8937393 (automatically managed by Flutter)
- Check in Android Studio → SDK Manager → SDK Tools → NDK

**6. Memory issues during build**

For large projects or systems with limited RAM:

```bash
# Add to android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
```

### Common Web Issues

**1. Firebase configuration errors**

- Ensure `firebase_options.dart` is generated correctly
- Verify web configuration in Firebase Console

**2. Hosting deployment issues**

- Run `flutter clean` and rebuild web version
- Check `firebase.json` configuration
- Ensure you're in the correct directory when running `firebase deploy`

**3. Firestore connection issues**

- Verify Firestore is enabled in Firebase Console
- Check Firestore rules are published
- Ensure network connectivity

### General Flutter Issues

**1. Dependencies issues**

```bash
flutter clean
flutter pub get
```

**2. Build cache issues**

```bash
flutter clean
flutter pub cache clean
flutter pub get
```

**3. Platform-specific issues**

```bash
flutter doctor
```

### Getting Help

- **Flutter Documentation**: https://docs.flutter.dev/
- **Firebase Documentation**: https://firebase.google.com/docs
- **FlutterFire Documentation**: https://firebase.flutter.dev/docs/overview
- **GitHub Issues**: Report issues in the project repository

## Project Structure

After successful setup, your project structure should look like:

```
contacts_crud_app/
├── android/
│   ├── app/
│   │   ├── google-services.json          ← Firebase Android config
│   │   ├── build.gradle                  ← Google services plugin
│   │   └── src/main/AndroidManifest.xml  ← App label configuration
│   ├── build.gradle                      ← Root build configuration
│   ├── settings.gradle                   ← Google services plugin
│   └── gradle/wrapper/
│       └── gradle-wrapper.properties     ← Gradle 8.6 configuration
├── lib/
│   ├── firebase_options.dart             ← Generated by FlutterFire CLI
│   ├── main.dart                         ← App entry point with Firebase init
│   ├── models/
│   │   └── contact.dart                  ← Contact model and validation
│   ├── providers/
│   │   └── contact_provider.dart         ← State management
│   ├── screens/
│   │   └── home_screen.dart              ← Main app screen
│   ├── services/
│   │   └── contact_service.dart          ← Firestore CRUD operations
│   └── widgets/
│       ├── contact_form_dialog.dart      ← Create/Edit contact form
│       ├── contact_list_widget.dart      ← Contact display widgets
│       └── search_widget.dart            ← Search functionality
├── web/
│   ├── index.html                        ← Updated title and meta tags
│   ├── manifest.json                     ← Web app manifest
│   ├── favicon.png                       ← App icon (crud.png)
│   └── icons/                            ← Web app icons
│       ├── Icon-192.png                  ← 192px icon
│       └── Icon-512.png                  ← 512px icon
├── assets/
│   └── icons/
│       ├── crud_icon.png                 ← App icon asset
│       └── app_icon.png                  ← Default app icon
├── firebase.json                         ← Firebase hosting config
├── firestore.rules                       ← Firestore security rules
├── firestore.indexes.json               ← Firestore indexes
├── pubspec.yaml                          ← Firebase dependencies
└── README.md                             ← Project documentation
```

## Required Project Files

If creating the project from scratch, you'll need to create these key files:

### Contact Model (`lib/models/contact.dart`)

```dart
class Contact {
  final String id;
  final String name;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Contact({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactNumber': contactNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map, String id) {
    return Contact(
      id: id,
      name: map['name'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? 'anonymous',
    );
  }
}

class ContactValidator {
  static String? getNameErrorMessage(String name) {
    if (name.trim().isEmpty) return 'Name is required';
    if (name.length > 40) return 'Name must be 40 characters or less';
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(name)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? getContactNumberErrorMessage(String number) {
    if (number.trim().isEmpty) return 'Contact number is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(number)) {
      return 'Contact number must be exactly 10 digits';
    }
    return null;
  }
}
```

### Firestore Service (`lib/services/contact_service.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';

class ContactService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'contacts';

  static Stream<List<Contact>> getContactsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Contact.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<void> createContact(String name, String contactNumber) async {
    await _firestore.collection(_collection).add({
      'name': name.trim(),
      'contactNumber': contactNumber.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': 'user',
    });
  }

  static Future<void> updateContact(
      String id, String name, String contactNumber) async {
    await _firestore.collection(_collection).doc(id).update({
      'name': name.trim(),
      'contactNumber': contactNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteContact(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  static Future<bool> isContactDuplicate(String name, String contactNumber,
      {String? excludeId}) async {
    Query query = _firestore.collection(_collection);

    if (excludeId != null) {
      query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
    }

    final nameQuery = await query.where('name', isEqualTo: name.trim()).get();
    final numberQuery = await query
        .where('contactNumber', isEqualTo: contactNumber.trim())
        .get();

    return nameQuery.docs.isNotEmpty || numberQuery.docs.isNotEmpty;
  }
}
```

---

**Congratulations!** 🎉 Your Flutter Firebase CRUD application is now fully configured and ready for development and deployment on both Android and Web platforms.

## Additional Development Tips

### Setting up IDE Extensions

**VS Code Extensions:**

- Dart
- Flutter
- Firebase
- Flutter Widget Snippets
- Bracket Pair Colorizer

**Android Studio Plugins:**

- Flutter
- Dart
- Firebase

### Development Workflow

1. **Start development server:**

```bash
flutter run -d chrome --web-port=8080
```

2. **Hot reload during development:**
   Press `r` in terminal or `Ctrl+S` in IDE

3. **Test on multiple platforms:**

```bash
# Android
flutter run -d android

# Web
flutter run -d chrome

# Check available devices
flutter devices
```

### Common Development Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get

# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for production
flutter build web --release
flutter build apk --release
```

### Firebase Development Tips

1. **Monitor Firestore usage:**

   - Go to Firebase Console → Usage and billing
   - Set up budget alerts

2. **View Firestore data:**

   - Firebase Console → Build → Firestore Database → Data

3. **Check hosting activity:**

   - Firebase Console → Build → Hosting → Dashboard

4. **Monitor performance:**
   - Firebase Console → Build → Performance (if enabled)

For any issues or questions, refer to the troubleshooting section or consult the official documentation links provided above.
