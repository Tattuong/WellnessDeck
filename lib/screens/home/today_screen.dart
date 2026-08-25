import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../providers/shop_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../widgets/deck_dialogs.dart';
import '../../widgets/deck_look.dart';
import 'settings_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<WellnessProvider>();
    final shop = context.watch<ShopProvider>();
    final leftover = deck.today.workout.where((e) => !e).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 86),
        children: [
          DeckHeader(
            title: AppStrings.t(context, 'navToday'),
            subtitle: AppStrings.t(context, 'todaySubtitle'),
            actionIcon: Icons.spa_rounded,
            onAction: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
          SoftCard(
            onTap: AppTabs.goCockpit,
            child: Row(
              children: [
                const IconBubble(icon: Icons.local_fire_department_rounded, color: DeckLook.orange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.deckStreak <= 0
                            ? AppStrings.t(context, 'streakStart')
                            : AppStrings.t(context, 'streakDays', {'n': '${deck.deckStreak}'}),
                        style: DeckLook.cardTitleOf(context),
                      ),
                      Text(_streakLine(context, deck), style: DeckLook.subtitleOf(context)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: DeckLook.mutedOf(context), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 6),
          StatusMeterCard(
            icon: Icons.water_drop_rounded,
            color: DeckLook.teal,
            title: AppStrings.t(context, 'hydration'),
            value: '${deck.today.cups} / ${deck.cupGoal} ${AppStrings.t(context, 'cups')}',
            progress: deck.cupGoal == 0 ? 0 : deck.today.cups / deck.cupGoal,
            onTap: () => deck.bumpCups(),
            onLongPress: () => deck.bumpCups(down: true),
          ),
          const SizedBox(height: 6),
          StatusMeterCard(
            icon: Icons.rice_bowl_rounded,
            color: DeckLook.green,
            title: AppStrings.t(context, 'meals'),
            value: '${deck.today.mealsDone} / ${deck.mealGoal} ${AppStrings.t(context, 'done')}',
            progress: deck.mealGoal == 0 ? 0 : deck.today.mealsDone / deck.mealGoal,
            onTap: deck.bumpMeals,
          ),
          const SizedBox(height: 6),
          StatusMeterCard(
            icon: Icons.directions_run_rounded,
            color: DeckLook.blue,
            title: AppStrings.t(context, 'movement'),
            value: '${deck.today.moveMin} / ${deck.moveGoal} ${AppStrings.t(context, 'min')}',
            progress: deck.moveGoal == 0 ? 0 : deck.today.moveMin / deck.moveGoal,
            onTap: () => deck.bumpMove(5),
            onLongPress: () => deck.bumpMove(-5),
          ),
          const SizedBox(height: 6),
          StatusMeterCard(
            icon: Icons.nightlight_round,
            color: DeckLook.purple,
            title: AppStrings.t(context, 'sleep'),
            value: deck.today.sleepH == 0 ? AppStrings.t(context, 'tapToLog') : '${deck.today.sleepH.toStringAsFixed(1)} h',
            trailing: AppStrings.t(context, 'sleepGoalShort'),
            progress: (deck.today.sleepH / 9).clamp(0, 1),
            prominentValue: true,
            onTap: () => _sleep(context, deck),
          ),
          const SizedBox(height: 6),
          StatusMeterCard(
            icon: Icons.sentiment_satisfied_alt_rounded,
            color: DeckLook.pink,
            title: AppStrings.t(context, 'mood'),
            value: deck.today.mood == 0 ? '—' : deck.moodLabel(deck.today.mood),
            caption: deck.today.moodNote.isEmpty ? AppStrings.t(context, 'moodPlaceholder') : deck.today.moodNote,
            progress: deck.today.mood / 5,
            prominentValue: true,
            onTap: deck.cycleMood,
            onLongPress: () async {
              final v = await DeckDialogs.title(
                context,
                heading: AppStrings.t(context, 'mood'),
                initial: deck.today.moodNote,
                hintKey: 'moodPlaceholder',
              );
              if (v != null) await deck.setMoodNote(v);
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconBubble(icon: Icons.waves_rounded, color: DeckLook.mint, size: 26),
                          const Spacer(),
                          NavyCircleButton(
                            icon: deck.breathRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 26,
                            onTap: deck.toggleBreath,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(AppStrings.t(context, 'breathing'), style: DeckLook.cardTitleOf(context)),
                      Text(AppStrings.t(context, 'breath478title'), style: DeckLook.valueOf(context)),
                      Text(
                        shop.hasBreathPlus ? AppStrings.t(context, 'breathMinPlus') : AppStrings.t(context, 'breathMin'),
                        style: DeckLook.subtitleOf(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  onTap: AppTabs.goWorkspace,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconBubble(icon: Icons.check_rounded, color: DeckLook.purple, size: 26),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded, color: DeckLook.mutedOf(context), size: 16),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(AppStrings.t(context, 'routines'), style: DeckLook.cardTitleOf(context)),
                      Text(AppStrings.t(context, 'morningFlow'), style: DeckLook.valueOf(context).copyWith(fontSize: 13)),
                      Text('$leftover ${AppStrings.t(context, 'steps')}', style: DeckLook.subtitleOf(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SoftCard(
            onTap: () async {
              final v = await DeckDialogs.title(
                context,
                heading: AppStrings.t(context, 'intention'),
                initial: deck.today.intention,
                hintKey: 'intentionPlaceholder',
              );
              if (v != null) await deck.setIntention(v);
            },
            child: Row(
              children: [
                const IconBubble(icon: Icons.star_rounded, color: DeckLook.orange, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'intention'), style: DeckLook.cardTitleOf(context)),
                      Text(
                        deck.today.intention.isEmpty
                            ? AppStrings.t(context, 'intentionPlaceholder')
                            : deck.today.intention,
                        style: GoogleFonts.inter(fontSize: 12, height: 1.25, color: DeckLook.inkOf(context)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite_border_rounded, color: Color(0xFFE25C5C), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: DeckLook.purple, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: DeckLook.isDark(context) ? const Color(0xFF4A4660) : const Color(0xFFD9D6E3), shape: BoxShape.circle)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sleep(BuildContext context, WellnessProvider deck) async {
    final v = await DeckDialogs.title(
      context,
      heading: AppStrings.t(context, 'sleep'),
      initial: deck.today.sleepH == 0 ? '' : deck.today.sleepH.toString(),
    );
    if (v == null) return;
    await deck.setSleep(double.tryParse(v.replaceAll(',', '.')) ?? 0);
  }

  String _streakLine(BuildContext context, WellnessProvider deck) {
    final h = deck.hydrateStreak;
    final m = deck.moveStreak;
    if (h >= 2 && h >= m) return AppStrings.t(context, 'streakHydrateLine', {'n': '$h'});
    if (m >= 2) return AppStrings.t(context, 'streakMoveLine', {'n': '$m'});
    return AppStrings.t(context, 'observationOnly');
  }
}
