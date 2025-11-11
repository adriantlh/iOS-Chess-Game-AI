# iOS Chess Game with AI

A fully-featured iOS chess game built with Swift and SwiftUI, featuring AI opponents with multiple difficulty levels, local multiplayer, and assisted play mode.

## Features

### Game Modes
- **Player vs Player**: Play against another person on the same device
- **Player vs AI**: Challenge an AI opponent with three difficulty levels

### AI Difficulty Levels
1. **Easy**: Random move selection - perfect for beginners
2. **Medium**: Minimax algorithm with depth 2 - provides a moderate challenge
3. **Hard**: Minimax algorithm with depth 3 with alpha-beta pruning - challenging opponent

### Gameplay Features
- **Full Chess Rules**: Complete implementation of standard chess rules including:
  - All piece movements (Pawn, Rook, Knight, Bishop, Queen, King)
  - Castling (kingside and queenside)
  - En passant capture
  - Pawn promotion (automatically promotes to Queen)
  - Check and checkmate detection
  - Stalemate detection

- **Undo Moves**: Step back through your game history
  - In Player vs Player mode: Undo one move at a time
  - In Player vs AI mode: Undo two moves (your move and AI's move)

- **Assisted Play**: Toggle to see which pieces are under threat
  - Threatened pieces are highlighted in orange
  - Helps beginners learn to spot dangers
  - Can be toggled on/off at any time

### User Interface
- Clean, intuitive chess board display
- Visual indicators for:
  - Selected pieces (blue highlight)
  - Possible moves (green highlights/circles)
  - Threatened pieces (orange highlight)
  - King in check (red highlight)
- Real-time game status display
- Easy-to-use controls for undo, restart, and settings

## Project Structure

```
ChessGame/
├── ChessGameApp.swift          # Main app entry point
├── Models/
│   ├── ChessPiece.swift        # Piece definitions and types
│   ├── ChessMove.swift         # Move representation
│   ├── ChessBoard.swift        # Board state and game logic
│   └── GameState.swift         # Game mode and settings
├── ViewModels/
│   └── ChessGameViewModel.swift # Main game view model
├── Views/
│   ├── ContentView.swift       # Main game view
│   ├── ChessBoardView.swift    # Board visualization
│   ├── ChessPieceView.swift    # Piece rendering
│   └── GameMenuView.swift      # Settings and game setup
├── AI/
│   └── ChessAI.swift           # AI opponent logic
└── Info.plist                  # App configuration
```

## Technical Details

### Architecture
- **MVVM Pattern**: Separates business logic from UI
- **SwiftUI**: Modern, declarative UI framework
- **Combine**: Reactive programming for state management

### AI Implementation
The AI uses a minimax algorithm with the following features:
- **Alpha-beta pruning**: Optimizes search performance
- **Position evaluation**: Considers material value, piece positioning, and mobility
- **Variable depth**: Adjusts difficulty by changing search depth
- **Asynchronous execution**: Runs on background thread to keep UI responsive

### Game Logic Highlights
- **Move validation**: Comprehensive validation for all piece types
- **Check detection**: Efficiently detects when kings are under attack
- **Legal move generation**: Only shows moves that don't leave king in check
- **Move history**: Full game history for undo functionality
- **Special moves**: Proper handling of castling, en passant, and promotion

## How to Build and Run

### Requirements
- Xcode 13.0 or later
- iOS 15.0 or later
- Swift 5.5 or later

### Steps
1. Open the `ChessGame` folder in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

### Creating an Xcode Project
Since this is structured as source files, you'll need to create an Xcode project:

1. Open Xcode
2. Create a new iOS App project
3. Choose SwiftUI for the interface
4. Copy all files from the `ChessGame` folder into your project
5. Ensure all files are added to your target
6. Build and run

## How to Play

### Starting a Game
1. Tap the gear icon to open settings
2. Choose your game mode (Player vs Player or Player vs AI)
3. If playing against AI, select difficulty and your color
4. Tap "Start New Game"

### Making Moves
1. Tap a piece to select it (must be your turn)
2. Valid moves are highlighted in green
3. Tap a highlighted square to move
4. Tap elsewhere to deselect

### Using Controls
- **Undo**: Step back through moves
- **Restart**: Start a fresh game with current settings
- **Assist**: Toggle threatened piece highlighting

### Winning the Game
- Checkmate your opponent's king to win
- The game detects checkmate and stalemate automatically
- A dialog will appear when the game ends

## Future Enhancements

Potential improvements for future versions:
- Multiplayer over network
- Save/load game functionality
- Move history display with notation
- Hints and move suggestions
- Chess puzzles and training mode
- Time controls (blitz, rapid, classical)
- Opening book for stronger AI
- Endgame tablebase integration
- Custom piece sets and board themes
- Game analysis and replay

## License

See LICENSE file for details.

## Credits

Created as a demonstration of AI-assisted development with Claude.
