import 'package:flutter/material.dart';
import '../screens/mood_screen.dart';
import '../screens/todo_screen.dart';

class NavigationIcons extends StatelessWidget {
  const NavigationIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.mood),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MoodScreen()),
            );
          },
        ),
        const SizedBox(height: 20),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TodoScreen()),
            );
          },
        ),
      ],
    );
  }
}

