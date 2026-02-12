import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ValentineHome(),
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
  final List<String> emojiOptions = [
    'Sweet Heart',
    'Party Heart',
    'Heart-Eyes Heart',
    'Smiley Heart',
  ];

  String selectedEmoji = 'Sweet Heart';

  late AnimationController _controller;
  late Animation<double> _smoothAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _smoothAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,  // smooth ending
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSweet = selectedEmoji == 'Sweet Heart';

    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas")),
      body: Container(
        decoration: BoxDecoration(
          gradient: isSweet
              ? const LinearGradient(
            colors: [Color(0xFFFFC1CC), Color(0xFFFF80AB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(350, 350),
                  painter: HeartEmojiPainter(
                    type: selectedEmoji,
                    animation: _smoothAnimation,
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
  final Animation<double> animation;

  HeartEmojiPainter({
    required this.type,
    required this.animation,
  }) : super(repaint: animation);

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
      colors: () {
        if (type == 'Party Heart') {
          return [Colors.pinkAccent, Colors.deepPurple];
        } else if (type == 'Smiley Heart') {
          return [Colors.yellow.shade300, Colors.pink];
        } else if (type == 'Heart-Eyes Heart') {
          return [Colors.pink.shade200, Colors.purpleAccent];
        } else {
          // Sweet Heart default
          return [Colors.red, Colors.pink];
        }
      }(),
    // PARTY BALLOONS BACKGROUND
    if (type == 'Party Heart') {
      _drawPartyBalloons(canvas, size, center);
    }

    final double scale =
        1.0 + 0.12 * sin(animation.value * 2 * pi);


    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // HEART COLOR
    final gradient = type == 'Sweet Heart'
        ? const LinearGradient(
      colors: [Color.fromARGB(255, 194, 180, 179), Color.fromARGB(255, 235, 8, 8)],
    )
        : const LinearGradient(
      colors: [Colors.pinkAccent, Colors.deepPurple],
    );

    final rect = Rect.fromCenter(center: center, width: 220, height: 220);
    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawPath(_heartPath(center), paint);

    // ===== FACE =====
    if (type != 'Heart-Eyes Heart') {
      final eyePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 5, eyePaint);
      canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 5, eyePaint);
    }

    
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
      mouthPaint,
    );

    // ===== PARTY FEATURES =====
    if (type == 'Party Heart') {
      _drawPartyHat(canvas, center);
      _drawConfetti(canvas, size);
    }

    // ===== Heart-Eyes HEART =====
    if (type == 'Heart-Eyes Heart') {
      _drawHeartEyes(canvas, center);
    }

    // ===== SMILEY HEART =====
    if (type == 'Smiley Heart') {
      _drawSmileyFace(canvas, center);
      _drawTinyHearts(canvas, size, center);
    }

    // ===== SPARKLES =====
    _drawSparkles(canvas, center);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      pi,
      false,
      mouthPaint,
    );

    canvas.restore();
  }

  Path _heartPath(Offset center) {
    return Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();
  }

  Path _tinyHeartPath(double cx, double cy) {
    final path = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 15, cy - 15, cx - 28, cy - 36, cx, cy - 24)
      ..cubicTo(cx + 28, cy - 36, cx + 15, cy - 15, cx, cy)
      ..close();
    return path;
  }

  // ===== PARTY HAT =====
  void _drawPartyHat(Canvas canvas, Offset center) {
    final hatPaint = Paint()..color = Colors.yellow;
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 110)
      ..lineTo(center.dx - 40, center.dy - 40)
      ..lineTo(center.dx + 40, center.dy - 40)
      ..close();
    canvas.drawPath(hatPath, hatPaint);
  }

  // ===== CONFETTI =====
  void _drawConfetti(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < 30; i++) {
      final paint = Paint()
        ..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        3,
        paint,
      );
    }
  }

  // ===== HEART EYES FOR HEART =====
  void _drawHeartEyes(Canvas canvas, Offset center) {
    // Background circle behind each eye
    final bgPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Heart eye color
    final heartPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    // Shadow paint for 3D pop
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Highlight paint for glossy top
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // LEFT EYE
    final leftCenter = Offset(center.dx - 30, center.dy - 10);

    // Shadow behind heart
    canvas.drawPath(
      _tinyHeartPath(leftCenter.dx + 2, leftCenter.dy + 2),
      shadowPaint,
    );

    // Yellow background
    canvas.drawCircle(leftCenter, 18, bgPaint);

    // Heart eye
    canvas.drawPath(_tinyHeartPath(leftCenter.dx, leftCenter.dy), heartPaint);

    // Highlight (small circle)
    canvas.drawCircle(
      Offset(leftCenter.dx - 6, leftCenter.dy - 10),
      4,
      highlightPaint,
    );

    // RIGHT EYE
    final rightCenter = Offset(center.dx + 30, center.dy - 10);

    canvas.drawPath(
      _tinyHeartPath(rightCenter.dx + 2, rightCenter.dy + 2),
      shadowPaint,
    );

    canvas.drawCircle(rightCenter, 18, bgPaint);

    canvas.drawPath(_tinyHeartPath(rightCenter.dx, rightCenter.dy), heartPaint);

    canvas.drawCircle(
      Offset(rightCenter.dx - 6, rightCenter.dy - 10),
      4,
      highlightPaint,
    );
  }

  // ===== SMILEY FACE =====
  void _drawSmileyFace(Canvas canvas, Offset center) {
    final eyePaint = Paint()..color = Colors.black;

    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 8, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 8, eyePaint);

    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      pi,
      false,
      smilePaint,
    );
  }

  // ===== TINY HEARTS AROUND SMILEY HEART =====
  void _drawTinyHearts(Canvas canvas, Size size, Offset center) {
    final random = Random();
    final paint = Paint()..color = const Color.fromARGB(255, 246, 3, 250);

    for (int i = 0; i < 12; i++) {
      final dx = center.dx + random.nextInt(160) - 80;
      final dy = center.dy + random.nextInt(160) - 80;

      final Path tiny = Path()
        ..moveTo(dx, dy)
        ..cubicTo(dx - 6, dy - 6, dx - 10, dy - 16, dx, dy - 10)
        ..cubicTo(dx + 10, dy - 16, dx + 6, dy - 6, dx, dy)
        ..close();

      canvas.drawPath(tiny, paint);
    }
  }

  // ===== SPARKLES =====
  void _drawSparkles(Canvas canvas, Offset center) {
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final dx = center.dx + 130 * cos(angle);
      final dy = center.dy + 130 * sin(angle);
      canvas.drawLine(Offset(dx - 5, dy), Offset(dx + 5, dy), sparklePaint);
      canvas.drawLine(Offset(dx, dy - 5), Offset(dx, dy + 5), sparklePaint);
    }
  }

  // ===== BALLOONS =====
  void _drawBalloons(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height / 2;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 30, height: 40),
        paint,
      );
      canvas.drawLine(Offset(x, y + 20), Offset(x, y + 60), Paint());
  void _drawPartyBalloons(Canvas canvas, Size size, Offset center) {
    for (int i = 0; i < 40; i++) {
      final paint = Paint()
        ..color = Colors.primaries[i % Colors.primaries.length];

      final radius = 100 + (i % 6) * 40;
      final speed = 0.5 + (i % 5) * 0.2;

      final angle = (animation.value * 20 * pi * speed) + (i * pi / 10);


      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      final sizeFactor = 20 + (i % 4) * 8;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: sizeFactor.toDouble(),
          height: (sizeFactor * 1.4).toDouble(),
        ),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.showBalloons != showBalloons;
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
