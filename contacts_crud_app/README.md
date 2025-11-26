# Contacts CRUD App

A modern Flutter application for managing contacts with real-time synchronization using Firebase Firestore. This app provides a complete CRUD (Create, Read, Update, Delete) interface with responsive design for both mobile and web platforms.

![App Icon](assets/icons/app_icon.png)

## 🌟 Features

### Core Functionality

- ✅ **Create Contacts** - Add new contacts with name and phone number validation
- ✅ **Read Contacts** - View all contacts in a responsive layout (list/table)
- ✅ **Update Contacts** - Edit existing contact information
- ✅ **Delete Contacts** - Remove contacts with confirmation dialog
- ✅ **Real-time Sync** - Changes are synchronized across all devices instantly
- ✅ **Search & Filter** - Find contacts quickly with live search functionality
- ✅ **Offline Support** - Works offline with Firebase local persistence
- ✅ **Offline Cache + Auto Sync** - Full offline functionality with automatic synchronization

### User Experience

- 🎨 **Material Design 3** - Modern, clean interface following latest design guidelines
- 📱 **Responsive Design** - Adaptive layout for mobile, tablet, and web
- 🔍 **Live Search** - Instant filtering as you type
- ✨ **Smart Validation** - Real-time field validation with helpful error messages
- 🌐 **Multi-platform** - Runs on Android, iOS, Web, Windows, and macOS
- 🔄 **Auto-refresh** - Automatic updates when data changes
- 💾 **Persistent Storage** - Data saved securely in Firebase Firestore
- 📡 **Offline-First Design** - Complete CRUD operations work without internet connection
- 🔄 **Automatic Sync** - Seamless data synchronization when connectivity returns
- 🟡 **Pending Status** - Visual indicators for operations awaiting sync
- 🌐 **Network Awareness** - Real-time online/offline status detection

## 🚀 Live Demo

- **Web Application**: [https://crud-8aa32.web.app](https://crud-8aa32.web.app)
- **Firebase Console**: [Project Dashboard](https://console.firebase.google.com/project/crud-8aa32/overview)

## 📱 Screenshots

### Mobile View

- **Home Screen**: Contact list with floating action button
- **Add Contact**: Form dialog with validation
- **Search**: Live filtering with results count

### Web View

- **Table Layout**: Responsive data table with sorting and actions
- **Responsive Design**: Adapts from mobile list to desktop table
- **Navigation**: Intuitive toolbar with search and create actions

## 🛠 Technology Stack

### Frontend

- **Framework**: Flutter 3.24.3
- **Language**: Dart 3.5.3+
- **UI Library**: Material Design 3
- **State Management**: Provider Pattern
- **Form Handling**: Flutter Form Builder
- **Network Detection**: connectivity_plus package
- **Offline Persistence**: Firebase Firestore offline cache

### Backend

- **Database**: Firebase Firestore
- **Authentication**: Firebase Core
- **Hosting**: Firebase Hosting
- **Real-time Sync**: Firestore real-time listeners

### Development Tools

- **IDE**: Visual Studio Code
- **Version Control**: Git
- **Build System**: Gradle 8.6 + Android Gradle Plugin 8.3.2
- **Firebase CLI**: 14.26.0
- **FlutterFire CLI**: 1.3.1

## 📋 Requirements

### Development Environment

- **Flutter SDK**: 3.24.3 or higher
- **Dart SDK**: 3.5.3 or higher
- **Android SDK**: API 21+ (Android 5.0+)
- **Java**: JDK 17 or JDK 21
- **Firebase CLI**: Latest version

### Device Compatibility

- **Android**: API 21+ (Android 5.0 Lollipop and above)
- **iOS**: iOS 12.0 and above
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **Desktop**: Windows 10+, macOS 10.14+, Linux

## 🏗 Project Structure

```
lib/
├── models/                 # Data models and validation
│   └── contact.dart       # Contact model with validation logic
├── providers/             # State management
│   └── contact_provider.dart  # Contact operations and state
├── screens/               # App screens
│   └── home_screen.dart   # Main application screen
├── services/              # Business logic
│   ├── contact_service.dart   # Firestore CRUD operations
│   └── network_service.dart   # Online/offline status detection
├── widgets/               # Reusable UI components
│   ├── contact_form_dialog.dart   # Add/Edit contact form
│   ├── contact_list_widget.dart   # Responsive contact display
│   └── search_widget.dart         # Search functionality
├── firebase_options.dart  # Firebase configuration
└── main.dart              # App entry point

android/                   # Android-specific configuration
├── app/
│   ├── build.gradle      # Android build configuration
│   └── google-services.json  # Firebase Android config
└── gradle/wrapper/       # Gradle wrapper configuration

web/                       # Web-specific configuration
build/                     # Build output directory
assets/                    # App assets
├── icons/                # Application icons
└── ...

test/                      # Unit and widget tests
firebase.json              # Firebase project configuration
firestore.rules           # Firestore security rules
firestore.indexes.json    # Firestore database indexes
pubspec.yaml              # Flutter dependencies and configuration
```

## 📝 Data Model

### Contact Schema

```dart
class Contact {
  final String id;           // Unique identifier
  final String name;         // Contact name (1-40 characters, letters and spaces only)
  final String contactNumber; // Phone number (exactly 10 digits)
  final DateTime createdAt;  // Creation timestamp
  final DateTime updatedAt;  // Last modification timestamp
  final String createdBy;    // Creator identifier
}
```

### Validation Rules

- **Name**: 1-40 characters, letters and spaces only, required
- **Contact Number**: Exactly 10 digits, required
- **Duplicate Prevention**: No two contacts can have the same phone number

### Firestore Structure

```
/contacts/{contactId}
{
  name: string,
  contactNumber: string,
  createdAt: timestamp,
  updatedAt: timestamp,
  createdBy: string
}
```

## 📡 Offline Functionality

### Complete Offline Support

The app implements comprehensive offline functionality using Firebase Firestore's offline persistence with automatic synchronization:

#### Core Offline Features

- ✅ **Full CRUD Operations Offline** - Create, read, update, and delete contacts without internet
- ✅ **Local Cache Storage** - All data cached locally for instant access
- ✅ **Queued Writes** - Offline operations automatically queued for sync
- ✅ **Immediate UI Updates** - Changes appear instantly in the UI
- ✅ **Automatic Sync** - Operations sync automatically when connectivity returns
- ✅ **Real-time Conflict Resolution** - Server data takes precedence during sync
- ✅ **Visual Status Indicators** - Clear feedback for sync status

#### Technical Implementation

**Offline Persistence:**

```dart
// Enabled at app initialization
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);
```

**Fire-and-Forget Operations:**

```dart
// Operations don't wait for server response
unawaited(_contactService.createContact(name, contactNumber));
// Dialog closes immediately, queues operation locally
```

**Real-time Sync Detection:**

```dart
// Snapshots include metadata for pending writes
.snapshots(includeMetadataChanges: true)
contact.pending = doc.metadata.hasPendingWrites;
```

#### User Experience

**Online State:**

- All operations complete normally
- Real-time updates across devices
- Immediate validation and feedback

**Offline State:**

- Orange "You are offline" banner appears
- All CRUD operations work immediately
- Orange sync icons appear on contacts with pending changes
- Dialog boxes close instantly without waiting for server
- Data persists locally and syncs when online

**Back Online:**

- Offline banner disappears automatically
- Pending changes sync to cloud Firestore
- Sync indicators disappear after successful upload
- Real-time updates resume across all devices

#### Network Status Detection

```dart
class NetworkService {
  static Stream<bool> get onStatusChanged;
  static Future<void> init();
}

// Usage in UI
Consumer<ContactProvider>(
  builder: (context, provider, child) {
    if (!provider.isOnline) {
      return OfflineBanner(); // Show offline indicator
    }
    return SizedBox.shrink();
  },
)
```

#### Visual Feedback

**Offline Banner:**

- Displayed prominently when device is offline
- Orange background with cloud-off icon
- Clear message: "You are offline. Changes will sync when connection is restored."

**Pending Sync Indicators:**

- Orange sync icons on contacts with pending writes
- Tooltip shows "Syncing changes..." message
- Visible in both list and table views
- Automatically disappear after successful sync

#### Supported Platforms

- **Android**: Full offline support with local SQLite cache
- **Web**: IndexedDB for local storage and queued operations
- **iOS**: Core Data for local persistence (when deployed)
- **Desktop**: SQLite for local caching

#### Data Consistency

**Conflict Resolution:**

- Server data always takes precedence
- Local changes merge with server updates
- Timestamps used for conflict detection
- No data loss during sync process

**Validation:**

- Client-side validation for immediate feedback
- Server-side validation during sync
- Duplicate detection handled gracefully
- Invalid operations logged but don't block UI

## 🔧 Installation & Setup

### Prerequisites

1. **Install Flutter**

   ```bash
   # Download from https://flutter.dev/docs/get-started/install
   flutter --version  # Verify installation
   ```

2. **Install Firebase CLI**

   ```bash
   npm install -g firebase-tools
   firebase --version
   ```

3. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd contacts_crud_app
   ```

### Firebase Setup

1. **Create Firebase Project**

   ```bash
   firebase login
   firebase init
   ```

2. **Configure FlutterFire**

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

### Dependencies Installation

```bash
# Install Flutter dependencies
flutter pub get

# Key dependencies installed:
# - firebase_core: ^3.15.2          # Firebase initialization
# - cloud_firestore: ^5.6.12       # Database with offline support
# - provider: ^6.1.2               # State management
# - connectivity_plus: ^4.0.0      # Network status detection
# - flutter_form_builder: ^9.4.1   # Form handling
# - intl: ^0.19.0                  # Date formatting

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

## 🚀 Running the Application

### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d chrome             # Run on Chrome
flutter run -d windows            # Run on Windows
flutter run -d <device-id>         # Run on specific device
```

### Web Development

```bash
# Run web version with hot reload
flutter run -d chrome --web-port=8080

# Build for web
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Android Development

```bash
# Run on Android device/emulator
flutter run -d android

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Install on specific device
adb -s <device-id> install build/app/outputs/flutter-apk/app-debug.apk
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/contact_test.dart
```

### Test Coverage

- **Unit Tests**: Contact model validation
- **Widget Tests**: Form validation and UI components
- **Integration Tests**: End-to-end user workflows

### Validation Testing

- ✅ Name validation (length, character restrictions)
- ✅ Phone number validation (format, uniqueness)
- ✅ Form submission with invalid data
- ✅ CRUD operations success/failure scenarios
- ✅ Offline operation handling and sync behavior
- ✅ Network status detection accuracy
- ✅ Pending write indicators and visual feedback

## 🏗 Build & Deployment

### Web Deployment (Firebase Hosting)

```bash
# Build production web version
flutter build web --web-renderer canvaskit

# Deploy to Firebase
firebase deploy --only hosting

# Access at: https://crud-8aa32.web.app
```

### Android Deployment

```bash
# Debug build for testing
flutter build apk --debug

# Release build for distribution
flutter build apk --release

# App Bundle for Google Play Store
flutter build appbundle --release
```

### iOS Deployment

```bash
# Build for iOS (requires macOS and Xcode)
flutter build ios --release
```

## 📊 Firebase Configuration

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /contacts/{contactId} {
      allow read: if true;
      allow write: if validateContact(request.resource.data);
      allow delete: if true;
    }
  }

  function validateContact(data) {
    return data.keys().hasAll(['name', 'contactNumber', 'createdAt', 'updatedAt', 'createdBy']) &&
           data.name is string &&
           data.name.size() > 0 &&
           data.name.size() <= 40 &&
           data.name.matches('[A-Za-z ]+') &&
           data.contactNumber is string &&
           data.contactNumber.size() == 10 &&
           data.contactNumber.matches('[0-9]{10}');
  }
}
```

### Firebase Project Configuration

- **Project ID**: crud-8aa32
- **Web App ID**: 1:60557841684:web:3e2867ac435bc4e5195e01
- **Android App ID**: 1:60557841684:android:49efbc7ba4381fe1195e01
- **Hosting URL**: https://crud-8aa32.web.app

## 🎨 UI/UX Features

### Responsive Design

- **Mobile (< 600px)**: List view with cards
- **Desktop (≥ 600px)**: Table view with sorting and vertical scrolling
- **Adaptive Icons**: Material Design adaptive icons
- **Theme**: Material Design 3 with custom color scheme

### User Interactions

- **Smart Save Button**: Enables when any field has content
- **Live Validation**: Real-time feedback during form input
- **Search as You Type**: Instant filtering with highlight
- **Loading States**: Progress indicators for async operations
- **Error Handling**: User-friendly error messages
- **Success Feedback**: Confirmation messages for completed actions

### Form Behavior

- **Save Button Logic**: Disabled initially, enables when user enters any character
- **Validation on Save**: All validations performed when Save is clicked
- **Clear Error Messages**: Specific error messages for each validation rule
- **Responsive Form**: Adapts to different screen sizes

## 🔍 Search & Filtering

### Search Features

- **Live Search**: Results update as you type
- **Case Insensitive**: Finds contacts regardless of case
- **Partial Match**: Matches anywhere in name or phone number
- **Result Counter**: Shows "X of Y" contacts found
- **Clear Search**: Quick clear button
- **No Results State**: Helpful message when no matches found

### Search Implementation

```dart
// Search logic in ContactProvider
void searchContacts(String query) {
  if (query.isEmpty) {
    _contacts = List.from(_allContacts);
  } else {
    _contacts = _allContacts.where((contact) {
      return contact.name.toLowerCase().contains(query.toLowerCase()) ||
             contact.contactNumber.contains(query);
    }).toList();
  }
  notifyListeners();
}
```

## ⚡ Performance Optimizations

### Flutter Optimizations

- **Tree Shaking**: Icons reduced by 99.5% (1.6MB → 8KB)
- **Code Splitting**: Efficient JavaScript bundles
- **Lazy Loading**: Widgets loaded on demand
- **Efficient Rebuilds**: Provider pattern with selective updates

### Firebase Optimizations

- **Local Persistence**: Offline data caching with automatic sync
- **Real-time Listeners**: Efficient data synchronization with metadata changes
- **Optimistic Updates**: Immediate UI feedback without waiting for server
- **Batch Operations**: Efficient multi-document operations
- **Fire-and-Forget Pattern**: Operations queued locally, dialogs close instantly

### Web Performance

- **CanvasKit Renderer**: Better performance for complex UIs
- **Service Worker**: PWA capabilities with offline support
- **CDN Delivery**: Global Firebase hosting with CDN
- **Compressed Assets**: Optimized images and fonts

## 🔒 Security & Validation

### Client-Side Validation

- **Input Sanitization**: Prevents invalid characters
- **Length Limits**: Enforced field length restrictions
- **Format Validation**: Phone number and name format checks
- **Duplicate Prevention**: Checks for existing phone numbers

### Server-Side Security

- **Firestore Rules**: Database-level validation
- **Data Types**: Strict type checking
- **Required Fields**: Ensures all mandatory fields
- **Character Restrictions**: Server-side format validation

### Privacy & Data Protection

- **No Personal Data**: Only stores name and phone number
- **No Authentication**: Public access (demo purposes)
- **Data Encryption**: Firebase handles encryption at rest
- **HTTPS**: All connections encrypted in transit

## 🐛 Troubleshooting

### Common Issues

#### Build Errors

```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Clear Gradle cache (Android)
cd android
./gradlew clean
cd ..
```

#### Firebase Connection Issues

```bash
# Verify Firebase configuration
firebase projects:list
firebase use crud-8aa32

# Check internet connection and Firebase status
```

#### Web Deployment Issues

```bash
# Build with specific renderer
flutter build web --web-renderer canvaskit

# Check Firebase hosting configuration
firebase deploy --only hosting --debug
```

#### Android SDK 34+ Issues

If you encounter build issues with Android SDK 34:

```bash
# Ensure Gradle wrapper is version 8.6
# Update android/gradle/wrapper/gradle-wrapper.properties:
distributionUrl=https\://services.gradle.org/distributions/gradle-8.6-all.zip

# Ensure Android Gradle Plugin is 8.3.2
# In android/settings.gradle:
id "com.android.application" version "8.3.2" apply false
```

### Performance Issues

- **Large Dataset**: Implement pagination for 1000+ contacts
- **Slow Search**: Add debouncing for search input
- **Memory Usage**: Monitor state management efficiency

### Development Tips

- **Hot Reload**: Use for rapid development iterations
- **Flutter Inspector**: Debug widget tree and performance
- **Firebase Console**: Monitor database usage and performance
- **Chrome DevTools**: Debug web version performance

## 🤝 Contributing

### Development Guidelines

1. **Code Style**: Follow Dart style guide
2. **Documentation**: Comment complex logic
3. **Testing**: Write tests for new features
4. **Performance**: Profile before optimizing
5. **Accessibility**: Ensure inclusive design

### Pull Request Process

1. Fork the repository
2. Create feature branch (`feature/new-feature`)
3. Commit changes with descriptive messages
4. Run tests and ensure they pass
5. Submit pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Firebase Team**: For the powerful backend services
- **Material Design**: For the beautiful design system
- **Open Source Community**: For the countless helpful packages

## 📞 Support

For issues, questions, or contributions:

- **Issues**: Create GitHub issues for bug reports
- **Discussions**: Use GitHub discussions for questions
- **Documentation**: [Flutter Documentation](https://flutter.dev/docs)
- **Firebase Help**: [Firebase Documentation](https://firebase.google.com/docs)

## 📈 Future Enhancements

### Planned Features

- [ ] **User Authentication**: Firebase Auth integration
- [ ] **Contact Photos**: Profile picture upload and management
- [ ] **Import/Export**: CSV/VCF file support
- [ ] **Advanced Filtering**: Sort by creation date, alphabetical
- [ ] **Dark Mode**: Theme switching support
- [ ] **Contact Groups**: Organize contacts into categories
- [ ] **Backup & Restore**: Data backup to cloud storage
- [ ] **Contact Sharing**: Share contact information
- [ ] **Internationalization**: Multi-language support
- [ ] **Push Notifications**: Contact update notifications
- [ ] **Enhanced Offline Features**: Conflict resolution UI and sync status details

### Technical Improvements

- [ ] **Pagination**: Handle large datasets efficiently
- [ ] **Caching Strategy**: Improved offline experience
- [ ] **Performance Monitoring**: Firebase Performance integration
- [ ] **Error Reporting**: Crashlytics integration
- [ ] **Analytics**: User interaction tracking
- [ ] **A/B Testing**: Feature flag management

---

**Built with ❤️ using Flutter and Firebase**

_Last updated: November 26, 2025_

## Quick Start Checklist

- [ ] Install Flutter SDK and Firebase CLI
- [ ] Create Firebase project and enable Firestore
- [ ] Run `flutterfire configure` to link project
- [ ] Deploy Firestore security rules
- [ ] Install dependencies with `flutter pub get`
- [ ] Generate launcher icons
- [ ] Test with `flutter run -d chrome`
- [ ] Deploy web version with `firebase deploy`
- [ ] Build Android APK/AAB for distribution

For a complete development setup, follow the detailed instructions in the [Installation & Setup](#installation--setup) section above.
