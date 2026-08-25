import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/shop_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/deck_dialogs.dart';
import '../../widgets/deck_look.dart';

class BuildScreen extends StatelessWidget {
  const BuildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<WellnessProvider>();
    context.watch<ShopProvider>();
    final wDone = deck.today.workout.where((e) => e).length;
    final hDone = deck.today.habits.where((e) => e).length;
    final ring = deck.breakCap == 0 ? 0.0 : deck.breakRemain / deck.breakCap;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 86),
        children: [
          DeckHeader(
            title: AppStrings.t(context, 'buildTitle'),
            subtitle: AppStrings.t(context, 'buildSubtitle'),
            actionIcon: Icons.edit_rounded,
            onAction: () => _edit(context, deck),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBubble(icon: Icons.fitness_center_rounded, color: DeckLook.purple, size: 36),
                      const SizedBox(height: 8),
                      Text(AppStrings.t(context, 'workoutPlan'), style: DeckLook.cardTitleOf(context)),
                      const SizedBox(height: 8),
                      for (var i = 0; i < deck.workoutLabels.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => deck.toggleWorkout(i),
                            child: Row(
                              children: [
                                CircleCheck(on: deck.today.workout[i], onColor: DeckLook.purple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(deck.workoutLabels[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: DeckLook.inkOf(context))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Text('$wDone / ${deck.workoutLabels.length} ${AppStrings.t(context, 'done')}', style: DeckLook.subtitleOf(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconBubble(icon: Icons.rice_bowl_rounded, color: DeckLook.purple, size: 36),
                          const Spacer(),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert_rounded, color: DeckLook.mutedOf(context), size: 20),
                            onSelected: (v) {
                              if (v == 'clear') {
                                for (var i = 0; i < deck.mealLabels.length; i++) {
                                  deck.setMealNote(i, '');
                                }
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'clear', child: Text(AppStrings.t(context, 'reset'))),
                            ],
                          ),
                        ],
                      ),
                      Text(AppStrings.t(context, 'mealNotes'), style: DeckLook.cardTitleOf(context)),
                      const SizedBox(height: 8),
                      for (var i = 0; i < deck.mealLabels.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () async {
                              final v = await DeckDialogs.title(
                                context,
                                heading: deck.mealLabels[i],
                                initial: deck.today.mealNotes.length > i ? deck.today.mealNotes[i] : '',
                              );
                              if (v != null) await deck.setMealNote(i, v);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleCheck(
                                  on: deck.today.mealNotes.length > i && deck.today.mealNotes[i].isNotEmpty,
                                  onColor: DeckLook.green,
                                  offColor: const Color(0xFFE7A0B0),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(deck.mealLabels[i], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: DeckLook.inkOf(context))),
                                      Text(
                                        (deck.today.mealNotes.length > i && deck.today.mealNotes[i].isNotEmpty)
                                            ? deck.today.mealNotes[i]
                                            : AppStrings.t(context, 'addANote'),
                                        style: GoogleFonts.inter(fontSize: 11, color: DeckLook.mutedOf(context), height: 1.25),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBubble(icon: Icons.layers_rounded, color: DeckLook.blue, size: 36),
                      const SizedBox(height: 8),
                      Text(AppStrings.t(context, 'habitStack'), style: DeckLook.cardTitleOf(context)),
                      const SizedBox(height: 8),
                      for (var i = 0; i < deck.habitLabels.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => deck.toggleHabit(i),
                            child: Row(
                              children: [
                                CircleCheck(on: deck.today.habits[i], onColor: DeckLook.green, offColor: const Color(0xFFD8D5E2)),
                                const SizedBox(width: 8),
                                Text(deck.habitLabels[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: DeckLook.inkOf(context))),
                              ],
                            ),
                          ),
                        ),
                      Text('$hDone / ${deck.habitLabels.length} ${AppStrings.t(context, 'done')}', style: DeckLook.subtitleOf(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoftCard(
                  onTap: deck.toggleBreak,
                  onLongPress: deck.resetBreak,
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: IconBubble(icon: Icons.desktop_windows_outlined, color: DeckLook.mint, size: 36),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppStrings.t(context, 'screenBreak'), style: DeckLook.cardTitleOf(context)),
                      ),
                      const SizedBox(height: 12),
                      BreakRing(
                        progress: ring,
                        clock: deck.clock(deck.breakRemain),
                        hint: AppStrings.t(context, 'tapToStart'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _mini(
                  context,
                  Icons.favorite_rounded,
                  DeckLook.blue,
                  AppStrings.t(context, 'selfCare'),
                  '${deck.careIdeas.length} ${AppStrings.t(context, 'ideas')}',
                  () => _care(context, deck),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _mini(
                  context,
                  Icons.menu_book_rounded,
                  DeckLook.purple,
                  AppStrings.t(context, 'journal'),
                  AppStrings.t(context, 'writeFreely'),
                  () => _journal(context, deck),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _mini(
                  context,
                  Icons.notifications_rounded,
                  DeckLook.pink,
                  AppStrings.t(context, 'reminders'),
                  '${deck.remindersSet} set',
                  () => _reminders(context, deck),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              children: [
                const IconBubble(icon: Icons.nights_stay_rounded, color: DeckLook.purple, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'eveningReminder'), style: DeckLook.cardTitleOf(context)),
                      Text(AppStrings.t(context, 'eveningLine'), style: DeckLook.subtitleOf(context)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: deck.today.eveningOn,
                  activeTrackColor: DeckLook.purple,
                  onChanged: (_) => deck.toggleEvening(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(BuildContext context, IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon: icon, color: color, size: 34),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: DeckLook.inkOf(context), height: 1.2)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: Text(sub, style: GoogleFonts.inter(fontSize: 11, color: DeckLook.mutedOf(context)))),
              Icon(Icons.chevron_right_rounded, size: 18, color: DeckLook.mutedOf(context)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WellnessProvider deck) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t(ctx, 'buildTitle'), style: DeckLook.cardTitleOf(context).copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.t(ctx, 'reset')),
                subtitle: Text(AppStrings.t(ctx, 'workoutPlan')),
                onTap: () async {
                  for (var i = 0; i < deck.workoutLabels.length; i++) {
                    if (deck.today.workout[i]) await deck.toggleWorkout(i);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _journal(BuildContext context, WellnessProvider deck) async {
    final v = await DeckDialogs.title(context, heading: AppStrings.t(context, 'journal'), initial: deck.today.journal, hintKey: 'journalHint');
    if (v != null) await deck.setJournal(v);
    if (!context.mounted) return;
    if (context.read<ShopProvider>().hasJournalPlus) {
      final extra = await DeckDialogs.title(
        context,
        heading: AppStrings.t(context, 'journalPlusTitle'),
        initial: deck.today.journalPlus,
        hintKey: 'journalPlusHint',
      );
      if (extra != null) await deck.setJournalPlus(extra);
    }
  }

  Future<void> _reminders(BuildContext context, WellnessProvider deck) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: deck,
          builder: (_, __) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(AppStrings.t(ctx, 'reminders'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(AppStrings.t(ctx, 'remindersHint'), style: const TextStyle(color: Color(0xFF6B7288), fontSize: 12)),
                  ),
                  if (!deck.phoneAlertsOn)
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: Text(AppStrings.t(ctx, 'reminderAllowAlerts')),
                      onTap: () async {
                        final ok = await deck.enablePhoneAlerts();
                        if (!ok && ctx.mounted) {
                          AppToast.show(
                            ctx,
                            title: AppStrings.t(ctx, 'reminderPermissionDenied'),
                            icon: Icons.notifications_off_outlined,
                          );
                        }
                      },
                    ),
                  CheckboxListTile(
                    value: deck.reminderOn[0],
                    onChanged: (_) => _toggleReminder(ctx, deck, 0),
                    title: Text(AppStrings.t(ctx, 'reminderMorning')),
                    subtitle: Text(AppStrings.t(ctx, 'reminderMorningTime')),
                  ),
                  CheckboxListTile(
                    value: deck.reminderOn[1],
                    onChanged: (_) => _toggleReminder(ctx, deck, 1),
                    title: Text(AppStrings.t(ctx, 'reminderMidday')),
                    subtitle: Text(AppStrings.t(ctx, 'reminderMiddayTime')),
                  ),
                  CheckboxListTile(
                    value: deck.reminderOn[2],
                    onChanged: (_) => _toggleReminder(ctx, deck, 2),
                    title: Text(AppStrings.t(ctx, 'reminderEvening')),
                    subtitle: Text(AppStrings.t(ctx, 'reminderEveningTime')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleReminder(BuildContext context, WellnessProvider deck, int i) async {
    final ok = await deck.toggleReminder(i);
    if (!ok && context.mounted) {
      AppToast.show(
        context,
        title: AppStrings.t(context, 'reminderPermissionDenied'),
        icon: Icons.notifications_off_outlined,
      );
    }
  }

  Future<void> _care(BuildContext context, WellnessProvider deck) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListenableBuilder(
        listenable: deck,
        builder: (_, __) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(AppStrings.t(ctx, 'selfCare'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              for (var i = 0; i < deck.careIdeas.length; i++)
                CheckboxListTile(
                  value: deck.today.careDone.contains(i),
                  onChanged: (_) => deck.toggleCare(i),
                  title: Text(deck.careIdeas[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
