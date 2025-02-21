import 'package:flutter/material.dart';
import '../providers/garden_provider.dart';
import 'dart:math' as math;

class GardenEffects extends StatefulWidget {
  final GardenState gardenState;
  final GardenStats stats;

  const GardenEffects({
    super.key,
    required this.gardenState,
    required this.stats,
  });

  @override
  State<GardenEffects> createState() => _GardenEffectsState();
}

class _GardenEffectsState extends State<GardenEffects>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Butterfly> _butterflies = [];
  final math.Random _random = math.Random();


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Efecto de clima según el estado
        _buildWeatherEffect(),

        // Mariposas si el jardín está próspero
        if (widget.stats.hasButterflies) ..._buildButterflies(),
      ],
    );
  }

  Widget _buildWeatherEffect() {
    switch (widget.gardenState) {
      case GardenState.withered:
        return _buildDustEffect();
      case GardenState.unhealthy:
        return _buildCloudyEffect();
      case GardenState.thriving:
        return _buildSunshineEffect();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDustEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: DustPainter(_controller.value),
        );
      },
    );
  }

  Widget _buildCloudyEffect() {
    return Opacity(
      opacity: 0.3,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.multiply,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[400]!,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSunshineEffect() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: SunshinePainter(_controller.value),
        );
      },
    );
  }

  List<Widget> _buildButterflies() {
    while (_butterflies.length < 3) {
      _butterflies.add(Butterfly(
        position: Offset(
          _random.nextDouble() * 300,
          _random.nextDouble() * 300,
        ),
        direction: _random.nextDouble() * math.pi * 2,
      ));
    }

    return _butterflies.map((butterfly) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          butterfly.update(_controller.value);
          return Positioned(
            left: butterfly.position.dx,
            top: butterfly.position.dy,
            child: Transform.rotate(
              angle: butterfly.direction,
              child: const Icon(
                Icons.flutter_dash,
                color: Colors.blue,
                size: 20,
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class Butterfly {
  Offset position;
  double direction;
  final math.Random _random = math.Random();

  Butterfly({
    required this.position,
    required this.direction,
  });

  void update(double time) {
    // Movimiento aleatorio suave
    direction += (_random.nextDouble() - 0.5) * 0.1;
    position += Offset(
      math.cos(direction) * 2,
      math.sin(direction) * 2,
    );

    // Mantener las mariposas dentro de la pantalla
    if (position.dx < 0) position = Offset(0, position.dy);
    if (position.dx > 300) position = Offset(300, position.dy);
    if (position.dy < 0) position = Offset(position.dx, 0);
    if (position.dy > 300) position = Offset(position.dx, 300);
  }
}

class DustPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random();

  DustPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 50; i++) {
      final x = _random.nextDouble() * size.width;
      final y = ((_random.nextDouble() + progress) % 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(DustPainter oldDelegate) => true;
}

class SunshinePainter extends CustomPainter {
  final double progress;

  SunshinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, -50);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withOpacity(0.2),
          Colors.yellow.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(
        center: center,
        radius: size.width,
      ));

    canvas.drawCircle(
      center,
      size.width * (0.8 + math.sin(progress * math.pi * 2) * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(SunshinePainter oldDelegate) => true;
}

