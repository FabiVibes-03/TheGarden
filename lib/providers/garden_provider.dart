import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

enum GardenState {
  withered,    // 0-20% salud
  unhealthy,   // 21-40% salud
  normal,      // 41-60% salud
  healthy,     // 61-80% salud
  thriving     // 81-100% salud
}

class GardenStats {
  final double health;
  final int flowersCount;
  final bool hasButterflies;
  final DateTime lastUpdate;

  GardenStats({
    required this.health,
    required this.flowersCount,
    required this.hasButterflies,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() => {
    'health': health,
    'flowersCount': flowersCount,
    'hasButterflies': hasButterflies,
    'lastUpdate': lastUpdate.toIso8601String(),
  };

  factory GardenStats.fromJson(Map<String, dynamic> json) => GardenStats(
    health: json['health'] ?? 100.0,
    flowersCount: json['flowersCount'] ?? 0,
    hasButterflies: json['hasButterflies'] ?? false,
    lastUpdate: DateTime.parse(json['lastUpdate']),
  );

  factory GardenStats.initial() => GardenStats(
    health: 100.0,
    flowersCount: 0,
    hasButterflies: false,
    lastUpdate: DateTime.now(),
  );
}

class GardenProvider with ChangeNotifier {
  GardenStats _stats = GardenStats.initial();
  Timer? _updateTimer;
  final Random _random = Random();
  static const String _statsKey = 'garden_stats';

  // Getters
  GardenStats get stats => _stats;
  GardenState get currentState {
    if (_stats.health <= 20) return GardenState.withered;
    if (_stats.health <= 40) return GardenState.unhealthy;
    if (_stats.health <= 60) return GardenState.normal;
    if (_stats.health <= 80) return GardenState.healthy;
    return GardenState.thriving;
  }

  String get modelName {
    switch (currentState) {
      case GardenState.withered:
        return 'garden_withered.obj';
      case GardenState.unhealthy:
        return 'garden_unhealthy.obj';
      case GardenState.normal:
        return 'garden_normal.obj';
      case GardenState.healthy:
        return 'garden_healthy.obj';
      case GardenState.thriving:
        return 'garden_thriving.obj';
    }
  }

  GardenProvider() {
    _loadStats();
    _startPeriodicUpdate();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_statsKey);
    if (statsJson != null) {
      _stats = GardenStats.fromJson(Map<String, dynamic>.from(
        json.decode(statsJson),
      ));
      notifyListeners();
    }
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(_stats.toJson()));
  }

  void _startPeriodicUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(hours: 6), (timer) {
      _naturalHealthDecay();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _naturalHealthDecay() {
    // Reducción natural de la salud con el tiempo
    final timeSinceLastUpdate = DateTime.now().difference(_stats.lastUpdate);
    final decayRate = 2.0 * (timeSinceLastUpdate.inHours / 24); // 2% por día
    
    _updateHealth(-decayRate);
  }

  Future<void> _updateHealth(double change) async {
    final newHealth = (_stats.health + change).clamp(0.0, 100.0);
    final oldState = currentState;

    _stats = GardenStats(
      health: newHealth,
      flowersCount: _calculateFlowers(newHealth),
      hasButterflies: newHealth > 75 && _random.nextBool(),
      lastUpdate: DateTime.now(),
    );

    await _saveStats();
    
    if (oldState != currentState) {
      // El estado del jardín ha cambiado, podríamos trigger una animación
      // o efecto especial aquí
    }

    notifyListeners();
  }

  int _calculateFlowers(double health) {
    // Calcula el número de flores basado en la salud
    if (health < 20) return 0;
    if (health < 40) return _random.nextInt(2) + 1;
    if (health < 60) return _random.nextInt(3) + 2;
    if (health < 80) return _random.nextInt(4) + 3;
    return _random.nextInt(5) + 4;
  }

  Future<void> updateFromMoodAndTodos(double moodValue, List<bool> recentTodos) async {
    if (recentTodos.isEmpty) return;

    // Calcula el impacto del estado de ánimo (entre -2 y +2)
    final moodImpact = ((moodValue - 50) / 50) * 2;

    // Calcula el impacto de las tareas completadas
    final completedTodos = recentTodos.where((done) => done).length;
    final todoImpact = (completedTodos / recentTodos.length) * 3;

    // Añade un factor aleatorio para hacer las actualizaciones más interesantes
    final randomFactor = _random.nextDouble() * 0.5 + 0.75; // Entre 0.75 y 1.25

    // Combina todos los factores
    final totalChange = (moodImpact + todoImpact) * randomFactor;

    await _updateHealth(totalChange);
  }

  // Eventos especiales que pueden ocurrir en el jardín
  Future<void> waterGarden() async {
    if (DateTime.now().difference(_stats.lastUpdate) > const Duration(hours: 12)) {
      await _updateHealth(5.0);
    }
  }

  Future<void> removeWeeds() async {
    if (_stats.health < 50) {
      await _updateHealth(3.0);
    }
  }
}

