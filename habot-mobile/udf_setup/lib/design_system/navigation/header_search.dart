/// AISS: ANSA-006-A01 -- "Build an expandable search text line inside primary
/// system headers."
///
/// 4 Substeps:
///   1. "Position a clean, clear text input field inside primary workspace
///       headers."
///   2. "Setup brief keypress delay timers to wait for typing pauses before
///       running queries."
///   3. "Render clear category match dropdown grids directly below the header
///       search bar."
///   4. "Save successful lookup keyword values locally to provide quick repeat
///       lookups."
///
/// Poka-Yoke: "Filter out invalid code punctuation marks from search inputs
/// automatically to prevent database query errors."
///
/// Completion Measure: "Entering valid search terms returns matching assets
/// inside dropdown lists under 350ms."
///
/// The last step of the batch, and the one that consumes the most: the header
/// from ANSA-012, the card chassis from GEN-01452, the empty state from
/// GEN-01297 for a zero-result query, and the progress indicator from
/// GEN-01848 while a query is in flight.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../feedback/empty_state.dart';
import '../feedback/progress_indicators.dart';
import '../surfaces/card_chassis.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// One row in the results dropdown.
class HabotSearchResult {
  const HabotSearchResult({
    required this.id,
    required this.label,
    required this.category,
  });

  final String id;
  final String label;

  /// Substep 3: "category match dropdown grids" -- results are grouped, not a
  /// flat list, so a user scanning for an asset type finds it by shape.
  final String category;
}

/// Runs a query. Returns the matches in relevance order.
typedef HabotSearchSource =
    Future<List<HabotSearchResult>> Function(String query);

/// Input hygiene (the poka-yoke) and the recent-keyword store (substep 4).
class HabotSearchSanitiser {
  const HabotSearchSanitiser._();

  /// Strips the punctuation that turns a search box into an injection vector
  /// or a malformed query, and collapses runs of whitespace.
  ///
  /// Deliberately a filter rather than a rejection: a user who pastes a value
  /// with a stray quote should get results, not a scolding.
  static String sanitise(String raw) {
    final StringBuffer out = StringBuffer();
    for (final int unit in raw.trim().codeUnits) {
      final String char = String.fromCharCode(unit);
      if (!HabotDiscovery.forbiddenSearchPunctuation.contains(char)) {
        out.write(char);
      }
    }
    return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// True when the sanitised query is worth running.
  static bool isRunnable(String sanitised) =>
      sanitised.length >= HabotDiscovery.minQueryLength;

  /// True when [raw] contained something the sanitiser had to remove.
  static bool wasFiltered(String raw) => sanitise(raw) != raw.trim();
}

/// Owns the debounce, the in-flight query, the results and the local history.
class HeaderSearchController extends ChangeNotifier {
  HeaderSearchController({required this.source});

  final HabotSearchSource source;

  Timer? _debounce;
  String _query = '';
  bool _running = false;
  List<HabotSearchResult> _results = <HabotSearchResult>[];
  final List<String> _recent = <String>[];
  Duration _lastLatency = Duration.zero;
  int _queryCount = 0;

  String get query => _query;
  bool get isRunning => _running;
  List<HabotSearchResult> get results => List<HabotSearchResult>.unmodifiable(_results);

  /// Substep 4: successful lookups, most recent first, capped and de-duplicated.
  List<String> get recent => List<String>.unmodifiable(_recent);

  /// Wall-clock time of the last query, excluding the debounce wait. Compared
  /// against [HabotMotion.searchLatencyBudget] by the completion-measure gate.
  Duration get lastLatency => _lastLatency;

  /// How many times the source was actually called. Proves the debounce
  /// collapsed a burst of keystrokes into one query rather than many.
  int get queryCount => _queryCount;

  /// Substep 3: results are grouped by category for the dropdown.
  Map<String, List<HabotSearchResult>> get grouped {
    final Map<String, List<HabotSearchResult>> out =
        <String, List<HabotSearchResult>>{};
    for (final HabotSearchResult result in _results) {
      out.putIfAbsent(result.category, () => <HabotSearchResult>[]).add(result);
    }
    return out;
  }

  /// Substep 2: a keystroke restarts the timer rather than starting a query.
  void onQueryChanged(String raw) {
    _query = HabotSearchSanitiser.sanitise(raw);
    _debounce?.cancel();
    if (!HabotSearchSanitiser.isRunnable(_query)) {
      _results = <HabotSearchResult>[];
      notifyListeners();
      return;
    }
    _debounce = Timer(HabotMotion.searchDebounce, run);
    notifyListeners();
  }

  /// Runs the query now, skipping the debounce. Called by the timer, and
  /// directly when the user submits or picks a recent keyword.
  Future<void> run() async {
    if (!HabotSearchSanitiser.isRunnable(_query)) {
      return;
    }
    final String issued = _query;
    _running = true;
    notifyListeners();
    final Stopwatch clock = Stopwatch()..start();
    try {
      _queryCount++;
      final List<HabotSearchResult> found = await source(issued);
      // A slower earlier query must not overwrite a newer one's results.
      if (issued != _query) {
        return;
      }
      _results = found;
      if (found.isNotEmpty) {
        _remember(issued);
      }
    } finally {
      clock.stop();
      _lastLatency = clock.elapsed;
      _running = false;
      notifyListeners();
    }
  }

  void selectRecent(String keyword) {
    _query = keyword;
    unawaited(run());
  }

  void clear() {
    _debounce?.cancel();
    _query = '';
    _results = <HabotSearchResult>[];
    notifyListeners();
  }

  void _remember(String keyword) {
    _recent
      ..remove(keyword)
      ..insert(0, keyword);
    if (_recent.length > HabotDiscovery.recentSearchLimit) {
      _recent.removeRange(HabotDiscovery.recentSearchLimit, _recent.length);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Substep 1: the search line that lives inside the header.
class HabotHeaderSearchField extends StatefulWidget {
  const HabotHeaderSearchField({
    required this.controller,
    this.hintText = 'Search',
    super.key,
  });

  final HeaderSearchController controller;
  final String hintText;

  @override
  State<HabotHeaderSearchField> createState() => _HabotHeaderSearchFieldState();
}

class _HabotHeaderSearchFieldState extends State<HabotHeaderSearchField> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _text,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        border: InputBorder.none,
      ),
      onChanged: widget.controller.onQueryChanged,
      onSubmitted: (String _) => widget.controller.run(),
    );
  }
}

/// Substep 3: the dropdown, rendered directly below the search line.
class HabotSearchResultsPanel extends StatelessWidget {
  const HabotSearchResultsPanel({
    required this.controller,
    required this.onSelected,
    super.key,
  });

  final HeaderSearchController controller;
  final void Function(HabotSearchResult result) onSelected;

  /// GEN-01848: an in-flight query is progress, not emptiness.
  static const Widget searching = Padding(
    padding: EdgeInsets.all(HabotSpacing.md),
    child: HabotProgressBar(value: null, label: 'Searching'),
  );

  @override
  Widget build(BuildContext context) {
    if (controller.isRunning) {
      return searching;
    }
    if (controller.query.isEmpty) {
      return const SizedBox.shrink();
    }
    // GEN-01297: a query that matched nothing gets the empty state, never a
    // blank panel the user has to interpret.
    if (controller.results.isEmpty) {
      return HabotEmptyState(
        reason: HabotEmptyReason.noSearchResults,
        onAction: controller.clear,
      );
    }
    return HabotCard(
      variant: HabotCardVariant.outlined,
      child: _ResultGroups(controller: controller, onSelected: onSelected),
    );
  }
}

class _ResultGroups extends StatelessWidget {
  const _ResultGroups({required this.controller, required this.onSelected});

  final HeaderSearchController controller;
  final void Function(HabotSearchResult result) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final MapEntry<String, List<HabotSearchResult>> group
            in controller.grouped.entries)
          ..._group(context, group),
      ],
    );
  }

  List<Widget> _group(
    BuildContext context,
    MapEntry<String, List<HabotSearchResult>> group,
  ) => <Widget>[
    Text(group.key, style: Theme.of(context).textTheme.labelMedium),
    for (final HabotSearchResult result
        in group.value.take(HabotDiscovery.maxVisibleResults))
      _ResultRow(result: result, onSelected: onSelected),
  ];
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.onSelected});

  final HabotSearchResult result;
  final void Function(HabotSearchResult result) onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(result),
      child: SizedBox(
        height: HabotDiscovery.searchResultRowHeight,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            result.label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
