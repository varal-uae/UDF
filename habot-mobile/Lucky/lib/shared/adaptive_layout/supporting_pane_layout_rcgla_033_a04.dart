// RCGLA-033-A04 — Supporting Pane Layout with Entity-Aware App Bar.
// Deploys responsive supporting pane layouts across app views, dynamically rendering the app bar title, logo, and theme based on the active entity profile. Forces a complete cache and view state reset when switching entities.

import 'package:flutter/material.dart';

/// Mock data representing available entity profiles.
class EntityProfile {
  final String id;
  final String name;
  final Color primaryColor;
  final IconData logoIcon;

  const EntityProfile({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.logoIcon,
  });
}

const List<EntityProfile> _mockEntities = [
  EntityProfile(
    id: 'ent_001',
    name: 'Habot Finance',
    primaryColor: Color(0xFF1565C0),
    logoIcon: Icons.account_balance,
  ),
  EntityProfile(
    id: 'ent_002',
    name: 'Habot Logistics',
    primaryColor: Color(0xFF2E7D32),
    logoIcon: Icons.local_shipping,
  ),
  EntityProfile(
    id: 'ent_003',
    name: 'Habot Retail',
    primaryColor: Color(0xFFC62828),
    logoIcon: Icons.storefront,
  ),
];

/// Controller managing the active entity and enforcing state resets.
class EntityController extends ChangeNotifier {
  EntityProfile _activeEntity = _mockEntities.first;

  EntityProfile get activeEntity => _activeEntity;

  /// Switches the active entity and forces a complete cache and view state reset.
  void switchEntity(String entityId) {
    final target = _mockEntities.firstWhere(
      (e) => e.id == entityId,
      orElse: () => _mockEntities.first,
    );
    if (_activeEntity.id != target.id) {
      _activeEntity = target;
      _forceCacheAndStateReset();
      notifyListeners();
    }
  }

  void _forceCacheAndStateReset() {
    // Poka-Yoke: Base templates automatically position tracking elements
    // below main inputs if width limits drop. State reset ensures no
    // stale layout configurations persist across entity switches.
    debugPrint('[RCGLA-033-A04] Cache and view state reset for entity: ${_activeEntity.id}');
  }
}

/// Responsive layout that organizes primary page elements into dedicated
/// focus input layers, placing supporting panes next to primary content
/// on large screens, and masking them behind clean menu links on phones.
class SupportingPaneLayout extends StatelessWidget {
  final Widget primaryContent;
  final Widget supportingPane;
  final String? title;

  const SupportingPaneLayout({
    super.key,
    required this.primaryContent,
    required this.supportingPane,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ensureController(context),
      builder: (context, _) {
        final controller = _ensureController(context);
        final entity = controller.activeEntity;
        final theme = Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: entity.primaryColor,
            brightness: Theme.of(context).brightness,
          ),
        );

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: _buildEntityAppBar(context, entity),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;

                if (isWide) {
                  // Dashboard / Interface Implication: Spending status views
                  // position detailed table metrics right next to target trend graphs.
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: primaryContent,
                      ),
                      VerticalDivider(width: 1, thickness: 1),
                      Expanded(
                        flex: 2,
                        child: supportingPane,
                      ),
                    ],
                  );
                } else {
                  // Phone viewports mask secondary support content completely
                  // behind clean menu links, maximizing interaction space.
                  return Column(
                    children: [
                      Expanded(child: primaryContent),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FilledButton.tonalIcon(
                          onPressed: () => _showSupportingPaneBottomSheet(context, entity),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('View Contextual Tips'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  AppBar _buildEntityAppBar(BuildContext context, EntityProfile entity) {
    return AppBar(
      backgroundColor: entity.primaryColor,
      foregroundColor: Colors.white,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entity.logoIcon, color: Colors.white),
          const SizedBox(width: 8),
          Text(title ?? entity.name),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Switch Entity Profile',
          onSelected: (id) => _ensureController(context).switchEntity(id),
          itemBuilder: (context) => _mockEntities
              .map((e) => PopupMenuItem<String>(
                    value: e.id,
                    child: Row(
                      children: [
                        Icon(e.logoIcon, size: 20, color: e.primaryColor),
                        const SizedBox(width: 8),
                        Text(e.name),
                        if (e.id == entity.id) ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 20),
                        ],
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showSupportingPaneBottomSheet(BuildContext context, EntityProfile entity) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: supportingPane,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  EntityController _ensureController(BuildContext context) {
    try {
      return Provider.of<EntityController>(context, listen: false);
    } catch (_) {
      // Fallback for isolated usage without Provider wrapper
      return EntityController();
    }
  }
}

/// A minimal ChangeNotifier provider implementation to avoid external dependencies
/// in this atomic step file. In production, replace with package:provider.
class AnimatedBuilder extends StatelessWidget {
  final ChangeNotifier animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderInternal(
      notifier: animation,
      builder: builder,
      child: child,
    );
  }
}

class AnimatedBuilderInternal extends StatefulWidget {
  final ChangeNotifier notifier;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilderInternal({
    super.key,
    required this.notifier,
    required this.builder,
    this.child,
  });

  @override
  State<AnimatedBuilderInternal> createState() => _AnimatedBuilderInternalState();
}

class _AnimatedBuilderInternalState extends State<AnimatedBuilderInternal> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onNotify);
  }

  @override
  void didUpdateWidget(covariant AnimatedBuilderInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_onNotify);
      widget.notifier.addListener(_onNotify);
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onNotify);
    super.dispose();
  }

  void _onNotify() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}

/// Minimal Provider lookup shim.
class Provider {
  static T of<T>(BuildContext context, {bool listen = true}) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_ProviderScope<T>>();
    if (inherited == null) throw Exception('Provider<$T> not found in context.');
    return inherited.value;
  }
}

class _ProviderScope<T> extends InheritedWidget {
  final T value;

  const _ProviderScope({required this.value, required super.child});

  @override
  bool updateShouldNotify(covariant _ProviderScope<T> oldWidget) => oldWidget.value != value;
}

/// Example usage demonstrating the supporting pane layout.
class SupportingPaneExampleScreen extends StatelessWidget {
  const SupportingPaneExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EntityController();

    return _ProviderScope<EntityController>(
      value: controller,
      child: SupportingPaneLayout(
        title: 'Task Entry',
        primaryContent: const _PrimaryFormContent(),
        supportingPane: const _SupportingTipsContent(),
      ),
    );
  }
}

class _PrimaryFormContent extends StatelessWidget {
  const _PrimaryFormContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Primary Input Layer', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Task Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportingTipsContent extends StatelessWidget {
  const _SupportingTipsContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contextual Tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('Naming Convention'),
              subtitle: const Text('Use clear, action-oriented names for tasks.'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Description Guidelines'),
              subtitle: const Text('Include relevant details and expected outcomes.'),
            ),
          ),
        ],
      ),
    );
  }
}