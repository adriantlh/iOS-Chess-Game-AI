# Chess Game Setup Instructions

## Quick Start Guide

Follow these steps to set up and run the iOS Chess Game in Xcode:

### Step 1: Create a New Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Click "Next"

### Step 2: Configure Project Settings

Fill in the project details:
- **Product Name**: ChessGame
- **Team**: Select your development team (or leave as None for simulator)
- **Organization Identifier**: com.yourname (or any identifier you prefer)
- **Interface**: SwiftUI
- **Language**: Swift
- **Storage**: None (uncheck Core Data, CloudKit, and Tests if prompted)

Click "Next" and choose a location to save the project (can be temporary as we'll replace files).

### Step 3: Replace Default Files

1. In Xcode, delete the default `ContentView.swift` file (Move to Trash)
2. Delete the default app file (it will be named something like `ChessGameApp.swift`)

### Step 4: Add the Chess Game Files

#### Option A: Drag and Drop (Recommended)
1. Open Finder and navigate to the `ChessGame` folder from this repository
2. Drag the entire `ChessGame` folder into your Xcode project navigator
3. In the dialog that appears:
   - Check "Copy items if needed"
   - Select "Create groups"
   - Make sure your target is selected
   - Click "Finish"

#### Option B: Add Files Manually
1. Right-click on the project in Xcode's navigator
2. Select "Add Files to [ProjectName]"
3. Navigate to the repository's `ChessGame` folder
4. Select all files and folders
5. Make sure "Copy items if needed" is checked
6. Click "Add"

### Step 5: Verify File Structure

Your Xcode project should now have this structure:
```
ChessGame/
├── ChessGameApp.swift
├── Models/
│   ├── ChessPiece.swift
│   ├── ChessMove.swift
│   ├── ChessBoard.swift
│   └── GameState.swift
├── ViewModels/
│   └── ChessGameViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── ChessBoardView.swift
│   ├── ChessPieceView.swift
│   └── GameMenuView.swift
├── AI/
│   └── ChessAI.swift
└── Info.plist
```

### Step 6: Update Info.plist (if needed)

If you want to use the provided Info.plist:
1. Delete the default Info.plist in your Xcode project
2. The Info.plist from the ChessGame folder should already be added
3. Make sure it's included in your target

Alternatively, keep your default Info.plist - the app will work with default settings.

### Step 7: Build and Run

1. Select a simulator or device from the target dropdown (iPhone 14, iPad, etc.)
2. Press ⌘R or click the "Run" button
3. Wait for the build to complete
4. The chess game should launch!

## Troubleshooting

### Build Errors

**"Cannot find type 'ChessPiece' in scope"**
- Solution: Make sure all files are added to your target. Select each .swift file, open the File Inspector (⌘⌥1), and verify your target is checked under "Target Membership"

**"Multiple commands produce Info.plist"**
- Solution: In Build Settings, search for "Info.plist" and make sure the path points to only one Info.plist file

**"No such module 'SwiftUI'"**
- Solution: Make sure your deployment target is iOS 15.0 or later (Project Settings → General → Deployment Info)

### Runtime Issues

**App crashes on launch**
- Solution: Check the console for error messages. Most likely a file is missing or not added to the target.

**Chess pieces don't display**
- Solution: This is likely a font issue. The app uses Unicode chess symbols which should work on all iOS devices running iOS 15+.

**AI is too slow**
- Solution: This is normal for Hard difficulty. Consider using Medium or Easy for faster gameplay, or run on a physical device instead of simulator.

## Building for Device

To run on a physical iPhone or iPad:

1. Connect your device via USB
2. In Xcode, select your device from the target dropdown
3. If prompted, trust the computer on your device
4. You may need to enable Developer Mode on iOS 16+:
   - Settings → Privacy & Security → Developer Mode → On
5. Build and run (⌘R)

## Minimum Requirements

- **Xcode**: 13.0 or later
- **iOS**: 15.0 or later
- **macOS**: 11.3 (Big Sur) or later for Xcode 13

## File Descriptions

- **ChessGameApp.swift**: Main app entry point with @main attribute
- **Models/**: Data models for game state, pieces, moves, and board
- **ViewModels/**: MVVM view model for managing game state and logic
- **Views/**: SwiftUI views for UI components
- **AI/**: Chess AI implementation with difficulty levels

## Need Help?

If you encounter issues not covered here:
1. Check that all .swift files are in the project
2. Verify Swift version is 5.5+
3. Clean build folder (⌘⇧K) and rebuild
4. Restart Xcode if issues persist

## Next Steps

Once the app is running, check out the README.md for:
- How to play the game
- Feature descriptions
- Technical implementation details
