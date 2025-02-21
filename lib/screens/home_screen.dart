import 'package:flutter/material.dart';
import '../widgets/garden_view.dart';
import '../widgets/navigation_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Jardín 3D
          const GardenView(),
          
          // Iconos de navegación
          const Positioned(
            right: 20,
            top: 60,
            child: NavigationIcons(),
          ),
        ],
      ),
    );
  }
}

