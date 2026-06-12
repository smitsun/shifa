# Implementation Plan - Shifa Healthcare Education App

Build a complete, production-ready, cross-platform Healthcare Education Mobile Application (Shifa) for medical students and healthcare professionals, along with a web-based Admin Dashboard.

Since Flutter is not currently in the system PATH, we will provide the complete Flutter project structure (the entire `lib/` directory, state management, UI pages, caching, offline support, and `pubspec.yaml` configuration) and outline how to initialize the platform-specific boilerplate using `flutter create`. We will fully build the web-based Admin Dashboard using React + Vite + TypeScript + CSS, which can be run locally using the installed Node.js/npm.

---

## Workspace Structure

We will organize the project under `c:\Projects\shifa` as a monorepo:
* **`shifa_mobile/`**: The complete Flutter application codebase, following Clean Architecture and Riverpod.
* **`shifa_admin/`**: The web-based Admin Dashboard built with React, Vite, TypeScript, and Vanilla CSS.
* **`firestore.rules` & `storage.rules`**: Firebase configuration and security rules.
* **`README.md`**: Combined documentation containing architecture details, database schema, and setup instructions.

---

## Database Schema (Cloud Firestore)

We will use a relational-style document schema in Firestore:

### 1. `users` (Collection)
* Document ID: `uid` (from Firebase Auth)
* Fields:
  ```typescript
  {
    uid: string;
    email: string;
    displayName: string;
    photoUrl: string;
    role: 'student' | 'admin';
    createdAt: timestamp;
    lastActiveDate: timestamp;
    streak: number;
    totalVideosWatched: number;
    completedChapters: string[]; // List of chapter IDs
    completedSubjects: string[]; // List of subject IDs
  }
  ```

### 2. `subjects` (Collection)
* Document ID: `subjectId`
* Fields:
  ```typescript
  {
    id: string;
    title: string;
    description: string;
    thumbnailUrl: string;
    chaptersCount: number;
    createdAt: timestamp;
    updatedAt: timestamp;
  }
  ```

### 3. `chapters` (Collection)
* Document ID: `chapterId`
* Fields:
  ```typescript
  {
    id: string;
    subjectId: string;
    title: string;
    description: string;
    videosCount: number;
    createdAt: timestamp;
  }
  ```

### 4. `videos` (Collection)
* Document ID: `videoId`
* Fields:
  ```typescript
  {
    id: string;
    subjectId: string;
    chapterId: string;
    title: string;
    description: string;
    youtubeUrl: string;
    thumbnailUrl: string;
    duration: string; // e.g., "15:34"
    createdAt: timestamp;
    updatedAt: timestamp;
  }
  ```

### 5. `progress` (Collection)
* Document ID: `userId_videoId`
* Fields:
  ```typescript
  {
    userId: string;
    videoId: string;
    subjectId: string;
    chapterId: string;
    watchTime: number; // in seconds, for resuming
    isCompleted: boolean;
    lastWatchedAt: timestamp;
  }
  ```

### 6. `bookmarks` (Collection)
* Document ID: `userId_itemId`
* Fields:
  ```typescript
  {
    userId: string;
    itemId: string;
    itemType: 'subject' | 'chapter' | 'video';
    bookmarkedAt: timestamp;
  }
  ```

### 7. `notes` (Collection)
* Document ID: Auto-generated
* Fields:
  ```typescript
  {
    id: string;
    userId: string;
    videoId: string;
    noteText: string;
    timestampInSeconds: number; // timestamp in video where note was made
    createdAt: timestamp;
  }
  ```

---

## User Review Required

> [!IMPORTANT]
> **Flutter CLI Environment Configuration**
> Since `flutter` is not available in the workspace command line PATH, you will need to run `flutter create shifa_mobile` on your local environment to generate the platform-specific files (`android/`, `ios/`, etc.), and then download the dependencies using `flutter pub get`. We will write all the Flutter source files and custom configurations so that they are ready to run.

> [!TIP]
> **Firebase Connection & Mocking**
> To run the Admin Dashboard and the Flutter app out-of-the-box before linking your private Firebase credentials, we will provide a robust mock client layer. This lets you explore the rich UI, animations, and full user flows immediately, with a clean switch in the configuration to bind to live Firebase.

---

## Proposed Changes

### Component 1: Root Configurations
We will add the top-level files to document the schema, setup, and Firebase security rules.

#### [NEW] [README.md](file:///c:/Projects/shifa/README.md)
* Comprehensive documentation detailing clean architecture, setup steps, database design, and building instructions.

#### [NEW] [firestore.rules](file:///c:/Projects/shifa/firestore.rules)
* Security rules restricting write operations on subjects, chapters, and videos to `admin` roles, and progress/notes/bookmarks to the respective authenticated user.

#### [NEW] [storage.rules](file:///c:/Projects/shifa/storage.rules)
* Rules for thumbnail and user photo uploads.

---

### Component 2: Flutter Mobile Application (`shifa_mobile`)
We will create a structured Flutter project that implements **Clean Architecture** combined with **Riverpod** state management.

```
shifa_mobile/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── core/
    │   ├── theme/          # Color schemes, dark/light modes
    │   ├── constants/      # App assets and constants
    │   ├── utils/          # Helpers (formatters, validators)
    │   └── services/       # Cache, storage, network info
    ├── domain/
    │   ├── entities/       # Subject, Chapter, Video, User, etc.
    │   ├── repositories/   # Interfaces for Auth, Learning, Progress
    │   └── usecases/       # Fetch subjects, update progress, toggle bookmarks
    ├── data/
    │   ├── models/         # JSON serialization & database schemas
    │   ├── datasources/    # Remote (Firebase/Mock) and Local (SQLite/SharedPref)
    │   └── repositories/   # Concrete implementations
    └── presentation/
        ├── providers/      # Riverpod providers, ViewModels
        ├── screens/        # UI Screen files (Splash, Home, Player, etc.)
        └── widgets/        # Reusable UI widgets
```

#### [NEW] [pubspec.yaml](file:///c:/Projects/shifa/shifa_mobile/pubspec.yaml)
* Add core dependencies: `flutter_riverpod`, `youtube_player_flutter`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `shared_preferences`, `sqflite`, `cached_network_image`, `google_fonts`, `intl`, `share_plus`.

#### [NEW] [lib/main.dart](file:///c:/Projects/shifa/shifa_mobile/lib/main.dart)
* Initialization logic for Flutter, Riverpod, caching services, and dark/light theme triggers.

#### [NEW] Flutter Domain and Data Layers
* Models, entities, repositories, and local database database helpers (SQLite/SharedPreferences) for offline metadata caching and video watch-history tracking.

#### [NEW] Flutter Presentation Layer (Riverpod ViewModels & Screens)
* Implement highly polished screens using **Material Design 3**, responsive structures, smooth scrolling with cached images, and custom animations:
  * **Splash Screen** & **Auth Screens** (Login, SignUp, Forgot Password, Google Login, Guest Access)
  * **Home Screen** (Global search, featured, continue learning, watch-streak counter)
  * **Subject List** & **Chapter List**
  * **Video Player Screen** (Embedded YouTube player, speed controller, resume playback, auto-play next, notes section, favorites, bookmarks)
  * **Bookmarks Screen** & **Progress Screen** (Stats cards, streak details, completion percentages)
  * **Profile Screen** & **Settings Screen** (Light/Dark mode toggle, cache clearing, log out)

---

### Component 3: Web-Based Admin Dashboard (`shifa_admin`)
We will initialize and build a web-based Admin Dashboard using React + Vite + TypeScript. It will feature a premium glassmorphic UI, responsive tables, real-time Firestore synchronization, dashboard analytics, and management tools for adding/editing courses.

```
shifa_admin/
├── package.json
├── index.html
├── src/
    ├── main.tsx
    ├── index.css           # Premium global dark/light theme, custom scrollbars
    ├── App.tsx             # Layout and routing
    ├── components/         # Glassmorphic cards, charts, modal forms, tables
    └── services/           # Firebase dashboard client / Mock client
```

#### [NEW] [package.json](file:///c:/Projects/shifa/shifa_admin/package.json)
* Configuration for React, Vite, Lucide-react (icons), and Chart.js or CSS-based analytics.

#### [NEW] [src/index.css](file:///c:/Projects/shifa/shifa_admin/src/index.css)
* Design system tokens, variables, custom scrollbars, layout helpers, animations, and dark/light color themes.

#### [NEW] [src/App.tsx](file:///c:/Projects/shifa/shifa_admin/src/App.tsx)
* Main routing, authentication gate, dashboard layout, and views (Analytics, Users, Subjects, Chapters, Videos).

#### [NEW] Dashboard Views and Modal Components
* Beautiful dashboards representing enrollment rates, completion metrics, and user management. Dialogs for adding/editing subjects, chapters, and video lectures.

---

## Verification Plan

### Automated Verification
* Run code syntax and lint checks on the React web application.
* Build the React Admin Dashboard (`npm run build`) to verify there are no compile-time errors.

### Manual Verification
1. Run the web-based Admin Dashboard locally via `npm run dev` and test:
   * Real-time metrics visualization (Analytics)
   * Adding, editing, and deleting mock subjects and chapters
   * Searching and filtering lists
   * Profile state updates
2. Review the structured Flutter files in the IDE, verifying compilation structure and syntax completeness.
