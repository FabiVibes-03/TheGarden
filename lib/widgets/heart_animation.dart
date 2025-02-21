import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/mood_provider.dart';
import '../screens/mood_history_screen.dart';

class HeartAnimation extends StatefulWidget {
  const HeartAnimation({super.key});

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _sliderValue = 50;

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
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getMoodStateIndex(double mood) {
    int index = (mood / 100 * 6).round();
    return index.clamp(0, 6);
  }

  Color _getHeartColor(double mood) {
    int index = _getMoodStateIndex(mood);
    return moodColors[index];
  }

  String _getMoodDescription(double mood) {
    int index = _getMoodStateIndex(mood);
    return moodStates[index];
  }

  Future<void> _updateTodayMood() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('mood_history');
    Map<String, dynamic> history =
        historyString != null ? json.decode(historyString) : {};
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    history[todayKey] = _sliderValue;
    await prefs.setString('mood_history', json.encode(history));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Estado de ánimo actualizado en el historial")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return Stack(
          children: [
            // Contenido principal
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // Espacio para que no se solape el botón de calendario
                  const Text(
                    "Elige cómo te sientes ahora mismo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Corazón con efecto de ondas
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _getHeartColor(_sliderValue).withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.2, 1],
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          Icons.favorite,
                          size: 90,
                          color: _getHeartColor(_sliderValue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getMoodDescription(_sliderValue),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  // Slider con degradado y efecto de brillo
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(169, 196, 34, 224).withOpacity(0.7),
                                  const Color.fromARGB(226, 31, 138, 225).withOpacity(0.7),
                                  const Color.fromARGB(218, 72, 220, 76).withOpacity(0.7),
                                  const Color.fromARGB(222, 219, 156, 61).withOpacity(0.7),
                                ],
                                stops: const [0.0, 0.3, 0.6, 1.0],
                              ),
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbColor: Colors.white,
                              overlayColor: Colors.white.withOpacity(0.3),
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            ),
                            child: Slider(
                              min: 0,
                              max: 100,
                              value: _sliderValue,
                              onChanged: (value) {
                                setState(() {
                                  _sliderValue = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("MUY MAL", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text("MUY BIEN", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Botón para actualizar en el historial
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(237, 234, 229, 230),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 19, 31, 43),),
                    ),
                    onPressed: _updateTodayMood,
                    child: const Text("Siguiente"),
                  ),
                ],
              ),
            ),
            // Botón de calendario en la esquina superior derecha
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
