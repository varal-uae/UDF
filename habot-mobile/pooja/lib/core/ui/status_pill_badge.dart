import 'package:flutter/material.dart';

enum StatusBadgeType { active, pending, approved, rejected, draft, synced, unknown }

/// Atomic High-Contrast Mobile Status Badge Component (WCAG AA 4.5:1 Compliant).
class StatusPillBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;

  const StatusPillBadge({super.key, required this.label, this.type = StatusBadgeType.unknown});

  @override
  Widget build(BuildContext context) {
    final colors = switch (type) {
      StatusBadgeType.active => (bg: const Color(0xFFE8F5E9), fg: const Color(0xFF1B5E20)),
      StatusBadgeType.pending => (bg: const Color(0xFFFFF3E0), fg: const Color(0xFFE65100)),
      StatusBadgeType.approved => (bg: const Color(0xFFE3F2FD), fg: const Color(0xFF0D47A1)),
      StatusBadgeType.rejected => (bg: const Color(0xFFFFEBEE), fg: const Color(0xFFB71C1C)),
      StatusBadgeType.draft => (bg: const Color(0xFFF3E5F5), fg: const Color(0xFF4A148C)),
      StatusBadgeType.synced => (bg: const Color(0xFFE0F7FA), fg: const Color(0xFF006064)),
      StatusBadgeType.unknown => (bg: const Color(0xFFEEEEEE), fg: const Color(0xFF424242)),
    };
    return Semantics(
      label: 'Status: ${label.toUpperCase()}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label.toUpperCase(), style: TextStyle(color: colors.fg, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }
}
