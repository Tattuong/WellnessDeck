import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';
import '../providers/shop_provider.dart';

class GlassPane extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? glow;
  final VoidCallback? onTap;

  const GlassPane({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.glow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final skinId = context.select<ShopProvider, String>((s) => s.activeSkinId);
    final skin = CardStyle.get(skinId);
    final g = glow ?? context.ftrTheme.primary;
    final r = skin.paperRadius(20);
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: skin.lookDecoration(
        fill: AppColors.card(context).withValues(alpha: 0.78),
        accent: g,
        radius: r,
      ).copyWith(
        border: Border.all(color: g.withValues(alpha: skin.neonGlow ? 0.7 : 0.32), width: skin.neonGlow ? 1.4 : 1),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(r), child: box);
  }
}

class HabitRing extends StatelessWidget {
  final String label;
  final String caption;
  final double t;
  final Color color;

  const HabitRing({super.key, required this.label, required this.caption, required this.t, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _RingPainter(t.clamp(0, 1), color),
            child: Center(
              child: Text(caption, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: AppColors.muted(context), fontSize: 11, fontWeight: FontWeight.w700)),
      ],
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
    final r = size.width / 2 - 5;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.57,
      6.2832 * t,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.t != t || oldDelegate.color != color;
}

class MiniSpark extends StatelessWidget {
  final List<double> values;
  final Color color;
  const MiniSpark({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 36, width: double.infinity, child: CustomPaint(painter: _SparkPainter(values, color)));
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final span = (max - min).abs() < 1e-6 ? 1.0 : max - min;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] - min) / span * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => true;
}

class DonutChart extends StatelessWidget {
  final List<(Color, double)> slices;
  final String center;
  final String sub;
  const DonutChart({super.key, required this.slices, required this.center, this.sub = ''});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: CustomPaint(
        painter: _DonutPainter(slices),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              if (sub.isNotEmpty) Text(sub, style: TextStyle(color: AppColors.muted(context), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(Color, double)> slices;
  const _DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (a, b) => a + b.$2);
    if (total <= 0) return;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    var start = -1.57;
    for (final s in slices) {
      final sweep = 6.2832 * (s.$2 / total);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
        Paint()
          ..color = s.$1
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
