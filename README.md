Flappy Doggo
Flappy Doggo is a Flutter-based mobile game inspired by the classic Flappy Bird. Players navigate a cute doggo through a series of buildings, avoiding collisions while aiming for a high score. The game features custom assets, sound effects, a leaderboard, and a special "Pookie" mode with unique visuals and audio.
Features

Dynamic Gameplay: Control the doggo by tapping to avoid randomly generated buildings with varying sizes.
Customizable Assets: Different background and bird images based on the player's name (e.g., "Pookie" mode).
Sound Effects: Includes background music, jump, score, and crash sounds for an immersive experience.
Leaderboard: Persists high scores using shared_preferences and displays the top 10 scores.
Responsive Design: Scales dynamically to different screen sizes for a consistent experience.
Immersive Mode: Runs in fullscreen with no debug banner for a polished feel.

Prerequisites
To run Flappy Doggo, ensure you have the following installed:

Flutter SDK: Version 3.0.0 or higher
Dart: Included with Flutter
Android Studio / Xcode: For emulator or physical device testing
Git: To clone the repository

Installation

Clone the Repository:
git clone https://github.com/IshtiAK47/FlappyDoggoGame.git
cd flappy-doggo


Install Dependencies:Run the following command to fetch the required packages:
flutter pub get


Add Assets:Ensure the following assets are added to the assets/ directory and listed in pubspec.yaml:

Images:
assets/images/bird-normal.png
assets/images/bird-pookiee.png
assets/images/bg-normal.png
assets/images/bg-pookiee.png


Sounds:
assets/sounds/background.mp3
assets/sounds/pookiee.mp3
assets/sounds/jump.wav
assets/sounds/score.wav
assets/sounds/crash.wav



Example pubspec.yaml configuration:
flutter:
  assets:
    - assets/images/bird-normal.png
    - assets/images/bird-pookiee.png
    - assets/images/bg-normal.png
    - assets/images/bg-pookiee.png
    - assets/sounds/background.mp3
    - assets/sounds/pookiee.mp3
    - assets/sounds/jump.wav
    - assets/sounds/score.wav
    - assets/sounds/crash.wav


Run the App:Connect a device or start an emulator, then run:
flutter run



Usage

Enter Your Name: On first launch, input your name. If you enter "Pookie" (case-insensitive), the game switches to a special theme with unique visuals and music.
Start the Game: Tap "Start Game" to begin. The game will save your name for future sessions.
Gameplay: Tap the screen to make the doggo jump and avoid buildings. Each building passed increases your score.
Game Over: If the doggo hits a building or goes off-screen, the game ends. Your score is saved to the leaderboard.
Leaderboard: View the top 10 high scores in the game-over screen.
Restart or Change Name: Choose to play again or change your name from the game-over screen.

Project Structure

lib/main.dart: Main entry point and game logic.
assets/: Contains images and sound files.
pubspec.yaml: Lists dependencies and assets.

Dependencies

flutter: Core Flutter framework
shared_preferences: For saving player name and leaderboard
audioplayers: For playing background music and sound effects

Contributing
Contributions are welcome! To contribute:

Fork the repository.
Create a new branch (git checkout -b feature/your-feature).
Make your changes and commit (git commit -m 'Add your feature').
Push to the branch (git push origin feature/your-feature).
Open a Pull Request.

Please ensure your code follows the Flutter style guide and includes tests where applicable.
License
This project is licensed under the MIT License. See the LICENSE file for details.
Acknowledgments

Inspired by Flappy Bird
Built with Flutter for cross-platform mobile development

