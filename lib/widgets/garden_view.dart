import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart';
import '../providers/garden_provider.dart';
import 'garden_effects.dart';
import 'package:flutter/material.dart' as material;


class GardenView extends StatefulWidget {
  const GardenView({Key? key}) : super(key: key);

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> {
  late cube.Object _gardenObject;
  cube.Scene? _scene;
  // Usamos un modelo de cubo predeterminado
  final String _defaultModel = 'assets/cube.obj';

  @override
  void initState() {
    super.initState();
    _gardenObject = cube.Object(
      fileName: _defaultModel,
      scale: Vector3(5.0, 5.0, 5.0),
      position: Vector3(0, -5, 0),
      rotation: Vector3(0, 0, 0),
    );
  }

  void _onSceneCreated(cube.Scene scene) {
    _scene = scene;
    scene.camera.position.z = 15;
    scene.light.position.setFrom(Vector3(0, 10, 10));
    scene.light.setColor(material.Colors.white, 1.0, 1.0, 0.8);
    scene.world.add(_gardenObject);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GardenProvider>(
      builder: (context, gardenProvider, child) {
        _updateGardenModel();

        return Stack(
          children: [
            // Escena 3D usando el widget Cube
            cube.Cube(
              onSceneCreated: _onSceneCreated,
            ),
            // Efectos visuales basados en el estado del jardín
            GardenEffects(
              gardenState: gardenProvider.currentState,
              stats: gardenProvider.stats,
            ),
            // Información del jardín
            Positioned(
              top: 40,
              left: 20,
              child: _buildGardenInfo(gardenProvider),
            ),
            // Acciones del jardín
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildGardenActions(gardenProvider),
            ),
          ],
        );
      },
    );
  }

  // En este ejemplo, mantenemos el modelo fijo (cubo predeterminado)
  void _updateGardenModel() {
    // Si en el futuro deseas actualizar el modelo, implementa la lógica aquí.
  }

  Widget _buildGardenInfo(GardenProvider provider) {
    final stats = provider.stats;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: material.Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salud: ${stats.health.toStringAsFixed(1)}%',
            style: TextStyle(color: material.Colors.white),
          ),
          Text(
            'Flores: ${stats.flowersCount}',
            style: TextStyle(color: material.Colors.white),
          ),
          if (stats.hasButterflies)
             Text(
              '🦋 ¡Hay mariposas!',
              style: TextStyle(color: material.Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildGardenActions(GardenProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.water_drop),
          label: const Text('Regar'),
          onPressed: () => provider.waterGarden(),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.grass),
          label: const Text('Quitar maleza'),
          onPressed: () => provider.removeWeeds(),
        ),
      ],
    );
  }
}
