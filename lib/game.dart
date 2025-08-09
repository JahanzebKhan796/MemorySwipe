import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final List<String> _directions = ["Up", "Down", "Left", "Right"];
  final Random _random = Random();

  late AudioPlayer _audioPlayer;
  bool _musicOn = true;

  List<String> _sequence = [];
  int _playerIndex = 0;
  bool _showingSequence = false;

  String? _currentArrow;
  Color? _flashColor;
  bool _showCountdown = false;
  int _countdownValue = 3;

  // Swipe trail
  List<_TrailPoint> _trailPoints = [];
  late Ticker _ticker;

  Offset _startSwipeOffset = Offset.zero;
  Offset _endSwipeOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _ticker = createTicker((_) {
      setState(() {
        _trailPoints.removeWhere(
              (p) => DateTime.now().difference(p.time).inMilliseconds > 500,
        );
      });
    })..start();
    _startNewGame();
  }



  @override
  void dispose() {
    _ticker.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }


  void _startNewGame() {
    if (_musicOn) _playMusic();
    _generateRandomSequence(length: 1);
    _playerIndex = 0;
    _playSequence();
  }


  Future<void> _playMusic() async {
    await _audioPlayer.setSource(AssetSource('music.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop forever
    await _audioPlayer.resume(); // Start playing
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
  }


  void _generateRandomSequence({required int length}) {
    _sequence = List.generate(
      length,
          (_) => _directions[_random.nextInt(_directions.length)],
    );
  }


  Future<void> _playSequence() async {
    setState(() => _showingSequence = true);

    for (var dir in _sequence) {
      setState(() => _currentArrow = dir);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _currentArrow = null);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    setState(() => _showingSequence = false);
  }

  void _handleSwipe(String swipeDir) {
    if (_showingSequence) return;

    if (swipeDir == _sequence[_playerIndex]) {
      _flash(Colors.green);
      _playerIndex++;
      if (_playerIndex >= _sequence.length) {
        _showCorrectCountdown();
      }
    } else {
      _flash(Colors.red);
      Future.delayed(const Duration(milliseconds: 500), _showGameOverDialog);
    }
  }

  void _flash(Color color) {
    setState(() => _flashColor = color);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _flashColor = null);
    });
  }

  Future<void> _showCorrectCountdown() async {
    setState(() {
      _showCountdown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i > 0; i--) {
      setState(() => _countdownValue = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() => _showCountdown = false);

    _playerIndex = 0;
    _generateRandomSequence(length: _sequence.length + 1); // Increase difficulty
    _playSequence();
  }

  void _showGameOverDialog() {
    _stopMusic();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Game Over",
      barrierColor: Colors.black54, // dimmed background
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.redAccent,
                  size: 80,
                ),
                const SizedBox(height: 15),
                Text(
                  "Game Over",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none, // Removes any underline
                  ),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startNewGame();
                      },
                      child: const Text(
                        "Play Again",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const StartScreen()),
                        );
                      },
                      child: const Text(
                        "Quit",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }



  String _detectSwipeDirection() {
    final dx = _endSwipeOffset.dx - _startSwipeOffset.dx;
    final dy = _endSwipeOffset.dy - _startSwipeOffset.dy;

    if (dx.abs() < 30 && dy.abs() < 30) return "";

    if (dx.abs() > dy.abs()) {
      return dx > 0 ? "Right" : "Left";
    } else {
      return dy > 0 ? "Down" : "Up";
    }
  }

  IconData _getArrowIcon(String direction) {
    switch (direction) {
      case "Up":
        return Icons.arrow_upward;
      case "Down":
        return Icons.arrow_downward;
      case "Left":
        return Icons.arrow_back;
      case "Right":
        return Icons.arrow_forward;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (details) {
          _startSwipeOffset = details.localPosition;
          if (!_showingSequence && !_showCountdown) { // 👈 added check
            _trailPoints.clear();
            _trailPoints.add(_TrailPoint(position: details.localPosition, time: DateTime.now()));
          }
        },
        onPanUpdate: (details) {
          _endSwipeOffset = details.localPosition;
          if (!_showingSequence && !_showCountdown) { // 👈 added check
            _trailPoints.add(_TrailPoint(position: details.localPosition, time: DateTime.now()));
          }
        },
        onPanEnd: (details) {
          final dir = _detectSwipeDirection();
          if (dir.isNotEmpty) {
            _handleSwipe(dir);
          }
        },
        child: Stack(
          children: [
            // Your game content here...
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _flashColor ?? Colors.black,
              child: Center(
                child: _showCountdown
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Correct!",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$_countdownValue",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                )
                    : _currentArrow != null
                    ? Icon(
                  _getArrowIcon(_currentArrow!),
                  size: 100,
                  color: Colors.blue,
                )
                    : (!_showingSequence
                    ? const Text(
                  "Your Turn!",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                )
                    : const SizedBox.shrink()),
              ),
            ),

            // 👇 Music toggle button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(
                  _musicOn ? Icons.music_note : Icons.music_off,
                  color: Colors.white,
                ),
                onPressed: () async {
                  setState(() => _musicOn = !_musicOn);
                  if (_musicOn) {
                    await _playMusic();
                  } else {
                    await _stopMusic();
                  }
                },
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _TrailPainter(_trailPoints, _showCountdown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Trail point model
class _TrailPoint {
  final Offset position;
  final DateTime time;
  _TrailPoint({required this.position, required this.time});
}

// Painter for fading trail
class _TrailPainter extends CustomPainter {
  final List<_TrailPoint> points;
  final bool showCountdown; // 👈 new
  _TrailPainter(this.points, this.showCountdown);

  @override
  void paint(Canvas canvas, Size size) {
    if (showCountdown) return; // 👈 skip drawing

    final paint = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final age = DateTime.now().difference(points[i].time).inMilliseconds;
      final opacity = 1 - (age / 500);
      if (opacity <= 0) continue;

      paint.color = Colors.blue.withOpacity(opacity);
      canvas.drawLine(points[i].position, points[i + 1].position, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => true;
}

