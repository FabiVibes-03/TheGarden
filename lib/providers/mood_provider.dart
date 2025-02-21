import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_context.dart';

class MoodProvider with ChangeNotifier {
  double _currentMood = 50;
  final String _moodKey = 'current_mood';

  double get currentMood => _currentMood;

  MoodProvider() {
    _loadMood();
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    _currentMood = prefs.getDouble(_moodKey) ?? 50;
    notifyListeners();
  }

  Future<void> setMood(double value) async {
    await AppContext.withLoading(
      //message: 'Actualizando estado de ánimo...',
      action: () async {
        _currentMood = value;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_moodKey, value);

        // Guardar en el historial usando la fecha actual (sin la hora) como clave
        //final todayKey = DateTime.now().toIso8601String().split('T')[0];
        //final String? historyString = prefs.getString('mood_history');
        //Map<String, dynamic> history = historyString != null ? json.decode(historyString) : {};
        //history[todayKey] = value;
        //await prefs.setString('mood_history', json.encode(history));

        // Actualizar el jardín con el estado de ánimo y tareas recientes
        final recentTodos = AppContext.todo.getRecentTodos();
        await AppContext.garden.updateFromMoodAndTodos(value, recentTodos);

        notifyListeners();
      },
    );

    //AppContext.showMessage('¡Estado de ánimo actualizado!');
  }
}
