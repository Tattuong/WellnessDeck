class DayLog {
  final String date;
  int cups;
  int mealsDone;
  int moveMin;
  double sleepH;
  int mood;
  String moodNote;
  String intention;
  List<bool> workout;
  List<String> mealNotes;
  List<bool> habits;
  String journal;
  String journalPlus;
  bool eveningOn;
  Set<int> careDone;
  int energy;

  DayLog({
    required this.date,
    this.cups = 0,
    this.mealsDone = 0,
    this.moveMin = 0,
    this.sleepH = 0,
    this.mood = 0,
    this.moodNote = '',
    this.intention = '',
    List<bool>? workout,
    List<String>? mealNotes,
    List<bool>? habits,
    this.journal = '',
    this.journalPlus = '',
    this.eveningOn = false,
    Set<int>? careDone,
    this.energy = 0,
  })  : workout = _padBool(workout, 4),
        mealNotes = _padStr(mealNotes, 4),
        habits = _padBool(habits, 4),
        careDone = careDone ?? {};

  static List<bool> _padBool(List<bool>? src, int n) {
    final list = [...?src];
    while (list.length < n) {
      list.add(false);
    }
    return list.take(n).toList();
  }

  static List<String> _padStr(List<String>? src, int n) {
    final list = [...?src];
    while (list.length < n) {
      list.add('');
    }
    return list.take(n).toList();
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'cups': cups,
        'mealsDone': mealsDone,
        'moveMin': moveMin,
        'sleepH': sleepH,
        'mood': mood,
        'moodNote': moodNote,
        'intention': intention,
        'workout': workout,
        'mealNotes': mealNotes,
        'habits': habits,
        'journal': journal,
        'journalPlus': journalPlus,
        'eveningOn': eveningOn,
        'careDone': careDone.toList(),
        'energy': energy,
      };

  factory DayLog.fromJson(Map<String, dynamic> j) => DayLog(
        date: j['date'] as String? ?? '',
        cups: j['cups'] as int? ?? 0,
        mealsDone: j['mealsDone'] as int? ?? 0,
        moveMin: j['moveMin'] as int? ?? 0,
        sleepH: (j['sleepH'] as num?)?.toDouble() ?? 0,
        mood: j['mood'] as int? ?? 0,
        moodNote: j['moodNote'] as String? ?? '',
        intention: j['intention'] as String? ?? '',
        workout: [for (final e in (j['workout'] as List? ?? [])) e == true],
        mealNotes: [for (final e in (j['mealNotes'] as List? ?? [])) e.toString()],
        habits: [for (final e in (j['habits'] as List? ?? [])) e == true],
        journal: j['journal'] as String? ?? '',
        journalPlus: j['journalPlus'] as String? ?? '',
        eveningOn: j['eveningOn'] as bool? ?? false,
        careDone: {for (final e in (j['careDone'] as List? ?? [])) e as int},
        energy: j['energy'] as int? ?? 0,
      );
}

class Experiment {
  final String id;
  String title;
  bool on;

  Experiment({required this.id, required this.title, this.on = true});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'on': on};
  factory Experiment.fromJson(Map<String, dynamic> j) => Experiment(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        on: j['on'] as bool? ?? true,
      );
}
