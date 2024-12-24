import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final Function(int) onToggleDay; 

  const HabitTile({
    Key? key,
    required this.habit,
    required this.onToggleDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int todayIndex = DateTime.now().weekday - 1;
    final Color habitColor = Color(habit.colorValue); 

    // Kurze Labels für Wochentage
    final List<String> shortDays = ['M', 'D', 'M', 'D', 'F', 'S', 'S'];

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            // Titelzeile
            ListTile(
              leading: habit.emoji.isNotEmpty 
                  ? Text(
                      habit.emoji,
                      style: const TextStyle(fontSize: 28),
                    )
                  : const SizedBox(),
              title: Text(
                habit.name,
                style: TextStyle(
                  color: habitColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                'Aktueller Streak: ${habit.currentStreak} | Bester Streak: ${habit.bestStreak}',
              ),
            ),
            // Die 7 Kästchen
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final bool done = habit.days[dayIndex];

                  return GestureDetector(
                    onTap: () => onToggleDay(dayIndex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: done ? habitColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                        border: dayIndex == todayIndex
                            ? Border.all(color: Colors.black, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          shortDays[dayIndex],
                          style: TextStyle(
                            color: done ? Colors.white : Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
