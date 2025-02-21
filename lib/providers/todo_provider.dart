import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_context.dart';

class Todo {
  final String id;
  final String title;
  final DateTime date;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.date,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'completed': completed,
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
        completed: json['completed'],
      );
}

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  final String _todosKey = 'todos';

  List<Todo> get todos => _todos;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_todosKey);
    if (todosString != null) {
      final List<dynamic> todosJson = jsonDecode(todosString);
      _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosString = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString(_todosKey, todosString);
  }

  List<Todo> getTodosForDay(DateTime date) {
    return _todos.where((todo) {
      return todo.date.year == date.year &&
          todo.date.month == date.month &&
          todo.date.day == date.day;
    }).toList();
  }

  Future<void> addTodo(String title, DateTime date) async {
    await AppContext.withLoading(
      message: 'Agregando tarea...',
      action: () async {
        final todo = Todo(
          id: DateTime.now().toString(),
          title: title,
          date: date,
        );
        _todos.add(todo);
        await _saveTodos();
        notifyListeners();
      },
    );

    AppContext.showMessage('¡Tarea agregada con éxito!');
  }

  List<bool> getRecentTodos() {
    final now = DateTime.now();
    return _todos
        .where((todo) =>
            now.difference(todo.date).inDays <= 1) // Tareas del último día
        .map((todo) => todo.completed)
        .toList();
  }

  Future<void> toggleTodo(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      await AppContext.withLoading(
        message: 'Actualizando tarea...',
        action: () async {
          _todos[todoIndex].completed = !_todos[todoIndex].completed;
          await _saveTodos();
          
          // Actualizar el jardín
          await AppContext.garden.updateFromMoodAndTodos(
            AppContext.mood.currentMood,
            getRecentTodos(),
          );
          
          notifyListeners();
        },
      );

      AppContext.showMessage(
        _todos[todoIndex].completed
            ? '¡Tarea completada!'
            : 'Tarea marcada como pendiente',
      );
    }
  }

  Future<void> deleteTodo(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      final confirmed = await AppContext.showConfirmDialog(
        title: 'Eliminar tarea',
        message: '¿Estás seguro de que deseas eliminar esta tarea?',
      );

      if (confirmed) {
        await AppContext.withLoading(
          message: 'Eliminando tarea...',
          action: () async {
            _todos.removeAt(todoIndex);
            await _saveTodos();
            notifyListeners();
          },
        );

        AppContext.showMessage('Tarea eliminada');
      }
    }
  }
}

