import 'package:flutter/material.dart';

/// WellnessDeck — cream field, sage, navy.
class AppColors {
  static const Color primary = Color(0xFF5E9A6E);
  static const Color primaryLight = Color(0xFF8FBF9A);
  static const Color primarySoft = Color(0xFFEAF6EE);
  static const Color primaryMuted = Color(0xFF3F6F4C);

  static const Color accent = Color(0xFFD07090);
  static const Color accentLight = Color(0xFFF3B07A);
  static const Color accentDeep = Color(0xFF5B6FA8);
  static const Color success = Color(0xFF5E9A6E);
  static const Color successDeep = Color(0xFF3F6F4C);
  static const Color warning = Color(0xFFE8B84A);
  static const Color error = Color(0xFFD94A4A);
  static const Color coin = Color(0xFFC49A3C);
  static const Color onGold = Color(0xFF1B2740);

  static const Color paint = Color(0xFF4C8DDB);
  static const Color tiles = Color(0xFFD07090);
  static const Color concrete = Color(0xFF5E9A6E);
  static const Color flooring = Color(0xFFE8B84A);
  static const Color wallpaper = Color(0xFF7B6BB0);

  static const List<Color> subjects = [
    Color(0xFF4C8DDB),
    Color(0xFF5E9A6E),
    Color(0xFF7B6BB0),
    Color(0xFFD07090),
    Color(0xFF5B6FA8),
    Color(0xFF2AA4B8),
  ];

  static const Color background = Color(0xFFF5F3F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAF8F4);
  static const Color surfaceVariant = Color(0xFFEEEAE3);
  static const Color border = Color(0xFFE4DFD6);
  static const Color borderBright = Color(0xFF5E9A6E);

  static const Color textPrimary = Color(0xFF1B2740);
  static const Color textSecondary = Color(0xFF6B7288);
  static const Color textMuted = Color(0xFF8A8378);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1B2740);
  static const Color onSurfaceVariant = Color(0xFF6B7288);

  static const Color navBar = Color(0xFF1B2740);
  static const Color navActive = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF8A8378);

  static const Color darkBackground = Color(0xFF141624);
  static const Color darkSurface = Color(0xFF23283F);
  static const Color darkCard = Color(0xFF2A3050);
  static const Color trueBlack = Color(0xFF0A0C10);
  static const Color darkInk = Color(0xFFF5F2FA);

  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightPrimaryTint = Color(0xFFEAF6EE);
  static const Color lightWarmTint = Color(0xFFF4F1EC);
  static const Color lightTextPrimary = Color(0xFF1B2740);

  static const Color salon = Color(0xFF12141A);
  static const Color salonCard = Color(0xFF1C1E26);
  static const Color salonLine = Color(0xFF3A3E4A);

  static const List<Color> papers = [
    Color(0xFFFFFFFF),
    Color(0xFFF4F1EC),
    Color(0xFFE8F3FB),
    Color(0xFFEAF6EE),
    Color(0xFFF3EEFA),
    Color(0xFFFBEAF0),
    Color(0xFFF7F0E8),
  ];

  static const List<Color> extraPapers = [
    Color(0xFFEDE6DA),
    Color(0xFFE8EEF8),
    Color(0xFFF3E8D8),
  ];

  static Color paperAt(int index, {bool extras = false}) {
    final all = extras ? [...papers, ...extraPapers] : papers;
    if (all.isEmpty) return surface;
    return all[index % all.length];
  }

  static Color brand(BuildContext context) => Theme.of(context).colorScheme.primary;

  static Color page(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  static Color brandSoft(BuildContext context) =>
      Color.lerp(page(context), brand(context), 0.16) ?? primarySoft;

  static Color sheet(BuildContext context) => Theme.of(context).colorScheme.surface;

  static Color ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : textSecondary;

  static Color card(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (Theme.of(context).brightness == Brightness.light) {
      return Colors.white;
    }
    return scheme.surface;
  }

  static Color line(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A3E4A) : border;

  static Color navBarColor(BuildContext context) => navBar;

  static Color paper(BuildContext context, int index) {
    if (Theme.of(context).brightness == Brightness.dark) return paperAt(index);
    return papers[index % papers.length];
  }

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F1EC), Color(0xFFEDE8DF)],
  );

  static const LinearGradient gameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F1EC), Color(0xFFE8E4DC)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8FBF9A), Color(0xFF5E9A6E), Color(0xFF3F6F4C)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C8DDB), Color(0xFF1B2740)],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    colors: [Color(0xFFE8B84A), Color(0xFFC49A3C)],
  );

  static const LinearGradient shopPromoGradient = LinearGradient(
    colors: [Color(0xFF1B2740), Color(0xFF2A3A58)],
  );

  static const LinearGradient vipGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8B84A), Color(0xFFE67A2E), Color(0xFFC45C18)],
  );

  static const LinearGradient shopVipHeroGradient = LinearGradient(
    colors: [Color(0xFF1C1E26), Color(0xFF12141A)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF8FBF9A), Color(0xFF5E9A6E)],
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF4F1EC)],
  );

  static List<BoxShadow> softShadow({double opacity = 0.08}) => [
        BoxShadow(
          color: const Color(0xFF1B2740).withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
