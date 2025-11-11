# iOS Chess Game with AI

A comprehensive iOS chess game built with Swift and SwiftUI, featuring AI opponents with multiple difficulty levels, local multiplayer, chess puzzles, time controls, move history, and assisted play mode.

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

### Home Screen
- **Professional Home Menu**: Beautiful landing page with easy navigation
- Quick access to all game modes and features
- Game history and settings easily accessible

### Chess Puzzles
- **Training Mode**: Solve tactical chess puzzles to improve your skills
- **9 Included Puzzles**: Across 4 difficulty levels (Beginner to Expert)
- **Multiple Themes**: Checkmate, Fork, Pin, Skewer, Discovery, Sacrifice, Endgame, and Tactical
- **Solution Validation**: Real-time feedback on your moves
- **Puzzle Categories**:
  - Beginner: Back rank mate, knight forks, simple pins
  - Intermediate: Queen sacrifices, skewer attacks
  - Advanced: Smothered mates, discovered checks
  - Expert: Complex combinations, endgame techniques
- **Hints System**: Get help when you're stuck
- **Progress Tracking**: See your attempts and completion status

### Time Controls
- **Chess Clocks**: Full timer implementation with multiple presets
- **Time Control Options**:
  - Bullet (1+0, 2+1)
  - Blitz (3+0, 5+0)
  - Rapid (10+0, 15+10)
  - Classical (30+0)
- **Visual Countdown**: Color-coded time display (green → orange → red)
- **Increment Support**: Automatic time addition after each move
- **Time Pressure Warnings**: Visual indicators when time is running low
- **Flag Fall Detection**: Automatic game end when time expires

### Move History & Analysis
- **Complete Move History**: View all moves in algebraic notation
- **Scrollable Move List**: Easy navigation through game history
- **Standard Notation**: Proper chess notation including:
  - Piece moves (e.g., Nf3, Qd4)
  - Captures (e.g., Nxe5, exd5)
  - Castling (O-O, O-O-O)
  - Promotions (e.g., e8=Q)
  - Check (+) and Checkmate (#) indicators
- **Move Numbers**: Organized by move pairs (white and black)
- **Clean Display**: Easy-to-read monospaced font

### Save/Load Games
- **Game Records**: Automatically save completed games
- **Game History**: View past games with full details
- **Metadata Storage**: Tracks date, time control, game mode, and result
- **Quick Access**: Load and review previous games from home screen

### User Interface
- **Modern Home Screen**: Professional menu with game mode selection
- **Clean Board Display**: Intuitive chess board visualization
- **Visual Indicators**:
  - Selected pieces (blue highlight)
  - Possible moves (green highlights/circles)
  - Threatened pieces (orange highlight)
  - King in check (red highlight)
- **Real-time Status**: Current turn, check status, and game mode display
- **Responsive Controls**: Undo, restart, assist, and exit buttons
- **Timer Display**: Color-coded timers for both players
- **Move History Sheet**: Slide-up panel with complete move list

## Project Structure

```
ChessGame/
├── ChessGameApp.swift               # Main app entry point
├── Models/
│   ├── ChessPiece.swift            # Piece definitions and types
│   ├── ChessMove.swift             # Move representation and game records
│   ├── ChessBoard.swift            # Board state and game logic
│   ├── GameState.swift             # Game mode and settings
│   ├── ChessTimer.swift            # Timer/clock implementation
│   └── ChessPuzzle.swift           # Puzzle definitions and data
├── ViewModels/
│   └── ChessGameViewModel.swift    # Main game view model
├── Views/
│   ├── HomeView.swift              # Home screen and main menu
│   ├── GameView.swift              # Main game view
│   ├── GameSetupView.swift         # Game configuration screen
│   ├── ChessBoardView.swift        # Board visualization
│   ├── ChessPieceView.swift        # Piece rendering
│   ├── MoveHistoryView.swift       # Move history display
│   ├── TimerView.swift             # Timer/clock display
│   ├── PuzzleMenuView.swift        # Puzzle selection menu
│   ├── PuzzleGameView.swift        # Puzzle solving interface
│   ├── SavedGamesView.swift        # Game history viewer
│   └── SettingsView.swift          # App settings
├── AI/
│   └── ChessAI.swift               # AI opponent logic
└── Info.plist                      # App configuration
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

### From the Home Screen
1. Launch the app to see the main menu
2. Choose from the following options:
   - **Play Game**: Start a new game against AI or another player
   - **Chess Puzzles**: Train your tactical skills
   - **Saved Games**: Review previously played games
   - **Settings**: Customize app preferences

### Starting a Regular Game
1. Select "Play Game" from the home screen
2. Choose your game mode (Player vs Player or Player vs AI)
3. If playing against AI:
   - Select difficulty (Easy, Medium, or Hard)
   - Choose your color (White or Black)
4. Optional: Enable timer and select time control
5. Optional: Enable assisted play to see threatened pieces
6. Tap "Start Game"

### Playing Chess Puzzles
1. Select "Chess Puzzles" from the home screen
2. Browse puzzles by difficulty (All, Beginner, Intermediate, Advanced, Expert)
3. Tap a puzzle to attempt it
4. Read the objective and make the correct moves
5. Use "Hint" if you need help
6. Use "Reset" to try again

### During a Game
1. **Making Moves**:
   - Tap a piece to select it (must be your turn)
   - Valid moves are highlighted in green
   - Tap a highlighted square to move
   - Tap elsewhere to deselect

2. **Using Controls**:
   - **Undo**: Step back through moves
   - **Restart**: Start a fresh game with current settings
   - **Assist**: Toggle threatened piece highlighting
   - **Exit**: Return to home screen

3. **Viewing Move History**:
   - Tap "Move History" button to see all moves in algebraic notation
   - Scroll through the complete game record

4. **Monitoring Time** (if enabled):
   - Watch the timer displays at top and bottom
   - Colors indicate time pressure (green → orange → red)
   - Game ends when a player's time expires

### Winning the Game
- Checkmate your opponent's king to win
- Win on time if your opponent's clock runs out
- The game detects checkmate and stalemate automatically
- Choose to start a new game or return to the home screen

## Recently Added Features ✨

The following features were recently implemented:
- ✅ **Home Screen**: Professional menu system with easy navigation
- ✅ **Chess Puzzles**: 9 tactical puzzles across 4 difficulty levels
- ✅ **Time Controls**: Full timer support with 7 preset time controls
- ✅ **Move History**: Complete game notation in algebraic format
- ✅ **Save/Load Games**: Automatic game record saving and viewing

## Future Enhancements

Potential improvements for future versions:
- **Multiplayer over network**: Play with friends remotely
- **Advanced game analysis**: Position evaluation and best move suggestions
- **More puzzles**: Expanded puzzle database with hundreds of puzzles
- **Opening book**: Pre-programmed opening moves for stronger AI
- **Endgame tablebase**: Perfect endgame play with tablebase integration
- **Custom themes**: Customizable piece sets and board colors
- **Game replay mode**: Step through saved games move by move
- **PGN import/export**: Import and export games in standard PGN format
- **Statistics**: Track win/loss ratios, average game time, and more
- **Achievements**: Unlock badges for milestones and accomplishments

## License

See LICENSE file for details.

## Credits

Created as a demonstration of AI-assisted development with Claude.
