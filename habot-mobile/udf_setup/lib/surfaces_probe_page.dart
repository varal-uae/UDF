/// Probe screen for the Steps 21-35 surface, feedback, discovery and telemetry
/// layers, in the same spirit as the two probes before it: `flutter run`
/// demonstrates every primitive the batch produced, and the widget gates have
/// a real tree to pump. Scaffolding, not product UI.
library;

import 'package:flutter/material.dart';

import 'design_system/feedback/empty_state.dart';
import 'design_system/feedback/error_snackbar.dart';
import 'design_system/feedback/progress_indicators.dart';
import 'design_system/feedback/status_badge.dart';
import 'design_system/layout/master_scaffold.dart';
import 'design_system/layout/virtualized_list.dart';
import 'design_system/motion/shared_axis.dart';
import 'design_system/navigation/contextual_header.dart';
import 'design_system/navigation/header_search.dart';
import 'design_system/surfaces/card_chassis.dart';
import 'design_system/surfaces/metadata_disclosure.dart';
import 'design_system/telemetry/friction_tracker.dart';
import 'design_system/tokens/spacing_tokens.dart';
import 'design_system/tokens/surface_tokens.dart';

/// Exercises the surfaces built in Steps 21-35.
class SurfacesProbePage extends StatefulWidget {
  const SurfacesProbePage({this.embedded = false, super.key});

  /// True when the app shell is hosting this as a destination; the shell owns
  /// the master scaffold, so this builds its content only.
  final bool embedded;

  /// Screen name registered with the RCGLA-018 layout audit.
  static const String screenName = 'SurfacesProbePage';

  @override
  State<SurfacesProbePage> createState() => _SurfacesProbePageState();
}

class _SurfacesProbePageState extends State<SurfacesProbePage> {
  late final HabotChunkController<int> _chunks;
  late final HeaderSearchController _search;
  bool _detailOpen = false;

  static const HabotMetadata _metadata = HabotMetadata(
    title: 'Settlement value',
    description:
        'The amount that will move when this batch is released, after fees '
        'and before any manual adjustment.',
    formula: 'gross - fees - held',
    source: 'Ledger, refreshed hourly',
  );

  @override
  void initState() {
    super.initState();
    _chunks = HabotChunkController<int>(fetch: _fetchChunk);
    _search = HeaderSearchController(source: _searchSource);
  }

  @override
  void dispose() {
    _chunks.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<HabotChunk<int>> _fetchChunk(int offset, int limit) async {
    const int total = 10000;
    final int end = (offset + limit).clamp(0, total);
    return HabotChunk<int>(
      items: <int>[for (int i = offset; i < end; i++) i],
      hasMore: end < total,
    );
  }

  Future<List<HabotSearchResult>> _searchSource(String query) async {
    return <HabotSearchResult>[
      HabotSearchResult(
        id: '1',
        label: '$query batch 001',
        category: 'Batches',
      ),
      HabotSearchResult(id: '2', label: '$query ledger', category: 'Ledgers'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return FrictionTracker(
        screenName: SurfacesProbePage.screenName,
        child: _body(context),
      );
    }
    return FrictionTracker(
      screenName: SurfacesProbePage.screenName,
      child: HabotMasterScaffold(
        screenName: SurfacesProbePage.screenName,
        // The virtualised list scrolls itself; a scroll view around it would
        // give the list unbounded height and defeat the whole point.
        scrollable: false,
        header: const HabotContextualHeader(title: 'Surfaces & feedback'),
        body: _body(context),
      ),
    );
  }

  /// The content, without a scaffold, so the shell can host it.
  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HabotHeaderSearchField(controller: _search),
        const SizedBox(height: HabotSpacing.xs),
        _ProbeControls(
          metadata: _metadata,
          onSheet: _openSheet,
          onSnackbar: _showSnackbar,
          onToggleDetail: () => setState(() => _detailOpen = !_detailOpen),
        ),
        const SizedBox(height: HabotSpacing.xs),
        HabotSharedAxisSwitcher(
          stateKey: _detailOpen ? 'detail' : 'summary',
          axis: HabotSharedAxis.scaled,
          child: _detailOpen ? const _DetailPanel() : const _SummaryPanel(),
        ),
        const SizedBox(height: HabotSpacing.xs),
        Expanded(
          child: HabotVirtualList<int>(
            controller: _chunks,
            itemBuilder: (BuildContext context, int item, int index) =>
                SizedBox(
                  height: HabotDiscovery.searchResultRowHeight,
                  child: HabotMilestoneNode(
                    title: 'Task ${item + 1}',
                    status: HabotStatus.values[item % 5],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  void _openSheet() {
    HabotMetadataDisclosure.show(context, _metadata);
  }

  void _showSnackbar() {
    HabotErrorSnackbar.showError(
      context,
      const SocketLikeFailure('SocketException: Failed host lookup'),
      onRetry: _chunks.loadMore,
    );
  }
}

class _ProbeControls extends StatelessWidget {
  const _ProbeControls({
    required this.metadata,
    required this.onSheet,
    required this.onSnackbar,
    required this.onToggleDetail,
  });

  final HabotMetadata metadata;
  final VoidCallback onSheet;
  final VoidCallback onSnackbar;
  final VoidCallback onToggleDetail;

  @override
  Widget build(BuildContext context) {
    return HabotCard(
      variant: HabotCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HabotMetadataLabel(label: metadata.title, metadata: metadata),
          const SizedBox(height: HabotSpacing.xs),
          const HabotStepProgress(currentStep: 2, totalSteps: 5),
          const SizedBox(height: HabotSpacing.xs),
          Row(
            children: <Widget>[
              FilledButton(onPressed: onSheet, child: const Text('Open sheet')),
              const SizedBox(width: HabotSpacing.xs),
              OutlinedButton(
                onPressed: onSnackbar,
                child: const Text('Fail once'),
              ),
              const SizedBox(width: HabotSpacing.xs),
              TextButton(
                onPressed: onToggleDetail,
                child: const Text('Toggle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel();

  @override
  Widget build(BuildContext context) =>
      const HabotCard(child: HabotStatusBadge(status: HabotStatus.active));
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel();

  @override
  Widget build(BuildContext context) => const HabotCard(
    variant: HabotCardVariant.elevated,
    child: SizedBox(
      height: HabotFeedback.emptyStateMaxContentWidth,
      child: HabotEmptyState(reason: HabotEmptyReason.nothingYet),
    ),
  );
}

/// Stand-in failure so the probe can demonstrate the error snackbar without a
/// real socket. Mirrors the one the REF-197 gate uses.
class SocketLikeFailure implements Exception {
  const SocketLikeFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The surfaces probe as a shell destination: the same content, hosted by the
/// app shell's scaffold instead of its own.
class SurfacesProbeBody extends StatelessWidget {
  const SurfacesProbeBody({super.key});

  @override
  Widget build(BuildContext context) => const SurfacesProbePage(embedded: true);
}
