import 'package:flutter/material.dart';
import '../widgets/heart_animation.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("¿Cómo te sientes hoy?"),
      ),
      body: const HeartAnimation(),
    );
  }
}
