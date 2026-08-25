import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/reminder_service.dart';
import '../core/services/storage_service.dart';
import '../models/wellness_models.dart';
import 'shop_provider.dart';

class WellnessProvider extends ChangeNotifier {
  static const _dataKey = 'wd_deck';
  static const _onboardKey = 'wd_onboarding_done';
  static const _shotSeedKey = 'wd_shot_seed_v1';

  ShopProvider? _shop;
  Timer? _breathTick;
  Timer? _breakTick;

  bool onboardingComplete = false;
  String patternRange = '7';
  int breathRemain = 120;
  bool breathRunning = false;
  int breakRemain = 15 * 60;
  bool breakRunning = false;
  String weeklyWentWell = '';
  String weeklyHard = '';
  String weeklyNext = '';
  List<Experiment> experiments = [];
  List<bool> reminderOn = [false, false, false];
  Map<String, DayLog> days = {};

  bool _initialized = false;

  void bindShop(ShopProvider shop) {
    _shop?.removeListener(_onShop);
    _shop = shop;
    _shop!.addListener(_onShop);
  }

  void _onShop() {
    if (!breathRunning && breathRemain > breathCap) breathRemain = breathCap;
    if (!breakRunning && breakRemain > breakCap) breakRemain = breakCap;
    notifyListeners();
  }

  DayLog get today {
    final k = _dateKey(DateTime.now());
    return days.putIfAbsent(k, () => DayLog(date: k));
  }

  int get cupGoal => (_shop?.hasHydratePlus ?? false) ? 10 : 8;
  int get mealGoal => (_shop?.hasMealPlus ?? false) ? 4 : 3;
  int get moveGoal => (_shop?.hasMovePlus ?? false) ? 60 : 45;
  int get breathCap => (_shop?.hasBreathPlus ?? false) ? 240 : 120;
  int get breakCap => (_shop?.hasBreakPlus ?? false) ? 25 * 60 : 15 * 60;

  List<String> get careIdeas {
    const base = [
      'Walk outside',
      'Stretch 5 min',
      'Warm drink',
      'Silence 10 min',
      'Tidy one surface',
      'Message a friend',
      'Read 5 pages',
      'Slow exhale x8',
    ];
    if (!(_shop?.hasCarePlus ?? false)) return base;
    return [...base, 'Sunlight 2 min', 'Feet on floor pause', 'Name 3 sounds', 'Shoulder roll'];
  }

  List<String> get workoutLabels => const ['Warm up', 'Strength', 'Mobility', 'Cool down'];
  List<String> get habitLabels => const ['Hydrate', 'Move', 'Breathe', 'Reflect'];
  List<String> get mealLabels {
    final labels = ['Breakfast', 'Lunch', 'Dinner'];
    if (_shop?.hasMealPlus ?? false) return [...labels, 'Snack'];
    return labels;
  }

  bool get show90 => _shop?.hasPattern90 ?? false;

  String get disclaimer => 'Observation only. Not a diagnosis. Not medical advice.';

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    onboardingComplete = await StorageService.instance.getBool(_onboardKey) ?? false;
    await _load();
    final seeded = await StorageService.instance.getBool(_shotSeedKey) ?? false;
    if (!seeded) {
      _seedShot();
      onboardingComplete = true;
      await StorageService.instance.saveBool(_onboardKey, true);
      await StorageService.instance.saveBool(_shotSeedKey, true);
      await _save();
    }
    await ReminderService.instance.sync(reminderOn);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingComplete = true;
    await StorageService.instance.saveBool(_onboardKey, true);
    notifyListeners();
  }

  void setRange(String r) {
    if (r == '90' && !show90) return;
    patternRange = r;
    notifyListeners();
  }

  Future<void> bumpCups({bool down = false}) async {
    today.cups = (today.cups + (down ? -1 : 1)).clamp(0, cupGoal);
    await _persist();
  }

  Future<void> bumpMeals() async {
    today.mealsDone = today.mealsDone >= mealGoal ? 0 : today.mealsDone + 1;
    await _persist();
  }

  Future<void> bumpMove(int delta) async {
    today.moveMin = (today.moveMin + delta).clamp(0, 180);
    await _persist();
  }

  Future<void> setSleep(double h) async {
    today.sleepH = h.clamp(0, 14);
    await _persist();
  }

  Future<void> cycleMood() async {
    today.mood = today.mood >= 5 ? 0 : today.mood + 1;
    today.energy = today.mood;
    await _persist();
  }

  Future<void> setMoodNote(String v) async {
    today.moodNote = v.trim();
    await _persist();
  }

  Future<void> setIntention(String v) async {
    today.intention = v.trim();
    await _persist();
  }

  Future<void> toggleWorkout(int i) async {
    today.workout[i] = !today.workout[i];
    await _persist();
  }

  Future<void> setMealNote(int i, String v) async {
    while (today.mealNotes.length <= i) {
      today.mealNotes.add('');
    }
    today.mealNotes[i] = v;
    await _persist();
  }

  Future<void> toggleHabit(int i) async {
    today.habits[i] = !today.habits[i];
    await _persist();
  }

  Future<void> setJournal(String v) async {
    today.journal = v;
    _shop?.rewardForJobSave();
    await _persist();
  }

  Future<void> setJournalPlus(String v) async {
    today.journalPlus = v;
    await _persist();
  }

  bool get phoneAlertsOn => ReminderService.instance.alertsAllowed;

  Future<bool> toggleReminder(int i) async {
    if (i < 0 || i >= reminderOn.length) return false;
    final turningOn = !reminderOn[i];
    if (turningOn && !ReminderService.instance.alertsAllowed) {
      final ok = await ReminderService.instance.requestPermission();
      if (!ok) {
        notifyListeners();
        return false;
      }
    }
    reminderOn[i] = turningOn;
    await _persist();
    await ReminderService.instance.sync(reminderOn);
    return true;
  }

  Future<bool> enablePhoneAlerts() async {
    final ok = await ReminderService.instance.requestPermission();
    if (ok) await ReminderService.instance.sync(reminderOn);
    notifyListeners();
    return ok;
  }

  int get remindersSet => reminderOn.where((e) => e).length;

  bool dayHasLog(DayLog d) =>
      d.cups > 0 ||
      d.mealsDone > 0 ||
      d.moveMin > 0 ||
      d.sleepH > 0 ||
      d.mood > 0 ||
      d.intention.trim().isNotEmpty ||
      d.journal.trim().isNotEmpty;

  int get deckStreak => streak(dayHasLog);
  int get hydrateStreak => streak((d) => d.cups > 0);
  int get moveStreak => streak((d) => d.moveMin > 0);

  Future<void> toggleEvening() async {
    today.eveningOn = !today.eveningOn;
    await _persist();
  }

  Future<void> toggleCare(int i) async {
    if (today.careDone.contains(i)) {
      today.careDone.remove(i);
    } else {
      today.careDone.add(i);
    }
    await _persist();
  }

  Future<void> addExperiment(String title) async {
    if (title.trim().isEmpty) return;
    experiments = [
      ...experiments,
      Experiment(id: 'x-${DateTime.now().microsecondsSinceEpoch}', title: title.trim()),
    ];
    await _persist();
  }

  Future<void> toggleExperiment(String id) async {
    experiments = [
      for (final e in experiments)
        if (e.id == id) Experiment(id: e.id, title: e.title, on: !e.on) else e
    ];
    await _persist();
  }

  Future<void> deleteExperiment(String id) async {
    experiments = [for (final e in experiments) if (e.id != id) e];
    await _persist();
  }

  Future<void> setReflection({String? well, String? hard, String? next}) async {
    if (well != null) weeklyWentWell = well;
    if (hard != null) weeklyHard = hard;
    if (next != null) weeklyNext = next;
    await _persist();
  }

  void toggleBreath() {
    if (breathRunning) {
      _breathTick?.cancel();
      breathRunning = false;
    } else {
      if (breathRemain <= 0) breathRemain = breathCap;
      breathRunning = true;
      _breathTick?.cancel();
      _breathTick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (breathRemain <= 0) {
          _breathTick?.cancel();
          breathRunning = false;
          notifyListeners();
          return;
        }
        breathRemain--;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void resetBreath() {
    _breathTick?.cancel();
    breathRunning = false;
    breathRemain = breathCap;
    notifyListeners();
  }

  void toggleBreak() {
    if (breakRunning) {
      _breakTick?.cancel();
      breakRunning = false;
    } else {
      if (breakRemain <= 0) breakRemain = breakCap;
      breakRunning = true;
      _breakTick?.cancel();
      _breakTick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (breakRemain <= 0) {
          _breakTick?.cancel();
          breakRunning = false;
          notifyListeners();
          return;
        }
        breakRemain--;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void resetBreak() {
    _breakTick?.cancel();
    breakRunning = false;
    breakRemain = breakCap;
    notifyListeners();
  }

  String clock(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String moodLabel(int m) => switch (m) {
        1 => 'Low',
        2 => 'Okay',
        3 => 'Steady',
        4 => 'Good',
        5 => 'Bright',
        _ => 'Tap to log',
      };

  List<DayLog> rangeLogs() {
    final n = int.tryParse(patternRange) ?? 7;
    final now = DateTime.now();
    return [
      for (var i = n - 1; i >= 0; i--)
        days[_dateKey(now.subtract(Duration(days: i)))] ?? DayLog(date: _dateKey(now.subtract(Duration(days: i)))),
    ];
  }

  double avg(double Function(DayLog d) pick) {
    final logs = rangeLogs().where((d) => pick(d) > 0).toList();
    if (logs.isEmpty) return 0;
    return logs.map(pick).reduce((a, b) => a + b) / logs.length;
  }

  List<double> series(double Function(DayLog d) pick) => [for (final d in rangeLogs()) pick(d)];

  int streak(bool Function(DayLog d) ok) {
    var n = 0;
    final now = DateTime.now();
    var started = false;
    for (var i = 0; i < 90; i++) {
      final log = days[_dateKey(now.subtract(Duration(days: i)))];
      final hit = log != null && ok(log);
      if (!hit) {
        if (!started && i == 0) continue;
        break;
      }
      started = true;
      n++;
    }
    return n;
  }

  String observation() {
    final logs = rangeLogs().where((d) => d.sleepH > 0 && d.mood > 0).toList();
    if (logs.length < 3) {
      return 'Log sleep and mood for a few days to see a pattern. $disclaimer';
    }
    final rest = logs.where((d) => d.sleepH >= 7);
    final short = logs.where((d) => d.sleepH < 7);
    if (rest.isEmpty || short.isEmpty) {
      return 'Keep logging. Patterns need both restful and short nights. $disclaimer';
    }
    final restMood = rest.map((d) => d.mood).reduce((a, b) => a + b) / rest.length;
    final shortMood = short.map((d) => d.mood).reduce((a, b) => a + b) / short.length;
    if (restMood > shortMood) {
      return 'On days you sleep 7h+, mood tends to read higher the next entries. $disclaimer';
    }
    return 'Sleep length and mood do not line up clearly in this window. $disclaimer';
  }

  void _seedShot() {
    final now = DateTime.now();
    days = {};
    for (var i = 13; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final k = _dateKey(d);
      final today = i == 0;
      final shortNight = i == 2 || i == 6 || i == 10;
      days[k] = DayLog(
        date: k,
        cups: i == 5 ? 0 : (today ? 6 : 5 + (i % 3)),
        mealsDone: today ? 2 : 2 + (i % 2),
        moveMin: i == 7 ? 0 : (today ? 30 : 22 + (i % 5) * 4),
        sleepH: today ? 7.5 : (shortNight ? 6.2 : 7.4 + (i % 5) * 0.15),
        mood: today ? 4 : (shortNight ? 3 : 4),
        energy: today ? 4 : (shortNight ? 3 : 4),
        moodNote: today ? 'Grateful, calm' : '',
        intention: today ? 'I choose focus and kindness' : '',
        workout: today ? [true, false, false, false] : [true, true, false, false],
        mealNotes: today ? ['Oats, berries, nuts', 'Quinoa bowl', '', ''] : ['', '', '', ''],
        habits: today ? [true, true, true, false] : [true, true, i < 4, false],
        journal: i <= 2 ? (today ? 'Felt steady after a walk.' : 'Noted the day.') : '',
        eveningOn: today,
        careDone: today ? {0, 2} : {},
      );
    }
    experiments = [Experiment(id: 'x-seed', title: 'Morning light + hydration')];
    reminderOn = [true, true, true];
    weeklyWentWell = 'Morning walk and water before coffee.';
    weeklyHard = 'Screens late two nights.';
    weeklyNext = 'Lights down by 9:30.';
    patternRange = '7';
  }

  Future<void> _persist() async {
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final data = await StorageService.instance.getData(_dataKey);
    if (data == null) return;
    patternRange = data['patternRange'] as String? ?? '7';
    weeklyWentWell = data['weeklyWentWell'] as String? ?? '';
    weeklyHard = data['weeklyHard'] as String? ?? '';
    weeklyNext = data['weeklyNext'] as String? ?? '';
    reminderOn = [
      for (final e in (data['reminderOn'] as List? ?? [false, false, false])) e == true,
    ];
    while (reminderOn.length < 3) {
      reminderOn.add(false);
    }
    reminderOn = reminderOn.take(3).toList();
    final ex = data['experiments'];
    if (ex is List) {
      experiments = [for (final e in ex) if (e is Map<String, dynamic>) Experiment.fromJson(e)];
    }
    final rawDays = data['days'];
    if (rawDays is Map) {
      days = {
        for (final e in rawDays.entries)
          if (e.value is Map<String, dynamic>) e.key.toString(): DayLog.fromJson(e.value as Map<String, dynamic>),
      };
    }
  }

  Future<void> _save() async {
    await StorageService.instance.saveData(_dataKey, {
      'patternRange': patternRange,
      'weeklyWentWell': weeklyWentWell,
      'weeklyHard': weeklyHard,
      'weeklyNext': weeklyNext,
      'reminderOn': reminderOn,
      'experiments': [for (final e in experiments) e.toJson()],
      'days': {for (final e in days.entries) e.key: e.value.toJson()},
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _shop?.removeListener(_onShop);
    _breathTick?.cancel();
    _breakTick?.cancel();
    super.dispose();
  }
}
