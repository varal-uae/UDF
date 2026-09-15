// GEN-00060 — MD3 Card Radius Standard + Guarded Disabled Button.
// Enforces 12dp (M) / 16dp (L) card radii, responsive M3 status cards and disabled control that blocks pointer + keyboard activation.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MD3 card radius tokens for GEN-00060.
/// Medium (M) = 12dp, Large (L) = 16dp per M3 spec.
abstract class Gen00060CardRadii {
  static const double medium = 12.0;
  static const double large = 16.0;
  static const BorderRadius mediumBorder = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeBorder = BorderRadius.all(Radius.circular(large));

  static BorderRadius resolveForWidth(double width) {
    if (width >= 840) return largeBorder;
    return mediumBorder;
  }

  static ShapeBorder cardShape(double width) {
    return RoundedRectangleBorder(borderRadius: resolveForWidth(width));
  }
}

/// Completion states captured as Complete / Partial / Not Complete.
enum Gen00060Completion { complete, partial, notComplete }

extension Gen00060CompletionX on Gen00060Completion {
  String get label {
    switch (this) {
      case Gen00060Completion.complete:
        return 'Complete';
      case Gen00060Completion.partial:
        return 'Partial';
      case Gen00060Completion.notComplete:
        return 'Not Complete';
    }
  }
}

/// M3 Status Chip with 48x48 minimum touch target.
class Gen00060StatusChip extends StatelessWidget {
  final Gen00060Completion status;
  const Gen00060StatusChip({super.key, required this.status});

  Color _bg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case Gen00060Completion.complete:
        return cs.primaryContainer;
      case Gen00060Completion.partial:
        return cs.tertiaryContainer;
      case Gen00060Completion.notComplete:
        return cs.errorContainer;
    }
  }

  Color _fg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case Gen00060Completion.complete:
        return cs.onPrimaryContainer;
      case Gen00060Completion.partial:
        return cs.onTertiaryContainer;
      case Gen00060Completion.notComplete:
        return cs.onErrorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: ShapeDecoration(shape: StadiumBorder(), color: _bg(context)),
          child: Text(status.label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: _fg(context))),
        ),
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) with MD3-standard radius.
class Gen00060StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gen00060Completion status;
  final VoidCallback? onDrillDown;
  const Gen00060StatusCard({super.key, required this.title, required this.subtitle, required this.status, this.onDrillDown});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final shape = Gen00060CardRadii.cardShape(c.maxWidth);
        return Card(
          elevation: 3,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onDrillDown,
            borderRadius: Gen00060CardRadii.resolveForWidth(c.maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Gen00060StatusChip(status: status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Disabled-safe button: blocks pointer events and keyboard activation when disabled.
/// When [enabled] is false, wraps in IgnorePointer + ExcludeFocus and forces onPressed null.
class Gen00060GuardedButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final Widget label;
  const Gen00060GuardedButton({super.key, required this.enabled, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: Gen00060CardRadii.mediumBorder));
    if (!enabled) {
      return ExcludeFocus(
        excluding: true,
        child: IgnorePointer(
          ignoring: true,
          child: Semantics(
            enabled: false,
            button: true,
            child: ElevatedButton(
              onPressed: null,
              style: style,
              focusNode: FocusNode(canRequestFocus: false, skipTraversal: true),
              child: label,
            ),
          ),
        ),
      );
    }
    return FocusableActionDetector(
      enabled: true,
      shortcuts: const <ShortcutActivator, Intent>{},
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: ElevatedButton(onPressed: onPressed, style: style, child: label),
      ),
    );
  }
}

/// Engineering console dashboard: single-column <600dp, multi-column >=840dp.
/// Includes 30s polling + pull-to-refresh + M3 BottomSheet / Snackbar.
class Gen00060EngineeringConsole extends StatefulWidget {
  const Gen00060EngineeringConsole({super.key});
  @override
  State<Gen00060EngineeringConsole> createState() => _Gen00060EngineeringConsoleState();
}

class _Gen00060EngineeringConsoleState extends State<Gen00060EngineeringConsole> {
  Timer? _poll;
  DateTime _lastSync = DateTime.now();
  final List<Gen00060Completion> _items = [Gen00060Completion.complete, Gen00060Completion.partial, Gen00060Completion.notComplete];

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _refresh(auto: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool auto = false}) async {
    setState(() => _lastSync = DateTime.now());
    debugPrint('GEN-00060 event_date=${DateTime.now().toIso8601String()} trace_id=gen-00060 auto=$auto radii=12dp/16dp');
    if (!auto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Synced MD3 card standards')));
    }
  }

  void _openConfigSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card radius config', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('M = 12dp, L = 16dp. Locked to MD3 standard.'),
              const SizedBox(height: 16),
              Gen00060GuardedButton(enabled: true, onPressed: () => Navigator.pop(c), label: const Text('Done')),
              const SizedBox(height: 8),
              const Gen00060GuardedButton(enabled: false, onPressed: null, label: Text('Disabled action')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engineering Console')),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(onPressed: _openConfigSheet, child: const Icon(Icons.tune)),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 840;
          final cards = List.generate(_items.length, (i) {
            return Gen00060StatusCard(title: 'GEN-00060 Step ${i + 1}', subtitle: 'Last sync: $_lastSync | Radius: ${isWide ? '16dp' : '12dp'}', status: _items[i], onDrillDown: () {});
          });
          return RefreshIndicator(
            onRefresh: () => _refresh(auto: false),
            child: isWide
                ? GridView.count(crossAxisCount: 2, padding: const EdgeInsets.all(16), mainAxisSpacing: 12, crossAxisSpacing: 12, children: cards)
                : ListView.separated(padding: const EdgeInsets.all(16), itemCount: cards.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, i) => cards[i]),
          );
        },
      ),
    );
  }
}
