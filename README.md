# Flappy Doggo 🐶

A charming and addictive Flappy Bird-inspired mobile game built with **Flutter**. Guide an adorable dog through a dynamic cityscape, dodging procedurally generated buildings to achieve the highest score. Compete on the leaderboard, unlock special themes, and enjoy a seamless gaming experience!

---

## 📱 Android Release Available!

[![Download Android APK](https://img.shields.io/badge/Download-Android_APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/IshtiAK47/FlappyDoggoGame/releases/tag/Android)

**Latest Version**: 0.9.0 (Pre-release)  
**Requirements**: Android 5.0+  
**File Size**: 27 MB  

### What's New in the Android Version
- **Optimized Touch Controls**: Responsive tap-based controls for smooth gameplay.
- **Battery-Friendly Performance**: Optimized to minimize battery drain.
- **Fullscreen Immersive Mode**: A distraction-free gaming experience.

---

## ✨ Features

- **Adorable Dog Character**: Play as a cute dog navigating a vibrant city.
- **Procedural Buildings**: Dodge dynamically generated buildings with unique designs.
- **Immersive Audio**: Custom background music and sound effects enhance the experience.
- **Day/Night Cycle**: Visuals shift for a dynamic and engaging atmosphere.
- **Local Leaderboard**: Track and compete for high scores stored locally.
- **Special "Pookie" Theme**: Unlock a unique character, background, and music by entering the name "Pookie".
- **Animated Elements**: Clouds and building windows add depth to the gameplay.

---

## 🎮 How to Play

1. **Enter Your Name**: Input your name on the start screen to begin.
2. **Jump to Survive**: Tap the screen to make the dog jump and avoid obstacles.
3. **Score Points**: Pass buildings to increase your score.
4. **Climb the Leaderboard**: Aim for the top spot with the highest score!

---

## 🔥 Special "Pookie" Mode

Enter the name **"Pookie"** to unlock an exclusive experience:
- Unique dog character design.
- Custom cityscape background.
- Exclusive background music track.

---

## 🛠️ Technologies Used

### Flutter
Flappy Doggo is built using **Flutter**, Google's open-source UI framework for creating natively compiled applications for mobile, web, and desktop from a single codebase. Flutter enables:
- **High-Performance Rendering**: Smooth animations and graphics using Skia.
- **Cross-Platform Support**: Consistent experience across Android and iOS (iOS support planned).
- **Rich Widget Library**: Material Design components for a polished UI.
- **Hot Reload**: Rapid development and testing for faster iterations.

### Potential Flame Engine Integration
While Flappy Doggo currently uses custom Flutter rendering with `CustomPainter`, the **Flame game engine** (a 2D game framework built on Flutter) could enhance future development. Flame offers:
- **Game Loop Management**: Simplified handling of updates and rendering.
- **Sprite and Animation Support**: Streamlined asset management for characters and backgrounds.
- **Collision Detection**: Built-in tools for efficient collision handling.
- **Physics Simulation**: Easy integration of gravity and movement mechanics.

To integrate Flame, consider using components like `SpriteComponent` for the dog and buildings, and leverage Flame's game loop for smoother updates. The current implementation achieves similar results with custom logic but could benefit from Flame's optimizations.

### Other Technologies
- **Dart**: The programming language powering Flutter, ensuring fast execution and a clean codebase.
- **Shared Preferences**: For persistent storage of player names and leaderboard data.
- **Audioplayers**: For seamless playback of background music and sound effects.
- **Custom Painters**: For rendering the game canvas, including the dog, buildings, and background.

---

## 📥 Installation

### Android
1. Download the APK from the [releases page](https://github.com/IshtiAK47/FlappyDoggoGame/releases/tag/Android).
2. Enable "Unknown Sources" in your Android settings and install the APK.
3. Launch the app and start playing!

### Development Setup
To run or modify the game locally:
1. Clone the repository: `git clone https://github.com/IshtiAK47/FlappyDoggoGame.git`
2. Navigate to the project directory: `cd FlappyDoggoGame`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

**Requirements**:
- Flutter SDK (version 3.0.0 or higher recommended)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Android/iOS emulator or physical device

---

## 🎨 Customization

Personalize Flappy Doggo by modifying the following:

- **Assets**:
  - Replace images in `assets/images` (e.g., `bird-normal.png`, `bg-normal.png`).
  - Add custom sound effects in `assets/sounds` (e.g., `jump.wav`, `score.wav`).
- **Game Parameters** (in `lib/main.dart`):
  - Gravity: `gravity = 0.45`
  - Jump force: `jumpForce = -9`
  - Game speed: `gameSpeed = 4.0`
  - Building spawn distance: `buildingSpawnDistance = 950`
- **Flame Integration**: To enhance the game, consider adding the Flame package (`flame: ^1.8.0`) to `pubspec.yaml` and refactoring the game loop and rendering to use Flame components.

---

## 🐛 Known Issues

- **Touch Sensitivity**: Controls may feel overly sensitive on some devices.
- **Local Storage**: Scores and player data are stored locally and may be cleared with app data.
- **Performance**: Older devices may experience minor frame rate drops.

---

## 🚀 Planned Improvements

- [ ] Add power-ups (e.g., speed boosts, shields).
- [ ] Implement an online leaderboard for global competition.
- [ ] Introduce additional character skins and themes.
- [ ] Add adjustable difficulty levels.
- [ ] Optimize rendering with the Flame engine for smoother performance.
- [ ] Expand to iOS with full cross-platform support.

---

## 🙏 Credits

- **Inspired by**: Flappy Bird
- **Developed by**: IshtiAK47
- **Assets**: Custom-designed images and audio for a unique experience.
- **Framework**: Flutter by Google
- **Community**: Thanks to the Flutter and Dart communities for their invaluable resources.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE). See the [LICENSE](LICENSE) file for details.

---

## 💬 Feedback & Contributions

We welcome your feedback and contributions! To get involved:
- **Report Bugs**: Open an issue on [GitHub](https://github.com/IshtiAK47/FlappyDoggoGame/issues).
- **Submit Improvements**: Create a pull request with your changes.
- **Join the Discussion**: Share ideas in [GitHub Discussions](https://github.com/IshtiAK47/FlappyDoggoGame/discussions).

---

**Soar through the skies with Flappy Doggo and chase the high score! 🐾**