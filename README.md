# CampusFix

CampusFix is a Flutter app for reporting campus issues and following them through resolution. Students can submit reports with a category, priority, location, description, and photos; staff can review reports and update their status.

## What the app includes

- Student registration, sign-in, profile, and report history
- Incident categories, priorities, locations, and photo attachments
- Live report status tracking: Submitted, In Progress, and Resolved
- Staff dashboard and report-management screens
- Firebase Authentication and Cloud Firestore
- Cloudinary image uploads
- Material 3 interface with light and dark themes

## Screenshots

<p>
  <img src="screeenshoots/Screenshot%202026-11-08%20012308.png" width="220" alt="CampusFix home screen">
  <img src="screeenshoots/Screenshot%202026-11-08%20000247.png" width="220" alt="My reports screen">
  <img src="screeenshoots/Screenshot%202026-11-08%20000315.png" width="220" alt="Report an incident screen">
</p>
<p>
  <img src="screeenshoots/Screenshot%202026-11-07%20222536.png" width="220" alt="Submitted incident details">
  <img src="screeenshoots/Screenshot%202026-11-08%20010140.png" width="220" alt="Resolved incident details">
  <img src="screeenshoots/Screenshot%202026-11-08%20010255.png" width="220" alt="Incident status timeline">
</p>

## App setup

### Requirements

- Flutter SDK and Dart SDK (the project requires Dart `^3.5.0`)
- Node.js and npm (for the Firebase CLI)
- A Firebase project
- A Cloudinary account (needed for photo uploads)

### 1. Get the project dependencies

From the project directory, run:

```bash
flutter pub get
```

### 2. Configure Firebase

1. Create or select a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** under Authentication and create a Cloud Firestore database.
3. Install the Firebase and FlutterFire CLIs, then sign in:

   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```

4. Configure the app for your Firebase project:

   ```bash
   flutterfire configure
   ```

   Select the platforms you intend to run. This generates the Firebase app options used by the app.
5. From the project directory, deploy the Firestore security rules and indexes:

   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

### 3. Configure Cloudinary

1. In Cloudinary, create an **unsigned** image upload preset. Restrict its allowed formats and upload size in the Cloudinary console.
2. Copy `.env.example` to `.env` in the project root and fill in your cloud name and preset:

   ```env
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_unsigned_upload_preset
   ```

   `.env` is local and ignored by Git. Never put a Cloudinary API secret in the app or commit it.

### 4. Run the app

Connect a supported device or start an emulator, then run:

```bash
flutter run
```

To build an Android release APK:

```bash
flutter build apk --release
```

### Staff access

The Firestore rules restrict student and staff roles by email domain. Use an `@alustudent.com` address for a student account and an `@alueducation.com` address for staff. Staff accounts must also have the `staff` role in their Firestore user document.
