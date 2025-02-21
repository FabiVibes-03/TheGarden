import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/garden_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/todo_provider.dart';
import '../main.dart';

// Clase de utilidad para acceder a los providers de manera más segura
class AppContext {
  static BuildContext get context {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw Exception('No se encontró el contexto de la aplicación');
    }
    return context;
  }

  static GardenProvider get garden {
    return Provider.of<GardenProvider>(context, listen: false);
  }

  static MoodProvider get mood {
    return Provider.of<MoodProvider>(context, listen: false);
  }

  static TodoProvider get todo {
    return Provider.of<TodoProvider>(context, listen: false);
  }

  // Método de utilidad para mostrar mensajes
  static void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Método de utilidad para mostrar diálogos de confirmación
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Método de utilidad para mostrar diálogos de carga
  static Future<T> withLoading<T>({
    required Future<T> Function() action,
    String message = 'Cargando...',
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await action();
      Navigator.pop(context); // Cierra el diálogo de carga
      return result;
    } catch (e) {
      Navigator.pop(context); // Cierra el diálogo de carga
      rethrow;
    }
  }
}

