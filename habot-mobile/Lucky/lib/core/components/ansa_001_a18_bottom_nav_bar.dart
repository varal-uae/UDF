// ANSA-001-A18 — Persistent bottom interface navigation container with active state tracking and badge count updates.
// Provides a reusable Material 3 bottom navigation bar enforcing 48dp touch targets and non-blocking active tab feedback.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Controller for active tab state and badge counts.
class BottomNavController extends ChangeNotifier {
  BottomNavController({required int itemCount, int initialIndex = 0})
      : assert(itemCount > 0),
        _itemCount = itemCount,
        _activeIndex = initialIndex,
        _badgeCounts = List<int>.filled(itemCount, 0);

  final int _itemCount;
  int _activeIndex;
  List<int> _badgeCounts;

  int get itemCount => _itemCount;
  int get activeIndex => _activeIndex;
  List<int> get badgeCounts => List.unmodifiable(_badgeCounts);

  int badgeCountFor(int index) {
    assert(index >= 0 && index < _itemCount);
    return _badgeCounts[index];
  }

  void setActiveIndex(int index) {
    assert(index >= 0 && index < _itemCount);
    if (_activeIndex == index) return;
    _activeIndex = index;
    notifyListeners();
  }

  void setBadgeCount(int index, int count) {
    assert(index >= 0 && index < _itemCount);
    final next = count < 0 ? 0 : count;
    if (_badgeCounts[index] == next) return;
    _badgeCounts[index] = next;
    notifyListeners();
  }

  void incrementBadge(int index, [int amount = 1]) {
    setBadgeCount(index, _badgeCounts[index] + amount);
  }

  void clearBadge(int index) => setBadgeCount(index, 0);
}

/// A compact, persistent Material 3 bottom navigation container.
class Ansa001A18BottomNavBar extends StatelessWidget {
  const Ansa001A18BottomNavBar({
    super.key,
    required this.controller,
    required this.items,
    this.onDestinationSelected,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showBadge = true,
  });

  final BottomNavController controller;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int>? onDestinationSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBg = backgroundColor ?? colorScheme.surfaceContainer;
    final effectiveSelected = selectedColor ?? colorScheme.primary;
    final effectiveUnselected = unselectedColor ?? colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final currentIndex = controller.activeIndex;
        return Material(
          color: effectiveBg,
          elevation: 0,
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final selected = index == currentIndex;
                  final badgeCount = showBadge ? controller.badgeCountFor(index) : 0;
                  return _BottomNavDestination(
                    key: ValueKey('bottom-nav-$index'),
                    item: item,
                    selected: selected,
                    selectedColor: effectiveSelected,
                    unselectedColor: effectiveUnselected,
                    badgeCount: badgeCount,
                    onTap: () {
                      controller.setActiveIndex(index);
                      onDestinationSelected?.call(index);
                    },
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavDestination extends StatelessWidget {
  const _BottomNavDestination({
    super.key,
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.badgeCount,
    required this.onTap,
  });

  final BottomNavigationBarItem item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    final icon = selected ? (item.activeIcon ?? item.icon) : item.icon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 48,
        width: 64,
        child: Semantics(
          selected: selected,
          button: true,
          label: item.label,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? selectedColor.withAlpha(30) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(height: 2),
                    Text(
                      item.label ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 2,
                  right: 6,
                  child: _Badge(count: badgeCount, color: selectedColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
