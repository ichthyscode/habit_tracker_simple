import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitService {
  static const String habitsKey = 'myHabits';

  /// Lädt alle Habits aus SharedPreferences
  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(habitsKey);

    if (habitsJson != null) {
      final List decoded = jsonDecode(habitsJson) as List;
      return decoded.map((map) => Habit.fromMap(map)).toList();
    } else {
      // Rückgabe einer leeren Liste, wenn noch keine vorhanden
      return [];
    }
  }

  /// Speichert die Habits in SharedPreferences
  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final List habitList = habits.map((h) => h.toMap()).toList();
    final String habitsJson = jsonEncode(habitList);
    await prefs.setString(habitsKey, habitsJson);
  }

  /// Liefert für jeden Tag (Index 0 = Montag, ..., 6 = Sonntag) die Anzahl fertig erledigter Habits.
  static List<int> completedHabitsPerDay(List<Habit> habits) {
    // Wir haben 7 Wochentage => array[7] für Zähler
    final counts = List<int>.filled(7, 0);

    for (final habit in habits) {
      for (int i = 0; i < 7; i++) {
        if (habit.days[i]) {
          counts[i]++;
        }
      }
    }
    return counts;
  }
}
