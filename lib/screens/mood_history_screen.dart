import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  Map<DateTime, double> _moodHistory = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('mood_history');
    if (historyString != null) {
      final Map<String, dynamic> jsonMap = json.decode(historyString);
      setState(() {
        _moodHistory = jsonMap.map((key, value) {
          return MapEntry(DateTime.parse(key), (value as num).toDouble());
        });
      });
    }
  }

int _getMoodStateIndex(double mood) {
  int index = (mood / 100 * 6).round();
  return index.clamp(0, 6);
}

// Devuelve la descripción del estado de ánimo según el valor
  String _getMoodDescription(double mood) {
    final List<String> moodStates = [
      "Muy mal",
      "Mal",
      "Ligeramente mal",
      "Neutral",
      "Ligeramente bien",
      "Bien",
      "Muy bien",
    ];
    int index = _getMoodStateIndex(mood);
    return moodStates[index];
  }

Color _getMoodColor(double mood) {
  final List<Color> moodColors = [
    Colors.purple,    // Muy mal
    Colors.blue,      // Mal
    Colors.lightBlue, // Ligeramente mal
    Colors.lightGreen,// Neutral (verde claro)
    Colors.green,     // Ligeramente bien (verde)
    Colors.yellow,    // Bien (amarillo)
    Colors.orange,    // Muy bien (naranja)
  ];
  int index = _getMoodStateIndex(mood);
  return moodColors[index];
}

  // Comprueba si hay un estado de ánimo registrado para el día
  bool _hasMood(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _moodHistory.keys.any((date) =>
        date.year == key.year && date.month == key.month && date.day == key.day);
  }

  double? _getMood(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    try {
      return _moodHistory.entries
          .firstWhere((entry) =>
              entry.key.year == key.year &&
              entry.key.month == key.month &&
              entry.key.day == key.day)
          .value;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Estado de Ánimo")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (_hasMood(day)) {
                  final mood = _getMood(day)!;
                  return Positioned(
                    bottom: 1,
                    child: Icon(
                      Icons.favorite,
                      color: _getMoodColor(mood),
                      size: 24,
                    )
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const Divider(),
          if (_selectedDay != null && _hasMood(_selectedDay!))
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Estado de ánimo del ${_selectedDay!.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      Icons.favorite,
                      color: _getMoodColor(_getMood(_selectedDay!)!),
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getMoodDescription(_getMood(_selectedDay!)!),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No hay datos para este día."),
            ),
        ],
      ),
    );
  }
}
