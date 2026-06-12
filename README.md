# Shifa Healthcare Education System

Shifa is a modern, premium, production-ready cross-platform Healthcare Education Mobile Application and Admin Control Panel designed for medical students and healthcare professionals. It offers organized video lectures for subjects like Anatomy, Physiology, Pathology, Surgery, and more, complete with bookmarks, streak tracking, note-taking, search capabilities, and offline compatibility.

This project is organized as a monorepo containing:
1. **`shifa_mobile`**: Cross-platform Flutter Mobile Application.
2. **`shifa_admin`**: Web-based React Administrative Dashboard.

---

## Repository Structure

```
shifa/
├── README.md                 # Root documentation (this file)
├── firestore.rules           # Cloud Firestore Security Rules
├── storage.rules             # Cloud Storage Security Rules
├── shifa_mobile/             # Flutter project directory
└── shifa_admin/              # React/Vite Admin Dashboard project directory
```

---

## 1. Cloud Firestore Database Schema

### `users` (Collection)
* Document ID: `uid` (Firebase Authentication User ID)
```json
{
  "uid": "user_12345",
  "email": "student@medical.edu",
  "displayName": "Jane Doe",
  "photoUrl": "https://lh3.googleusercontent.com/...",
  "role": "student", // 'student' | 'admin'
  "createdAt": "2026-06-12T11:00:00.000Z",
  "lastActiveDate": "2026-06-12T11:00:00.000Z",
  "streak": 5,
  "totalVideosWatched": 12,
  "completedChapters": ["anatomy_upper_limb"],
  "completedSubjects": []
}
```

### `subjects` (Collection)
* Document ID: `subjectId` (e.g., `anatomy`, `physiology`)
```json
{
  "id": "anatomy",
  "title": "Anatomy",
  "description": "Comprehensive guide to human structure and gross anatomy.",
  "thumbnailUrl": "https://firebasestorage.googleapis.com/.../anatomy.jpg",
  "chaptersCount": 5,
  "createdAt": "2026-06-12T00:00:00.000Z",
  "updatedAt": "2026-06-12T00:00:00.000Z"
}
```

### `chapters` (Collection)
* Document ID: `chapterId` (e.g., `anatomy_upper_limb`)
```json
{
  "id": "anatomy_upper_limb",
  "subjectId": "anatomy",
  "title": "Upper Limb",
  "description": "Bones, muscles, nerves, and blood supply of the shoulder, arm, and hand.",
  "videosCount": 5,
  "createdAt": "2026-06-12T00:00:00.000Z"
}
```

### `videos` (Collection)
* Document ID: `videoId` (e.g., `anatomy_ul_intro`)
```json
{
  "id": "anatomy_ul_intro",
  "subjectId": "anatomy",
  "chapterId": "anatomy_upper_limb",
  "title": "Introduction to Upper Limb Anatomy",
  "description": "General overview of the osteology and fascial compartments of the upper extremity.",
  "youtubeUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "thumbnailUrl": "https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg",
  "duration": "12:45",
  "createdAt": "2026-06-12T00:00:00.000Z",
  "updatedAt": "2026-06-12T00:00:00.000Z"
}
```

### `progress` (Collection)
* Document ID: `userId_videoId`
```json
{
  "userId": "user_12345",
  "videoId": "anatomy_ul_intro",
  "subjectId": "anatomy",
  "chapterId": "anatomy_upper_limb",
  "watchTime": 345, // Last stopped video time in seconds
  "isCompleted": true,
  "lastWatchedAt": "2026-06-12T11:15:00.000Z"
}
```

### `bookmarks` (Collection)
* Document ID: `userId_itemId`
```json
{
  "userId": "user_12345",
  "itemId": "anatomy_ul_intro",
  "itemType": "video", // 'subject' | 'chapter' | 'video'
  "bookmarkedAt": "2026-06-12T11:10:00.000Z"
}
```

### `notes` (Collection)
* Document ID: Auto-generated UUID
```json
{
  "id": "note_abcd1234",
  "userId": "user_12345",
  "videoId": "anatomy_ul_intro",
  "noteText": "The brachial plexus root starts from C5 to T1 nerve segments.",
  "timestampInSeconds": 145, // Time code in the video
  "createdAt": "2026-06-12T11:12:00.000Z"
}
```

---

## 2. Setup Instructions

### Pre-requisites
Make sure you have installed:
* [Node.js](https://nodejs.org) (v18 or higher)
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
* VS Code or Android Studio with Flutter plugin installed.

### Developing the React Web Admin Dashboard (`shifa_admin`)
1. Open a terminal in `shifa_admin/`
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the development server locally:
   ```bash
   npm run dev
   ```
4. Access the dashboard at `http://localhost:5173`.
5. Run lint and type checking:
   ```bash
   npm run lint
   ```
6. Build for production deployment:
   ```bash
   npm run build
   ```

### Developing the Flutter Mobile Application (`shifa_mobile`)
1. Setup the Flutter environment on your workspace machine.
2. Navigate to `shifa_mobile/` directory:
   ```bash
   cd shifa_mobile
   ```
3. Initialize platform project folders (Android/iOS/Web etc.) if they do not exist:
   ```bash
   flutter create .
   ```
4. Get dependencies:
   ```bash
   flutter pub get
   ```
5. Run the mobile application:
   * On Android emulator or connected device:
     ```bash
     flutter run -d android
     ```
   * On iOS Simulator (requires macOS):
     ```bash
     flutter run -d ios
     ```
   * On Web browser (for layout testing):
     ```bash
     flutter run -d chrome
     ```

---

## 3. Firebase Setup for Custom Environments
To link this system with your own live Firebase account, follow these steps:

1. **Firestore Database**: Create a new Firestore Database instance in your Firebase Console and deploy `firestore.rules`.
2. **Cloud Storage**: Set up Firebase Storage and deploy `storage.rules`.
3. **Web Dashboard Setup**:
   - Register a Web App in your Firebase console.
   - Copy the Firebase SDK keys and paste them into `shifa_admin/src/services/firebaseConfig.ts`.
   - Update `shifa_admin/src/services/db.ts` to set `const USE_MOCK = false;`.
4. **Mobile App Setup**:
   - Install the Flutterfire CLI.
   - Run `flutterfire configure` in `shifa_mobile/` and select your Firebase project.
   - Ensure Auth methods (Email/Password, Google Sign-In) are enabled in your console.
