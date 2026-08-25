import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../providers/shop_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../widgets/deck_dialogs.dart';
import '../../widgets/deck_look.dart';

class PatternsScreen extends StatelessWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<WellnessProvider>();
    final shop = context.watch<ShopProvider>();
    final sleep = deck.avg((d) => d.sleepH);
    final energy = deck.avg((d) => d.energy.toDouble());
    final mood = deck.avg((d) => d.mood.toDouble());
    final cups = deck.avg((d) => d.cups.toDouble());
    final move = deck.avg((d) => d.moveMin.toDouble());
    final hydraStreak = deck.streak((d) => d.cups > 0);
    final moveStreak = deck.streak((d) => d.moveMin > 0);
    final journalStreak = deck.streak((d) => d.journal.trim().isNotEmpty);
    final experimentLine = deck.experiments.isEmpty
        ? AppStrings.t(context, 'experimentSample')
        : deck.experiments.first.title;
    final reflectLine = deck.weeklyWentWell.isEmpty
        ? AppStrings.t(context, 'reflectHint')
        : deck.weeklyWentWell;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 86),
        children: [
          DeckHeader(
            title: AppStrings.t(context, 'patternStudio'),
            subtitle: AppStrings.t(context, 'patternSubtitle'),
            actionIcon: Icons.tag_rounded,
            onAction: () => AppTabs.goShop(features: true),
          ),
          RangePills(
            selected: deck.patternRange,
            onSelect: (id) {
              if (id == '90' && !shop.hasPattern90) {
                AppTabs.goShop(features: true);
                return;
              }
              deck.setRange(id);
            },
            items: [
              ('7', AppStrings.t(context, 'days7')),
              ('30', AppStrings.t(context, 'days30')),
              ('90', AppStrings.t(context, 'days90')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metric(
                  context,
                  Icons.nightlight_round,
                  DeckLook.purple,
                  AppStrings.t(context, 'sleep'),
                  sleep == 0 ? '—' : '${sleep.toStringAsFixed(1)} h',
                  deck.series((d) => d.sleepH),
                  bars: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  context,
                  Icons.bolt_rounded,
                  DeckLook.green,
                  AppStrings.t(context, 'energy'),
                  energy == 0 ? '—' : deck.moodLabel(energy.round()),
                  deck.series((d) => d.energy.toDouble()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metric(
                  context,
                  Icons.sentiment_satisfied_alt_rounded,
                  DeckLook.pink,
                  AppStrings.t(context, 'mood'),
                  mood == 0 ? '—' : '${mood.toStringAsFixed(1)} / 5',
                  deck.series((d) => d.mood.toDouble()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  context,
                  Icons.water_drop_rounded,
                  DeckLook.blue,
                  AppStrings.t(context, 'hydration'),
                  cups == 0 ? '—' : '${cups.toStringAsFixed(1)} ${AppStrings.t(context, 'cups')}',
                  deck.series((d) => d.cups.toDouble()),
                  bars: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: _metric(
                context,
                Icons.directions_run_rounded,
                DeckLook.orange,
                AppStrings.t(context, 'activity'),
                move == 0 ? '—' : '${move.toStringAsFixed(0)} ${AppStrings.t(context, 'min')}',
                deck.series((d) => d.moveMin.toDouble()),
                bars: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: DeckLook.isDark(context)
                    ? const [Color(0xFF2C3250), Color(0xFF1C2238)]
                    : const [Color(0xFF1A1C3D), Color(0xFF243056)],
              ),
              border: DeckLook.isDark(context) ? Border.all(color: const Color(0xFF4A5170)) : null,
              boxShadow: DeckLook.shadowOf(context),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(left: 140),
                    child: WaveBackdrop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.t(context, 'patternObservation'), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        _body(deck),
                        style: GoogleFonts.inter(color: const Color(0xFFD7DCE8), height: 1.4, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Text(AppStrings.t(context, 'observationOnly'), style: GoogleFonts.inter(color: const Color(0xFF9AA3B8), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: DeckLook.orange, size: 18),
                    const SizedBox(width: 6),
                    Text(AppStrings.t(context, 'streaks'), style: DeckLook.cardTitleOf(context)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _streak(context, Icons.water_drop_rounded, DeckLook.mint, AppStrings.t(context, 'hydration'), hydraStreak),
                    _streak(context, Icons.auto_awesome, DeckLook.orange, AppStrings.t(context, 'movement'), moveStreak),
                    _streak(context, Icons.stop_rounded, DeckLook.purple, AppStrings.t(context, 'journaling'), journalStreak),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SoftCard(
                  onTap: () => _experiments(context, deck),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBubble(icon: Icons.science_rounded, color: DeckLook.mint, size: 36),
                      const SizedBox(height: 10),
                      Text(AppStrings.t(context, 'experiments'), style: DeckLook.cardTitleOf(context)),
                      const SizedBox(height: 4),
                      Text(experimentLine, style: DeckLook.subtitleOf(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoftCard(
                  onTap: () => _reflect(context, deck),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBubble(icon: Icons.auto_awesome, color: DeckLook.blue, size: 36),
                      const SizedBox(height: 10),
                      Text(AppStrings.t(context, 'weeklyReflection'), style: DeckLook.cardTitleOf(context)),
                      const SizedBox(height: 4),
                      Text(reflectLine, style: DeckLook.subtitleOf(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _body(WellnessProvider deck) {
    final raw = deck.observation();
    final cut = raw.split('Observation only').first.trim();
    return cut.isEmpty ? raw : cut;
  }

  Widget _metric(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String value,
    List<double> series, {
    bool bars = false,
  }) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: DeckLook.subtitleOf(context).copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: DeckLook.valueOf(context).copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          MiniChart(values: series, color: color, bars: bars),
        ],
      ),
    );
  }

  Widget _streak(BuildContext context, IconData icon, Color color, String label, int n) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.35), width: 3),
              color: color.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text('$n ${n == 1 ? 'day' : 'days'}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: DeckLook.inkOf(context))),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: DeckLook.mutedOf(context))),
        ],
      ),
    );
  }

  Future<void> _experiments(BuildContext context, WellnessProvider deck) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: deck,
        builder: (_, __) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(AppStrings.t(ctx, 'experiments'), style: DeckLook.cardTitleOf(context).copyWith(fontSize: 18))),
                    IconButton(
                      onPressed: () async {
                        final v = await DeckDialogs.title(ctx, heading: AppStrings.t(ctx, 'experiments'));
                        if (v != null) await deck.addExperiment(v);
                      },
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (deck.experiments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(AppStrings.t(ctx, 'experimentHint'), style: DeckLook.subtitleOf(context)),
                  ),
                for (final e in deck.experiments)
                  GestureDetector(
                    onLongPress: () => deck.deleteExperiment(e.id),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: e.on,
                      onChanged: (_) => deck.toggleExperiment(e.id),
                      title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reflect(BuildContext context, WellnessProvider deck) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListenableBuilder(
        listenable: deck,
        builder: (_, __) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t(ctx, 'weeklyReflection'), style: DeckLook.cardTitleOf(context).copyWith(fontSize: 18)),
                _q(ctx, deck, AppStrings.t(ctx, 'wentWell'), deck.weeklyWentWell, (v) => deck.setReflection(well: v)),
                _q(ctx, deck, AppStrings.t(ctx, 'whatHard'), deck.weeklyHard, (v) => deck.setReflection(hard: v)),
                _q(ctx, deck, AppStrings.t(ctx, 'whatNext'), deck.weeklyNext, (v) => deck.setReflection(next: v)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _q(BuildContext context, WellnessProvider deck, String q, String value, Future<void> Function(String) save) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      subtitle: Text(value.isEmpty ? AppStrings.t(context, 'tapToWrite') : value),
      onTap: () async {
        final v = await DeckDialogs.title(context, heading: q, initial: value);
        if (v != null) await save(v);
      },
    );
  }
}
