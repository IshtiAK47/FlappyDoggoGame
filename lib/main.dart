import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;

void main() {
  // Ensure the app runs in fullscreen immersive mode
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FlappyDoggoApp());
}

class FlappyDoggoApp extends StatelessWidget {
  const FlappyDoggoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Doggo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game variables
  late AnimationController _birdController;
  late Animation<double> _birdAnimation;

  double birdY = 0;
  double birdVelocity = 0;
  double gravity = 0.45; // Reduced from 0.6 to increase floating time
  double jumpForce = -9; // Kept same to balance gameplay

  bool gameRunning = false;
  bool gameStarted = false;
  bool gameOver = false;

  int score = 0;
  String playerName = '';
  bool showNameInput = true;
  List<Map<String, dynamic>> buildings = [];
  List<Map<String, dynamic>> leaderboard = [];

  double gameSpeed = 1.0;
  double lastFrameTime = 0;
  double buildingSpawnDistance = 950;
  int maxBuildings = 2;

  // Audio players
  late AudioPlayer bgMusicPlayer;
  late AudioPlayer jumpSoundPlayer;
  late AudioPlayer scoreSoundPlayer;
  late AudioPlayer crashSoundPlayer;

  // Controllers
  TextEditingController nameController = TextEditingController();

  // Images
  ui.Image? birdUiImage;
  ui.Image? bgUiImage;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _birdController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _birdAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_birdController);

    // Initialize audio players
    initAudio();

    // Load saved data
    loadPlayerName();
    loadLeaderboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload images
    _loadImages();
  }

  Future<void> _loadImages() async {
    final birdAsset = playerName.toLowerCase() == 'pookie'
        ? 'assets/images/bird-pookiee.png'
        : 'assets/images/bird-normal.png';
    final bgAsset = playerName.toLowerCase() == 'pookie'
        ? 'assets/images/bg-pookiee.png'
        : 'assets/images/bg-normal.png';

    // Load bird image
    final birdCompleter = Completer<ui.Image>();
    final birdImageProvider = AssetImage(birdAsset);
    final birdStream = birdImageProvider.resolve(ImageConfiguration());
    ImageStreamListener? birdListener;
    birdListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        birdCompleter.complete(info.image);
        birdStream.removeListener(birdListener!);
      },
      onError: (exception, stackTrace) {
        birdCompleter.completeError(exception, stackTrace);
      },
    );
    birdStream.addListener(birdListener);

    // Load background image
    final bgCompleter = Completer<ui.Image>();
    final bgImageProvider = AssetImage(bgAsset);
    final bgStream = bgImageProvider.resolve(ImageConfiguration());
    ImageStreamListener? bgListener;
    bgListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        bgCompleter.complete(info.image);
        bgStream.removeListener(bgListener!);
      },
      onError: (exception, stackTrace) {
        bgCompleter.completeError(exception, stackTrace);
      },
    );
    bgStream.addListener(bgListener);

    try {
      final images =
          await Future.wait([birdCompleter.future, bgCompleter.future]);
      setState(() {
        birdUiImage = images[0];
        bgUiImage = images[1];
      });
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  void initAudio() {
    bgMusicPlayer = AudioPlayer();
    jumpSoundPlayer = AudioPlayer();
    scoreSoundPlayer = AudioPlayer();
    crashSoundPlayer = AudioPlayer();
  }

  Future<void> loadPlayerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('playerName');
    if (name != null && name.isNotEmpty) {
      setState(() {
        playerName = name;
        showNameInput = false;
        gameStarted = true;
      });
      await _loadImages();
    }
  }

  Future<void> loadLeaderboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('leaderboard');
    List<dynamic> decoded = jsonDecode(data ?? '[]');
    if (decoded.isEmpty) {
      leaderboard = [];
    } else {
      setState(() {
        leaderboard = decoded.cast<Map<String, dynamic>>();
        leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
        if (leaderboard.length > 10) {
          leaderboard = leaderboard.take(10).toList();
        }
      });
    }
  }

  Future<void> saveScore(String name, int score) async {
    if (name.isEmpty || score == 0) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    leaderboard.add({'name': name, 'score': score});
    leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
    if (leaderboard.length > 10) {
      leaderboard = leaderboard.take(10).toList();
    }

    await prefs.setString('leaderboard', jsonEncode(leaderboard));
  }

  void startGame() async {
    if (playerName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name!')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', playerName);

    setState(() {
      showNameInput = false;
      gameStarted = true;
      gameRunning = true;
      gameOver = false;
      score = 0;
      birdY = 0;
      birdVelocity = 0;
      buildings.clear();
      gameSpeed = 4.0;
      lastFrameTime = 0;
    });

    // Reload images for new player name
    await _loadImages();

    // Play background music
    try {
      if (playerName.toLowerCase() == 'pookie') {
        await bgMusicPlayer.play(AssetSource('sounds/pookiee.mp3'));
      } else {
        await bgMusicPlayer.play(AssetSource('sounds/background.mp3'));
      }
      await bgMusicPlayer.setVolume(0.3);
    } catch (e) {
      print('Error playing background music: $e');
    }

    startGameLoop();
    spawnBuilding();
  }

  void startGameLoop() {
    void updateFrame(Duration timestamp) {
      if (!gameRunning) return;

      double currentTime = timestamp.inMicroseconds / 1000000.0;
      double deltaTime =
          lastFrameTime == 0 ? 1 / 60 : currentTime - lastFrameTime;
      lastFrameTime = currentTime;

      setState(() {
        // Update bird physics
        birdVelocity += gravity * deltaTime * 60;
        birdY += birdVelocity * deltaTime * 60;

        // Update buildings
        for (int i = buildings.length - 1; i >= 0; i--) {
          buildings[i]['x'] -= gameSpeed * deltaTime * 80;

          if (!buildings[i]['passed'] &&
              buildings[i]['x'] + buildings[i]['width'] < 120) {
            buildings[i]['passed'] = true;
            score++;
            playScoreSound();
          }

          if (buildings[i]['x'] < -buildings[i]['width']) {
            buildings.removeAt(i);
          }
        }

        // Spawn new building
        if (buildings.length < maxBuildings &&
            (buildings.isEmpty ||
                buildings.last['x'] + buildings.last['width'] <
                    MediaQuery.of(context).size.width -
                        buildingSpawnDistance *
                            (MediaQuery.of(context).size.width / 1080))) {
          spawnBuilding();
          if (score > 0 && score % 5 == 0) {
            gameSpeed += 0.1;
          }
        }

        // Check collisions
        checkCollisions();
      });

      if (gameRunning) {
        SchedulerBinding.instance.scheduleFrameCallback(updateFrame);
      }
    }

    SchedulerBinding.instance.scheduleFrameCallback(updateFrame);
  }

  void spawnBuilding() {
    Random rand = Random();
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 1080;
    double buildingWidth =
        (rand.nextDouble() * 40 + 200) * scale; // 200–240 pixels
    double buildingHeight =
        (rand.nextDouble() * 200 + 400) * scale; // 400–600 pixels

    // Calculate number of windows based on building size
    int windowsPerRow = (buildingWidth / (15 * scale))
        .floor(); // Reduced spacing for more windows
    int windowsPerColumn = (buildingHeight / (15 * scale)).floor();
    int totalWindows = windowsPerRow * windowsPerColumn;
    if (totalWindows > 50) totalWindows = 50; // Cap at 50 for performance

    // Generate window positions in a grid with random lit state
    List<Map<String, dynamic>> windows = [];
    double windowSize = 12 * scale;
    double margin = 5 * scale; // Reduced margin for fuller coverage
    double xStep =
        (buildingWidth - 2 * margin) / (windowsPerRow > 0 ? windowsPerRow : 1);
    double yStep = (buildingHeight - 2 * margin) /
        (windowsPerColumn > 0 ? windowsPerColumn : 1);

    for (int row = 0; row < windowsPerColumn; row++) {
      for (int col = 0; col < windowsPerRow; col++) {
        if (windows.length >= totalWindows) break;
        windows.add({
          'x': margin + col * xStep,
          'y': margin + row * yStep,
          'lit': rand.nextDouble() < 0.5, // 50% chance to be lit
        });
      }
    }

    setState(() {
      buildings.add({
        'x': screenWidth,
        'height': buildingHeight,
        'width': buildingWidth,
        'passed': false,
        'color': Color.fromRGBO(
          rand.nextInt(100) + 50,
          rand.nextInt(100) + 50,
          rand.nextInt(100) + 100,
          1.0,
        ),
        'windows': windows,
      });
    });
  }

  void jump() {
    if (!gameRunning) return;

    setState(() {
      birdVelocity = jumpForce;
    });

    _birdController.forward().then((_) {
      _birdController.reverse();
    });

    playJumpSound();
  }

  void checkCollisions() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 1080;
    double birdWidth = 100 * scale; // Increased for larger bird
    double birdHeight = 100 * scale;
    double birdLeft = 120 * scale; // Shifted right
    double birdTop = screenHeight / 2 + birdY;

    // Check collision with screen bottom (no ground)
    if (birdTop + birdHeight > screenHeight || birdTop < 0) {
      endGame();
      return;
    }

    for (var building in buildings) {
      double buildingLeft = building['x'];
      double buildingRight = building['x'] + building['width'];
      double buildingTop = screenHeight - building['height'];
      double buildingBottom = screenHeight;

      bool horizontalOverlap =
          birdLeft + birdWidth > buildingLeft && birdLeft < buildingRight;
      bool verticalOverlap =
          birdTop + birdHeight > buildingTop && birdTop < buildingBottom;

      if (horizontalOverlap && verticalOverlap) {
        endGame();
        return;
      }
    }
  }

  void endGame() {
    setState(() {
      gameRunning = false;
      gameOver = true;
    });

    bgMusicPlayer.stop();
    playCrashSound();
    saveScore(playerName, score);
    loadLeaderboard();
  }

  void restartGame() {
    setState(() {
      gameOver = false;
      buildings.clear();
    });
    startGame();
  }

  void changeName() {
    setState(() {
      showNameInput = true;
      gameStarted = false;
      gameOver = false;
      playerName = '';
      nameController.text = '';
    });
  }

  void playJumpSound() async {
    try {
      await jumpSoundPlayer.play(AssetSource('sounds/jump.wav'));
    } catch (e) {
      print('Error playing jump sound: $e');
    }
  }

  void playScoreSound() async {
    try {
      await scoreSoundPlayer.play(AssetSource('sounds/score.wav'));
    } catch (e) {
      print('Error playing score sound: $e');
    }
  }

  void playCrashSound() async {
    try {
      await crashSoundPlayer.play(AssetSource('sounds/crash.wav'));
    } catch (e) {
      print('Error playing crash sound: $e');
    }
  }

  @override
  void dispose() {
    _birdController.dispose();
    bgMusicPlayer.dispose();
    jumpSoundPlayer.dispose();
    scoreSoundPlayer.dispose();
    crashSoundPlayer.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: jump,
        child: Stack(
          children: [
            // Background
            if (bgUiImage != null)
              CustomPaint(
                painter: BackgroundPainter(bgUiImage!),
                size: MediaQuery.of(context).size,
              ),
            // Game canvas
            if (gameStarted && birdUiImage != null)
              CustomPaint(
                painter: GamePainter(
                  birdY: birdY,
                  birdVelocity: birdVelocity,
                  buildings: buildings,
                  birdImage: birdUiImage!,
                  screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height,
                ),
                size: MediaQuery.of(context).size,
              ),
            // Score
            if (gameStarted)
              Positioned(
                top: 60,
                left: 20,
                child: Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 32 *
                        (MediaQuery.of(context).size.width /
                            1080), // Scaled score
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            // Name Input Dialog
            if (showNameInput)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Flappy Doggo',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Enter your name:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Your name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            maxLength: 20,
                            onChanged: (value) => playerName = value,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Start Game'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Game Over Dialog with Materialized Leaderboard
            if (gameOver)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Game Over!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Your score: $score',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  'Leaderboard',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: leaderboard.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${index + 1}. ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${leaderboard[index]['name']}: ${leaderboard[index]['score']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: restartGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Play Again'),
                              ),
                              ElevatedButton(
                                onPressed: changeName,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Change Name'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final ui.Image bgImage;

  BackgroundPainter(this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Calculate the source and destination rectangles to fill the screen
    final srcRect = Rect.fromLTWH(
      0,
      0,
      bgImage.width.toDouble(),
      bgImage.height.toDouble(),
    );
    // Scale the image to cover the entire screen, preserving aspect ratio
    final aspectRatio = bgImage.width / bgImage.height;
    final screenAspectRatio = size.width / size.height;

    double dstWidth, dstHeight;
    double offsetX = 0, offsetY = 0;

    if (aspectRatio > screenAspectRatio) {
      // Image is wider than screen: scale by height
      dstHeight = size.height;
      dstWidth = size.height * aspectRatio;
      offsetX = (size.width - dstWidth) / 2;
    } else {
      // Image is taller than screen: scale by width
      dstWidth = size.width;
      dstHeight = size.width / aspectRatio;
      offsetY = (size.height - dstHeight) / 2;
    }

    final dstRect = Rect.fromLTWH(
      offsetX,
      offsetY,
      dstWidth,
      dstHeight,
    );

    // Draw the image to cover the entire screen
    canvas.drawImageRect(
      bgImage,
      srcRect,
      dstRect,
      paint,
    );
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => false;
}

class GamePainter extends CustomPainter {
  final double birdY;
  final double birdVelocity;
  final List<Map<String, dynamic>> buildings;
  final ui.Image birdImage;
  final double screenWidth;
  final double screenHeight;

  GamePainter({
    required this.birdY,
    required this.birdVelocity,
    required this.buildings,
    required this.birdImage,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double scale = screenWidth / 1080;

    // Draw buildings
    for (var building in buildings) {
      final buildingPaint = Paint()..color = building['color'];
      canvas.drawRect(
        Rect.fromLTWH(
          building['x'],
          screenHeight - building['height'],
          building['width'],
          building['height'],
        ),
        buildingPaint,
      );

      // Draw building border
      final borderPaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * scale;
      canvas.drawLine(
        Offset(building['x'], screenHeight - building['height']),
        Offset(building['x'] + building['width'],
            screenHeight - building['height']),
        borderPaint,
      );

      // Draw windows with random lighting
      final litWindowPaint = Paint()..color = Colors.yellow;
      final unlitWindowPaint = Paint()..color = Colors.grey[800]!;
      for (var window in building['windows']) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              building['x'] + window['x'],
              screenHeight - building['height'] + window['y'],
              12 * scale,
              12 * scale,
            ),
            Radius.circular(2 * scale),
          ),
          window['lit'] ? litWindowPaint : unlitWindowPaint,
        );
      }
    }

    // Draw bird (larger size)
    final birdPaint = Paint();
    final birdSize = 100 * scale; // Increased from 80 to 100
    final birdRect = Rect.fromLTWH(
      120 * scale,
      screenHeight / 2 + birdY,
      birdSize,
      birdSize,
    );
    canvas.save();
    canvas.translate(birdRect.center.dx, birdRect.center.dy);
    canvas.rotate(birdVelocity * 0.1);
    canvas.translate(-birdRect.center.dx, -birdRect.center.dy);
    canvas.drawImageRect(
      birdImage,
      Rect.fromLTWH(
          0, 0, birdImage.width.toDouble(), birdImage.height.toDouble()),
      birdRect,
      birdPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return birdY != oldDelegate.birdY ||
        birdVelocity != oldDelegate.birdVelocity ||
        buildings != oldDelegate.buildings;
  }
}
