import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Habit> _habits = [];
  List<int> _completedPerDay = List.filled(7, 0);

  // Labels für x-Achse
  final List<String> _weekLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitService.loadHabits();
    final completedCounts = HabitService.completedHabitsPerDay(habits);

    setState(() {
      _habits = habits;
      _completedPerDay = completedCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Chart (Balkendiagramm)
            const SizedBox(height: 16),
            Text(
              'Erledigte Habits pro Tag (Woche)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calculateMaxY(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _weekLabels.length) {
                              return Text(_weekLabels[index]);
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: _completedPerDay[index].toDouble(),
                            color: Colors.blue,
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1),
            const SizedBox(height: 10),
            Text(
              'Streak-Übersicht pro Habit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            // Liste aller Habits mit currentStreak und bestStreak
            ListView.builder(
              itemCount: _habits.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return ListTile(
                  leading: habit.emoji.isNotEmpty 
                      ? Text(habit.emoji, style: const TextStyle(fontSize: 28))
                      : const SizedBox(width: 28),
                  title: Text(
                    habit.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(habit.colorValue),
                    ),
                  ),
                  subtitle: Text(
                    'Aktueller Streak: ${habit.currentStreak} | Bester Streak: ${habit.bestStreak}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    // Evtl. 1 mehr als das Maximum, damit die Balken optisch etwas Freiraum haben
    final maxVal = _completedPerDay.fold<int>(0, (prev, elem) => elem > prev ? elem : prev);
    return (maxVal + 1).toDouble();
  }
}
