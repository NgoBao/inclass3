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
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  late AnimationController _controller;
  late Animation<double> _smoothAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
      appBar: AppBar(title: const Text("Cupid's Canvas 💘")),
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

    // 💖 HEART COLOR
    final gradient = type == 'Sweet Heart'
        ? const LinearGradient(
      colors: [Color.fromARGB(255, 194, 180, 179), Color.fromARGB(255, 0, 0, 0)],
    )
        : const LinearGradient(
      colors: [Colors.pinkAccent, Colors.deepPurple],
    );

    final rect = Rect.fromCenter(center: center, width: 220, height: 220);
    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawPath(_heartPath(center), paint);

    // 👀 EYES
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    // 😊 MOUTH
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

    canvas.restore();
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
