# FreakyFit — Native iOS Workout Planner & Tracker

A native, ultra-lightweight, 100% offline workout planner and tracker designed for **iOS 12+** and fully optimized for the **iPhone 5s** (1GB RAM, low CPU overhead).

Developed programmatically using **Swift 5 + UIKit + Core Data**. No SwiftUI, no heavy dependencies, no trackers.

---

## Features

- **🏠 Home Screen**: Today's scheduled workout overview, streak counter, latest log, and quick stats.
- **📋 Workout Planner**: Full routine CRUD templates, set counts, rep goals, rest timer configurations, and a multi-select weekly scheduler.
- **⚡ Active Workout Tracker**: Live set logs checkoffs, automated rest timer overlays, and overall completion percentages.
- **📊 Progress Analytics**: manual weight trackers with fine adjustments, dynamic weight line chart visualization (with CAShapeLayer GPU renders), and total log statistics.
- **📝 Offline Notes**: Simple body diagnostics logging and category segments (Workout vs Body notes) with auto-save triggers.
- **⚙️ Settings Configuration**: Goal weight updates, in-app dark/light mode toggle, local reminder scheduling, and strict double-confirmation DB resets.

---

## Project Structure

```
FreakyFit/
├── project.yml                    — XcodeGen Project configuration
├── FreakyFit/
│   ├── App/
│   │   ├── AppDelegate.swift      — Programmatic UIWindow setup (iOS 12 compatibility)
│   │   └── Info.plist             — App permissions and deployment rules
│   ├── Models/
│   │   ├── FreakyFit.xcdatamodeld — SQLite database schema
│   │   ├── CoreDataStack.swift    — Core Data container initializers
│   │   ├── CoreDataEntities.swift — Table entities (WorkoutTemplate, Logs, etc.)
│   │   └── DataManager.swift      — DB CRUD logic
│   ├── Managers/
│   │   ├── ThemeManager.swift     — Dark/light mode switcher
│   │   ├── NotificationManager.swift — UNUserNotification triggers
│   │   └── StreakManager.swift    — Streak calculation helpers
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── GradientButton.swift
│   │   │   ├── StatCard.swift
│   │   │   ├── ProgressRing.swift
│   │   │   ├── SimpleChartView.swift
│   │   │   ├── RestTimerView.swift
│   │   │   └── EmptyStateView.swift
│   │   └── Cells/
│   │       ├── WorkoutCell.swift
│   │       ├── ExerciseCell.swift
│   │       ├── SetCell.swift
│   │       ├── NoteCell.swift
│   │       └── WeightLogCell.swift
│   ├── Controllers/
│   │   ├── MainTabBarController.swift
│   │   ├── Home/
│   │   │   └── HomeViewController.swift
│   │   ├── Planner/
│   │   │   ├── PlannerViewController.swift
│   │   │   ├── WorkoutDetailViewController.swift
│   │   │   └── ExerciseEditViewController.swift
│   │   ├── Tracker/
│   │   │   └── ActiveWorkoutViewController.swift
│   │   ├── Progress/
│   │   │   ├── ProgressViewController.swift
│   │   │   └── WeightEntryViewController.swift
│   │   ├── Notes/
│   │   │   ├── NotesViewController.swift
│   │   │   └── NoteDetailViewController.swift
│   │   └── Settings/
│   │       └── SettingsViewController.swift
│   ├── Extensions/
│   │   ├── UIColor+Theme.swift
│   │   ├── UIFont+App.swift
│   │   ├── Date+Helpers.swift
│   │   └── UIView+Helpers.swift
│   └── Resources/
│       └── LaunchScreen.storyboard — Required Apple Launch UI
```

---

## How to Build the Project

### Prerequisites on Mac
1. Install **Xcode 14.x** (which contains iOS 12 build support).
2. Install **XcodeGen**:
   ```bash
   brew install xcodegen
   ```

### Generation
Generate the `.xcodeproj` package by running this inside the workspace:
```bash
xcodegen generate
```
Now, open the generated `FreakyFit.xcodeproj` in Xcode.

---

## Build & Sideloading from Windows

Since Xcode requires macOS, here is the recommended workflow to compile and sign the app from Windows:

### Step 1: Compile the `.ipa` (Using GitHub Actions — Free)
1. Push the project workspace folder to a private/public **GitHub repository**.
2. Add the following action workflow to `.github/workflows/build.yml`:
   ```yaml
   name: Build IPA
   on: [push]
   jobs:
     build:
       runs-on: macos-12
       steps:
         - uses: actions/checkout@v3
         - name: Install XcodeGen
           run: brew install xcodegen
         - name: Generate Xcode Project
           run: xcodegen generate
         - name: Build and Archive
           run: |
             xcodebuild -project FreakyFit.xcodeproj \
               -scheme FreakyFit \
               -sdk iphoneos \
               -configuration Release \
               -archivePath $PWD/build/FreakyFit.xcarchive \
               archive \
               CODE_SIGNING_ALLOWED=NO
         - name: Export IPA
           run: |
             mkdir -p Payload
             mv build/FreakyFit.xcarchive/Products/Applications/FreakyFit.app Payload/
             zip -r FreakyFit.ipa Payload
         - name: Upload Artifact
           uses: actions/upload-artifact@v3
           with:
             name: FreakyFit-unsigned-ipa
             path: FreakyFit.ipa
   ```
3. Run the workflow and download the compiled `FreakyFit-unsigned-ipa` artifact.

### Step 2: Sign and Install via Sideloadly (Windows)
1. Download and install [Sideloadly](https://sideloadly.io/) on your Windows PC.
2. Install **iTunes** (direct download from Apple's site, **not** the Microsoft Store version).
3. Connect your **iPhone 5s** to your PC using a USB cable. Trust the computer on your phone.
4. Launch Sideloadly:
   - Drag the downloaded `FreakyFit.ipa` into Sideloadly.
   - Enter your **Apple ID** (used to generate a free signing certificate).
   - Click **Start** to sign and sideload.
5. On your iPhone 5s:
   - Go to **Settings** → **General** → **Profiles & Device Management**.
   - Tap your Apple ID profile and select **Trust**.
6. Open **FreakyFit** and enjoy your lightweight offline workout tracker!

*Note: Free Apple IDs allow sideloaded apps to run for 7 days before requiring re-sideloading.*
