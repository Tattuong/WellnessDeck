import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_theme_preset.dart';
import '../providers/shop_provider.dart';
import 'deck_look.dart';

class CircuitBackdrop extends StatelessWidget {
  final Widget child;
  const CircuitBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    AppThemePreset preset;
    try {
      preset = context.select<ShopProvider, AppThemePreset>((s) => s.activeTheme);
    } catch (_) {
      preset = AppThemePresets.defaultPreset;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? DeckLook.pageDark : preset.background;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: fill),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF1C2040),
                      Color(0xFF141624),
                      Color(0xFF101218),
                    ]
                  : const [
                      Color(0xFFEDE9F6),
                      Color(0xFFF5F3F8),
                      Color(0xFFF8F7FB),
                    ],
              stops: const [0, 0.42, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
