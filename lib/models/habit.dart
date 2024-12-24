class Habit {
  final String name;
  List<bool> days; // 7 Booleans (Index 0 = Montag, 6 = Sonntag)
  int colorValue;  // ARGB-Value z. B. 0xFF2196F3
  String emoji;    // z. B. "💦"

  Habit({
    required this.name,
    required this.days,
    required this.colorValue,
    required this.emoji,
  });

  /// Aktuellen Streak ermitteln (Anzahl an aufeinanderfolgenden True ab dem heutigen Tag rückwärts).
  int get currentStreak {
    // Heutiger Tag (0-based)
    final int todayIndex = DateTime.now().weekday - 1; 
    if (todayIndex < 0) return 0;
    int streak = 0;
    int index = todayIndex;

    while (index >= 0 && days[index]) {
      streak++;
      index--;
    }
    return streak;
  }

  /// Besten Streak (maximaler zusammenhängender True-Block in days).
  int get bestStreak {
    int best = 0;
    int currentCount = 0;

    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        currentCount++;
      } else {
        best = best < currentCount ? currentCount : best;
        currentCount = 0;
      }
    }
    // Ende der Schleife: evtl. letzten Lauf prüfen
    best = best < currentCount ? currentCount : best;
    return best;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'days': days,
      'colorValue': colorValue,
      'emoji': emoji,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      name: map['name'] as String,
      days: (map['days'] as List).map((e) => e as bool).toList(),
      colorValue: map['colorValue'] as int,
      emoji: map['emoji'] as String,
    );
  }
}
