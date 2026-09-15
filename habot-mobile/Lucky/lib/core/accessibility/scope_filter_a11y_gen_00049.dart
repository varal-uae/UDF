// GEN-00049 — Scope Filter Accessibility Verification Console.
// Single-column M3 layout verifying atomic components are Figma-specified and mobile-accessible; labeled + keyboard-navigable scope filters.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Completion gate for GEN-00049: Requirements Definition Completeness.
/// Floor: All required inputs identified (no gaps). Target: 100% coverage.
enum Gen00049CompletionStatus { complete, partial, notComplete }

extension Gen00049CompletionStatusX on Gen00049CompletionStatus {
  String get label {
    switch (this) {
      case Gen00049CompletionStatus.complete:
        return 'Complete';
      case Gen00049CompletionStatus.partial:
        return 'Partial';
      case Gen00049CompletionStatus.notComplete:
        return 'Not Complete';
    }
  }
}

/// Model for a core atomic component under verification.
class Gen00049AtomicComponent {
  const Gen00049AtomicComponent({
    required this.id,
    required this.name,
    required this.figmaSpecified,
    required this.a11yTested,
    required this.status,
  });
  final String id;
  final String name;
  final bool figmaSpecified;
  final bool a11yTested;
  final Gen00049CompletionStatus status;
}

/// GEN-00049 screen: verifies scope filter controls are labeled and keyboard navigable.
class Gen00049ScopeFilterScreen extends StatefulWidget {
  const Gen00049ScopeFilterScreen({super.key});
  @override
  State<Gen00049ScopeFilterScreen> createState() => _Gen00049ScopeFilterScreenState();
}

class _Gen00049ScopeFilterScreenState extends State<Gen00049ScopeFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode(debugLabel: 'gen00049_search');
  final FocusNode _scopeFocus = FocusNode(debugLabel: 'gen00049_scope');
  final FocusNode _listFocus = FocusNode(debugLabel: 'gen00049_list');
  Timer? _pollTimer;
  DateTime _lastSync = DateTime.now();
  String _scope = 'All';
  Gen00049CompletionStatus? _statusFilter;
  final List<String> _scopes = ['All', 'Buttons', 'Cards', 'Inputs', 'Navigation'];

  List<Gen00049AtomicComponent> _items = const [
    Gen00049AtomicComponent(id: 'BTN-01', name: 'M3 Primary Button', figmaSpecified: true, a11yTested: true, status: Gen00049CompletionStatus.complete),
    Gen00049AtomicComponent(id: 'CARD-02', name: 'M3 Elevated Card L2', figmaSpecified: true, a11yTested: true, status: Gen00049CompletionStatus.complete),
    Gen00049AtomicComponent(id: 'INP-03', name: 'Scope Filter Input', figmaSpecified: true, a11yTested: false, status: Gen00049CompletionStatus.partial),
    Gen00049AtomicComponent(id: 'NAV-04', name: 'Header Navigation', figmaSpecified: false, a11yTested: false, status: Gen00049CompletionStatus.notComplete),
  ];

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _backgroundRefresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _scopeFocus.dispose();
    _listFocus.dispose();
    super.dispose();
  }

  Future<void> _backgroundRefresh() async {
    if (!mounted) return;
    setState(() => _lastSync = DateTime.now());
  }

  Future<void> _manualRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _backgroundRefresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scope verification data synced')),
    );
  }

  List<Gen00049AtomicComponent> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _items.where((e) {
      final scopeOk = _scope == 'All' || e.name.toLowerCase().contains(_scope.toLowerCase()) || e.id.startsWith(_scope.substring(0, 3).toUpperCase());
      final statusOk = _statusFilter == null || e.status == _statusFilter;
      final queryOk = q.isEmpty || e.name.toLowerCase().contains(q) || e.id.toLowerCase().contains(q);
      return scopeOk && statusOk && queryOk;
    }).toList();
  }

  void _openConfigSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Semantics(
        label: 'Configuration inputs for scope verification',
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gate configuration', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Standard: Internal Process Gate — Agile Definition of Done (Scrum Guide 2020).'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration saved')));
                  },
                  child: const Text('Confirm gate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _chipColor(Gen00049CompletionStatus s, ColorScheme cs) {
    switch (s) {
      case Gen00049CompletionStatus.complete:
        return cs.primaryContainer;
      case Gen00049CompletionStatus.partial:
        return cs.tertiaryContainer;
      case Gen00049CompletionStatus.notComplete:
        return cs.errorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Atomic A11y Verification')),
        floatingActionButton: Semantics(
          button: true,
          label: 'Open configuration inputs',
          child: SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(onPressed: _openConfigSheet, child: const Icon(Icons.tune)),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final filtered = _filtered;
            return RefreshIndicator(
              onRefresh: _manualRefresh,
              semanticsLabel: 'Pull to refresh verification data',
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Semantics(
                        header: true,
                        label: 'Scope filter controls. All controls are labeled and keyboard navigable.',
                        child: Text('Scope filters', style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: isDesktop ? _buildDesktopFilters() : _buildMobileFilters(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Semantics(
                        liveRegion: true,
                        label: '${filtered.length} components match current filters. Last sync ${_lastSync.hour}:${_lastSync.minute.toString().padLeft(2, '0')}',
                        child: Text('${filtered.length} results • synced ${_lastSync.hour}:${_lastSync.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: isDesktop
                        ? SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 190, crossAxisSpacing: 12, mainAxisSpacing: 12),
                            delegate: SliverChildBuilderDelegate((c, i) => _buildCard(filtered[i], cs), childCount: filtered.length),
                          )
                        : SliverList.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (c, i) => _buildCard(filtered[i], cs),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        Semantics(
          textField: true,
          label: 'Search atomic components by name or ID',
          hint: 'Example: Button, CARD-02',
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Search components', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Filter by scope. Currently ${_scope}',
          hint: 'Use arrow keys to change scope, Enter to confirm',
          child: DropdownButtonFormField<String>(
            value: _scope,
            focusNode: _scopeFocus,
            decoration: const InputDecoration(labelText: 'Scope', border: OutlineInputBorder()),
            items: [for (final s in _scopes) DropdownMenuItem(value: s, child: SizedBox(height: 48, child: Align(alignment: Alignment.centerLeft, child: Text(s))))],
            onChanged: (v) => setState(() => _scope = v ?? 'All'),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'Filter by completion status',
          child: Wrap(
            spacing: 8,
            children: [
              for (final s in Gen00049CompletionStatus.values)
                SizedBox(
                  height: 48,
                  child: FilterChip(
                    label: Text(s.label),
                    selected: _statusFilter == s,
                    tooltip: 'Show only ${s.label} components',
                    onSelected: (sel) => setState(() => _statusFilter = sel ? s : null),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(child: _buildMobileFilters()),
      ],
    );
  }

  Widget _buildCard(Gen00049AtomicComponent item, ColorScheme cs) {
    return Semantics(
      button: false,
      label: '${item.name}, ${item.id}, status ${item.status.label}, Figma ${item.figmaSpecified ? 'specified' : 'missing'}, accessibility ${item.a11yTested ? 'tested' : 'not tested'}',
      child: Card(
        elevation: 3,
        surfaceTintColor: cs.surfaceTint,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FocusableActionDetector(
            focusNode: FocusNode(debugLabel: 'gen00049_card_${item.id}'),
            shortcuts: {LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent()},
            actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) { _openConfigSheet(); return null; })},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleMedium)),
                    Semantics(label: 'Completion status ${item.status.label}', child: Chip(label: Text(item.status.label), backgroundColor: _chipColor(item.status, cs), visualDensity: VisualDensity.compact)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('ID: ${item.id} • Figma: ${item.figmaSpecified ? 'Yes' : 'No'} • A11y: ${item.a11yTested ? 'Yes' : 'No'}',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      TextButton(onPressed: _openConfigSheet, child: const Text('Details')),
                      const SizedBox(width: 8),
                      ExcludeSemantics(child: Icon(item.a11yTested ? Icons.accessibility_new : Icons.accessibility, color: cs.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
