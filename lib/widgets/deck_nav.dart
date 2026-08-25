import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DeckNavTab { today, build, patterns, menu }

class DeckNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final String todayLabel;
  final String buildLabel;
  final String patternsLabel;
  final String menuLabel;

  const DeckNavBar({
    super.key,
    required this.index,
    required this.onSelect,
    required this.todayLabel,
    required this.buildLabel,
    required this.patternsLabel,
    required this.menuLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: ColoredBox(
        color: const Color(0xFF1E253C),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                _item(DeckNavTab.today, todayLabel, 0),
                _item(DeckNavTab.build, buildLabel, 1),
                _item(DeckNavTab.patterns, patternsLabel, 2),
                _item(DeckNavTab.menu, menuLabel, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(DeckNavTab tab, String label, int i) {
    final selected = index == i;
    final color = selected ? Colors.white : const Color(0xFF9AA3B8);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(painter: _NavIconPainter(tab: tab, color: color)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIconPainter extends CustomPainter {
  final DeckNavTab tab;
  final Color color;
  const _NavIconPainter({required this.tab, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (tab) {
      case DeckNavTab.today:
        _sun(canvas, size, paint);
      case DeckNavTab.build:
        _sparkles(canvas, size, paint);
      case DeckNavTab.patterns:
        _bars(canvas, size, paint);
      case DeckNavTab.menu:
        _menu(canvas, size, paint);
    }
  }

  void _sun(Canvas canvas, Size size, Paint paint) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * 0.20, paint);
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final inner = size.width * 0.30;
      final outer = size.width * 0.46;
      canvas.drawLine(
        c + Offset(math.cos(a) * inner, math.sin(a) * inner),
        c + Offset(math.cos(a) * outer, math.sin(a) * outer),
        paint,
      );
    }
  }

  void _sparkles(Canvas canvas, Size size, Paint paint) {
    _star(canvas, Offset(size.width * 0.36, size.height * 0.52), size.width * 0.34, paint);
    _star(canvas, Offset(size.width * 0.72, size.height * 0.38), size.width * 0.20, paint);
    _star(canvas, Offset(size.width * 0.74, size.height * 0.72), size.width * 0.14, paint);
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final rad = i.isEven ? r : r * 0.32;
      final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _bars(Canvas canvas, Size size, Paint paint) {
    final fill = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    final w = size.width * 0.16;
    final gap = size.width * 0.12;
    final left = (size.width - (w * 3 + gap * 2)) / 2;
    final base = size.height * 0.86;
    final heights = [0.42, 0.64, 0.90];
    for (var i = 0; i < 3; i++) {
      final x = left + i * (w + gap);
      final h = size.height * heights[i];
      canvas.drawRRect(
        RRect.fromLTRBR(x, base - h, x + w, base, Radius.circular(w / 2)),
        fill,
      );
    }
  }

  void _menu(Canvas canvas, Size size, Paint paint) {
    final x0 = size.width * 0.16;
    final x1 = size.width * 0.84;
    for (final t in [0.28, 0.50, 0.72]) {
      final y = size.height * t;
      canvas.drawLine(Offset(x0, y), Offset(x1, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NavIconPainter oldDelegate) =>
      oldDelegate.tab != tab || oldDelegate.color != color;
}
