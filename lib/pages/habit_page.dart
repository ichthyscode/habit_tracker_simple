import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/habit_tile.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  List<Habit> _habits = [];
  bool _filterNotDoneToday = false;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    _habits = await HabitService.loadHabits();

    // Falls beim allerersten Start noch keine Habits existieren:
    if (_habits.isEmpty) {
      _habits = [
        Habit(
          name: 'Wasser trinken',
          days: List.filled(7, false),
          colorValue: Colors.blue.value,
          emoji: '💧',
        ),
        Habit(
          name: 'Meditation',
          days: List.filled(7, false),
          colorValue: Colors.green.value,
          emoji: '🧘',
        ),
      ];
      await HabitService.saveHabits(_habits);
    }
    setState(() {});
  }

  Future<void> _saveHabits() async {
    await HabitService.saveHabits(_habits);
  }

  void _toggleDay(Habit habit, int dayIndex) {
    setState(() {
      habit.days[dayIndex] = !habit.days[dayIndex];
    });
    _saveHabits();

    // Optionale visuelle Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '„${habit.name}“ am ${dayIndex + 1}. Tag getoggelt (${habit.days[dayIndex] ? "erledigt" : "nicht erledigt"}).',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleFilter() {
    setState(() {
      _filterNotDoneToday = !_filterNotDoneToday;
    });
  }

  List<Habit> get _filteredHabits {
    if (!_filterNotDoneToday) {
      // Keine Filterung
      return _habits;
    }
    // Wochentag (0-based)
    final int todayIndex = DateTime.now().weekday - 1;
    if (todayIndex < 0) return _habits;

    // Nur die anzeigen, die HEUTE nicht erledigt sind
    return _habits.where((h) => h.days[todayIndex] == false).toList();
  }

  void _addNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController();
        final emojiCtrl = TextEditingController();
        Color selectedColor = Colors.blue;

        return AlertDialog(
          title: const Text('Neue Gewohnheit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emojiCtrl,
                  decoration: const InputDecoration(labelText: 'Emoji (optional)'),
                ),
                const SizedBox(height: 10),
                // Simple ColorPicker-Variante mit Dropdown (mini)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Farbe:'),
                    DropdownButton<Color>(
                      value: selectedColor,
                      onChanged: (Color? newVal) {
                        if (newVal == null) return;
                        setState(() {
                          selectedColor = newVal;
                        });
                      },
                      items: <Color>[
                        Colors.blue,
                        Colors.green,
                        Colors.red,
                        Colors.orange,
                        Colors.purple,
                        Colors.brown,
                      ].map((Color color) {
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Container(
                            width: 50,
                            height: 20,
                            color: color,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final emoji = emojiCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _habits.add(Habit(
                      name: name,
                      days: List.filled(7, false),
                      colorValue: selectedColor.value,
                      emoji: emoji,
                    ));
                  });
                  await _saveHabits();
                }
                Navigator.pop(context);
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = _filterNotDoneToday ? Icons.filter_alt_off : Icons.filter_alt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habit Tracker'),
        actions: [
          IconButton(
            icon: Icon(icon),
            tooltip: 'Filter: heute nicht erledigte',
            onPressed: _toggleFilter,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewHabit,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _filteredHabits.length,
        itemBuilder: (context, index) {
          final habit = _filteredHabits[index];
          return HabitTile(
            habit: habit,
            onToggleDay: (dayIndex) => _toggleDay(habit, dayIndex),
          );
        },
      ),
    );
  }
}
