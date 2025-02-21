import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/mood_provider.dart';

class HeartAnimation extends StatefulWidget {
  const HeartAnimation({super.key});

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

// Estados y colores definidos
  final List<String> moodStates = [
    "Muy mal",
    "Mal",
    "Ligeramente mal",
    "Neutral",
    "Ligeramente bien",
    "Bien",
    "Muy bien",
  ];

  final List<Color> moodColors = [
    Colors.purple,    // Muy mal
    Colors.blue,      // Mal
    Colors.lightBlue, // Ligeramente mal (celeste)
    Colors.lightGreen,// Neutral (verde claro)
    Colors.green,     // Ligeramente bien (verde)
    Colors.yellow,    // Bien (amarillo)
    Colors.orange,    // Muy bien (naranja)
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  
  // Mapear el valor (0 a 100) a un índice discreto (0 a 6)
  int _getMoodStateIndex(double mood) {
    int index = (mood / 100 * 6).round();
    return index.clamp(0, 6);
  }

  // Devuelve el color asignado para el estado de ánimo
  Color _getHeartColor(double mood) {
    int index = _getMoodStateIndex(mood);
    return moodColors[index];
  }

  // Devuelve la descripción asignada para el estado de ánimo
  String _getMoodDescription(double mood) {
    int index = _getMoodStateIndex(mood);
    return moodStates[index];
  }

// Actualiza en SharedPreferences el estado de ánimo del día actual
  Future<void> _updateTodayMood(double currentMood) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('mood_history');
    Map<String, dynamic> history =
        historyString != null ? json.decode(historyString) : {};
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    history[todayKey] = currentMood;
    await prefs.setString('mood_history', json.encode(history));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Estado de ánimo actualizado en el historial")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        final currentMood = moodProvider.currentMood;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.favorite,
                size: 100,
                color: _getHeartColor(currentMood),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getMoodDescription(currentMood),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 163, 201, 165),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                await _updateTodayMood(currentMood);
              },
              child: const Text("Actualizar en Calendario"),
            ),
          ],
        );
      },
    );
  }
}

