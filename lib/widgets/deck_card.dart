import 'package:flutter/material.dart';

class DeckCard extends StatelessWidget {
  final Widget child;
  final Color? tint;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets padding;

  const DeckCard({
    super.key,
    required this.child,
    this.tint,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1B2740).withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
    if (onTap == null && onLongPress == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, onLongPress: onLongPress, borderRadius: BorderRadius.circular(22), child: box),
    );
  }
}

class MeterBar extends StatelessWidget {
  final double t;
  final Color color;

  const MeterBar({super.key, required this.t, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: t.clamp(0, 1),
        minHeight: 8,
        color: color,
        backgroundColor: color.withValues(alpha: 0.15),
      ),
    );
  }
}
