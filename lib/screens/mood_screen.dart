import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_slider.dart';
import '../widgets/heart_animation.dart';
import 'mood_history_screen.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Cómo te sientes hoy?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeartAnimation(),
          const SizedBox(height: 40),
          Consumer<MoodProvider>(
            builder: (context, moodProvider, child) {
              return MoodSlider(
                value: moodProvider.currentMood,
                onChanged: (value) => moodProvider.setMood(value),
              );
            },
          ),
        ],
      ),
    );
  }
}
