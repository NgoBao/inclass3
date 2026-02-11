import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ValentineHome(),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  late AnimationController _controller;
  bool showBalloons = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleBalloons() {
    setState(() => showBalloons = !showBalloons);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas 💘")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [Color(0xFFFFCDD2), Color(0xFFE91E63)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedEmoji,
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedEmoji = value ?? selectedEmoji),
            ),
            ElevatedButton(
              onPressed: toggleBalloons,
              child: const Text("Balloon Celebration 🎈"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: _controller,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: HeartEmojiPainter(
                      type: selectedEmoji,
                      showBalloons: showBalloons,
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

class HeartEmojiPainter extends CustomPainter {
  final String type;
  final bool showBalloons;

  HeartEmojiPainter({required this.type, required this.showBalloons});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ===== GLOW TRAIL =====
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    final glowPath = _heartPath(center);
    canvas.drawPath(glowPath, glowPaint);

    // ===== HEART WITH GRADIENT =====
    final gradient = LinearGradient(
      colors: type == 'Party Heart'
          ? [Colors.pinkAccent, Colors.deepPurple]
          : [Colors.red, Colors.pink],
    );

    final rect = Rect.fromCenter(center: center, width: 220, height: 220);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(_heartPath(center), paint);

    // ===== FACE =====
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
        0,
        pi,
        false,
        mouthPaint);

    // ===== PARTY FEATURES =====
    if (type == 'Party Heart') {
      _drawPartyHat(canvas, center);
      _drawConfetti(canvas, size);
    }

    // ===== SPARKLES =====
    _drawSparkles(canvas, center);

    // ===== BALLOONS =====
    if (showBalloons) {
      _drawBalloons(canvas, size);
    }
  }

  Path _heartPath(Offset center) {
    return Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60,
          center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110,
          center.dy - 10, center.dx, center.dy + 60)
      ..close();
  }

  void _drawPartyHat(Canvas canvas, Offset center) {
    final hatPaint = Paint()..color = Colors.yellow;
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 110)
      ..lineTo(center.dx - 40, center.dy - 40)
      ..lineTo(center.dx + 40, center.dy - 40)
      ..close();
    canvas.drawPath(hatPath, hatPaint);
  }

  void _drawConfetti(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < 30; i++) {
      final paint = Paint()
        ..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
      canvas.drawCircle(
          Offset(random.nextDouble() * size.width,
              random.nextDouble() * size.height),
          3,
          paint);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center) {
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final dx = center.dx + 130 * cos(angle);
      final dy = center.dy + 130 * sin(angle);
      canvas.drawLine(
          Offset(dx - 5, dy), Offset(dx + 5, dy), sparklePaint);
      canvas.drawLine(
          Offset(dx, dy - 5), Offset(dx, dy + 5), sparklePaint);
    }
  }

  void _drawBalloons(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height / 2;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 30, height: 40), paint);
      canvas.drawLine(Offset(x, y + 20), Offset(x, y + 60), Paint());
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.showBalloons != showBalloons;
}
