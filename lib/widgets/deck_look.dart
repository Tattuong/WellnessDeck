import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeckLook {
  DeckLook._();

  static const navy = Color(0xFF1A1C3D);
  static const page = Color(0xFFF5F3F8);
  static const muted = Color(0xFF8A8798);
  static const ink = Color(0xFF1A1C3D);
  static const card = Colors.white;
  static const pageDark = Color(0xFF141624);
  static const cardDark = Color(0xFF23283F);
  static const inkDark = Color(0xFFF5F2FA);
  static const mutedDark = Color(0xFFA9A5B8);
  static const hairlineDark = Color(0xFF353A52);
  static const teal = Color(0xFF3DB8B0);
  static const green = Color(0xFF6FBF73);
  static const blue = Color(0xFF5B8DEF);
  static const purple = Color(0xFF8B7CF6);
  static const pink = Color(0xFFE58AA6);
  static const orange = Color(0xFFF0A05A);
  static const mint = Color(0xFF4ECDC4);

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color pageOf(BuildContext context) => isDark(context) ? pageDark : page;
  static Color cardOf(BuildContext context) => isDark(context) ? cardDark : card;
  static Color inkOf(BuildContext context) => isDark(context) ? inkDark : ink;
  static Color mutedOf(BuildContext context) => isDark(context) ? mutedDark : muted;
  static Color hairlineOf(BuildContext context) => isDark(context) ? hairlineDark : const Color(0xFFE8E4F0);

  static TextStyle serifTitle([double size = 22]) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: ink,
        height: 1.05,
      );

  static TextStyle serifTitleOf(BuildContext context, [double size = 22]) =>
      serifTitle(size).copyWith(color: inkOf(context));

  static TextStyle subtitle() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: muted,
      );

  static TextStyle subtitleOf(BuildContext context) => subtitle().copyWith(color: mutedOf(context));

  static TextStyle label() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: muted,
      );

  static TextStyle value() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: ink,
      );

  static TextStyle valueOf(BuildContext context) => value().copyWith(color: inkOf(context));

  static TextStyle cardTitle() => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: ink,
      );

  static TextStyle cardTitleOf(BuildContext context) => cardTitle().copyWith(color: inkOf(context));

  static List<BoxShadow> get shadow => [
        BoxShadow(color: navy.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 6)),
      ];

  static List<BoxShadow> shadowOf(BuildContext context) => isDark(context)
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.38), blurRadius: 18, offset: const Offset(0, 8))]
      : shadow;
}

class DeckHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const DeckHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 0, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DeckLook.serifTitleOf(context)),
                const SizedBox(height: 4),
                Text(subtitle, style: DeckLook.subtitleOf(context)),
              ],
            ),
          ),
          NavyCircleButton(icon: actionIcon, onTap: onAction, size: 28),
        ],
      ),
    );
  }
}

class NavyCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const NavyCircleButton({super.key, required this.icon, this.onTap, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final dark = DeckLook.isDark(context);
    return Material(
      color: dark ? const Color(0xFFEEEAF6) : DeckLook.navy,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: dark ? DeckLook.navy : Colors.white, size: size * 0.42),
        ),
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBubble({super.key, required this.icon, required this.color, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(10, 7, 10, 7),
    this.color,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? DeckLook.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: DeckLook.isDark(context) ? Border.all(color: DeckLook.hairlineOf(context)) : null,
        boxShadow: DeckLook.shadowOf(context),
      ),
      child: child,
    );
    if (onTap == null && onLongPress == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: box,
      ),
    );
  }
}

class StatusMeterCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String? trailing;
  final String? caption;
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final bool prominentValue;

  const StatusMeterCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    this.trailing,
    this.caption,
    required this.progress,
    this.onTap,
    this.onLongPress,
    this.prominentValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          IconBubble(icon: icon, color: color, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DeckLook.cardTitleOf(context)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: prominentValue
                            ? DeckLook.valueOf(context)
                            : GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: DeckLook.mutedOf(context)),
                      ),
                    ),
                    if (trailing != null)
                      Text(trailing!, style: GoogleFonts.inter(fontSize: 10, color: DeckLook.mutedOf(context))),
                  ],
                ),
                if (caption != null)
                  Text(caption!, style: GoogleFonts.inter(fontSize: 10, color: DeckLook.mutedOf(context))),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 3,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SquareCheck extends StatelessWidget {
  final bool on;
  final Color color;

  const SquareCheck({super.key, required this.on, this.color = DeckLook.purple});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: on ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: on ? color : (DeckLook.isDark(context) ? DeckLook.hairlineDark : const Color(0xFFD8D5E2)), width: 1.6),
      ),
      child: on ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
    );
  }
}

class CircleCheck extends StatelessWidget {
  final bool on;
  final Color onColor;
  final Color offColor;

  const CircleCheck({
    super.key,
    required this.on,
    this.onColor = DeckLook.green,
    this.offColor = const Color(0xFFD8D5E2),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: on ? onColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: on ? onColor : (DeckLook.isDark(context) ? DeckLook.hairlineDark : offColor),
          width: 1.7,
        ),
      ),
      child: on ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
    );
  }
}

class BreakRing extends StatelessWidget {
  final double progress;
  final String clock;
  final String hint;
  final Color color;

  const BreakRing({
    super.key,
    required this.progress,
    required this.clock,
    required this.hint,
    this.color = DeckLook.mint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: CustomPaint(
        painter: _RingPainter(progress.clamp(0, 1), color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(clock, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: DeckLook.inkOf(context))),
              Text(hint, style: GoogleFonts.inter(fontSize: 11, color: DeckLook.mutedOf(context))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  final Color color;
  const _RingPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * (t == 0 ? 0.001 : t),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.t != t || oldDelegate.color != color;
}

class RangePills extends StatelessWidget {
  final List<(String, String)> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool Function(String id)? enabled;

  const RangePills({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final dark = DeckLook.isDark(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1E30) : const Color(0xFFE9E7F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(item.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected == item.$1 ? (dark ? const Color(0xFFEEEAF6) : DeckLook.navy) : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected == item.$1
                          ? (dark ? DeckLook.navy : Colors.white)
                          : (enabled == null || enabled!(item.$1) ? DeckLook.inkOf(context) : DeckLook.mutedOf(context)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MiniChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final bool bars;

  const MiniChart({super.key, required this.values, required this.color, this.bars = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: double.infinity,
      child: CustomPaint(painter: bars ? _BarPainter(values, color) : _LinePainter(values, color)),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _LinePainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final data = values.isEmpty ? const [0.0, 0.0] : values;
    if (data.length == 1) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 3, Paint()..color = color);
      return;
    }
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 1e-6 ? 1.0 : max - min;
    final path = Path();
    Offset? last;
    for (var i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - ((data[i] - min) / span) * (size.height - 6) - 3;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      last = Offset(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - ((data[i] - min) / span) * (size.height - 6) - 3;
      canvas.drawCircle(Offset(x, y), 2.4, Paint()..color = color);
    }
    if (last != null) {}
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}

class _BarPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _BarPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final data = values.isEmpty ? List<double>.filled(7, 0) : values;
    final max = data.fold<double>(0, (a, b) => a > b ? a : b);
    final peak = max <= 0 ? 1.0 : max;
    const gap = 3.0;
    final w = (size.width - gap * (data.length - 1)) / data.length;
    for (var i = 0; i < data.length; i++) {
      final h = (data[i] / peak) * size.height;
      final x = i * (w + gap);
      final rect = RRect.fromLTRBR(x, size.height - h, x + w, size.height, const Radius.circular(3));
      canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.85));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) => true;
}

class WaveBackdrop extends StatelessWidget {
  const WaveBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _WavePainter(), size: Size.infinite);
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.55);
    for (var x = 0.0; x <= size.width; x += 1) {
      final y = size.height * 0.55 + math.sin(x / 18) * 10 + math.sin(x / 9) * 4;
      path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5EEAD4).withValues(alpha: 0.85)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0xFF67E8F9).withValues(alpha: 0.35)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
