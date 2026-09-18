// GEN-01092 — Dismissible child profile cards with tap-to-add gesture and M3 responsive layout.
// Implements dismissible card actions, 48x48dp touch targets, Material You dynamic color,
// single-column mobile (<600dp) and multi-column desktop (>=840dp) layouts, and mock data.

import 'package:flutter/material.dart';

/// Mock model representing a child profile for local development.
class ChildProfile {
  final String id;
  final String name;
  final int age;
  final bool isActive;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.isActive,
  });
}

/// Hardcoded mock dataset containing valid, boundary, and edge-case profiles.
final List<ChildProfile> _mockChildProfiles = [
  const ChildProfile(id: 'c1', name: 'Ahmed Al Maktoum', age: 7, isActive: true),
  const ChildProfile(id: 'c2', name: 'Fatima Hassan', age: 12, isActive: true),
  const ChildProfile(id: 'c3', name: 'Omar Khalid', age: 3, isActive: false),
  const ChildProfile(id: 'c4', name: 'Layla Noor', age: 15, isActive: true),
  const ChildProfile(id: 'edge_empty', name: '', age: 0, isActive: false),
];

/// Controller managing child profile state and dismissible actions.
class ChildProfileController extends ChangeNotifier {
  final List<ChildProfile> _profiles = List.from(_mockChildProfiles);

  List<ChildProfile> get profiles => List.unmodifiable(_profiles);

  void removeProfile(String id) {
    _profiles.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addProfile(ChildProfile profile) {
    _profiles.add(profile);
    notifyListeners();
  }

  void undoRemove(ChildProfile profile) {
    _profiles.add(profile);
    notifyListeners();
  }
}

/// Main widget rendering the responsive child profile management screen.
class ChildProfileManagementScreen extends StatefulWidget {
  const ChildProfileManagementScreen({super.key});

  @override
  State<ChildProfileManagementScreen> createState() => _ChildProfileManagementScreenState();
}

class _ChildProfileManagementScreenState extends State<ChildProfileManagementScreen> {
  late final ChildProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChildProfileController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profiles'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 840;
              final crossAxisCount = isDesktop ? 2 : 1;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: isDesktop ? 2.5 : 3.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == _controller.profiles.length) {
                            return _buildTapToAddCard(context);
                          }
                          final profile = _controller.profiles[index];
                          return _buildDismissibleProfileCard(context, profile);
                        },
                        childCount: _controller.profiles.length + 1,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// M3 Elevated Card Level 2 (3dp) with dismissible action.
  Widget _buildDismissibleProfileCard(BuildContext context, ChildProfile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(profile.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.onErrorContainer,
          size: 32.0,
        ),
      ),
      onDismissed: (_) {
        final removed = profile;
        _controller.removeProfile(profile.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${removed.name.isEmpty ? "Unknown" : removed.name} removed'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _controller.undoRemove(removed),
            ),
          ),
        );
      },
      child: Card(
        elevation: 3.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: InkWell(
          onTap: () => _showDetailsBottomSheet(context, profile),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.0,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                    style: TextStyle(color: colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.name.isEmpty ? 'Unnamed Profile' : profile.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Age: ${profile.age}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // M3 Status Chip
                Chip(
                  avatar: Icon(
                    profile.isActive ? Icons.check_circle : Icons.cancel,
                    size: 18.0,
                    color: profile.isActive
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                  label: Text(profile.isActive ? 'Active' : 'Inactive'),
                  backgroundColor: profile.isActive
                      ? colorScheme.secondaryContainer
                      : colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: profile.isActive
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tap-to-add gesture card with 48x48dp touch target.
  Widget _buildTapToAddCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
      ),
      child: InkWell(
        onTap: () => _showAddBottomSheet(context),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: IconButton(
                  iconSize: 32.0,
                  icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                  onPressed: () => _showAddBottomSheet(context),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Add Child Profile',
                style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs.
  void _showAddBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Child Profile', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 24.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                height: 48.0,
                child: FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final age = int.tryParse(ageController.text.trim()) ?? 0;
                    if (name.isNotEmpty && age > 0) {
                      _controller.addProfile(
                        ChildProfile(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          age: age,
                          isActive: true,
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile added successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  void _showDetailsBottomSheet(BuildContext context, ChildProfile profile) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile Details', style: Theme.of(ctx).textTheme.titleLarge),
              const Divider(height: 32.0),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Name'),
                subtitle: Text(profile.name.isEmpty ? 'N/A' : profile.name),
              ),
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: const Text('Age'),
                subtitle: Text('${profile.age} years'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Status'),
                subtitle: Text(profile.isActive ? 'Active' : 'Inactive'),
              ),
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('ID'),
                subtitle: Text(profile.id),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper widget to rebuild on ChangeNotifier updates without external packages.
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
    widget.notifier.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant AnimatedBuilderInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_onChanged);
      widget.notifier.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}
