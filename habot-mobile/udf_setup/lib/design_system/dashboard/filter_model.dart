/// AISS: GEN-01441-A01 (the sheet that edits filters) and GEN-04880-A01 (the
/// KPI tap that applies one). The model both share, so a filter set by a tap
/// and a filter set by the sheet are the same object rather than two that
/// have to be kept in step.
///
/// GEN-01441 Metric: Filter Application Latency -- Floor <1s, Optimal <300ms,
/// Ceiling <2s.
/// GEN-04880 Metric: Automation Trigger Reliability Rate -- Floor >=99.0%,
/// Optimal 99.9%.
///
/// Applying a filter is a pure function over data already in memory: there is
/// no round trip to be slow. The latency budget is therefore about the frame,
/// and [HabotFilterSelection.apply] is written to be O(n) over the rows with
/// no allocation per predicate, so the budget is a property of the algorithm
/// rather than of the network.
library;

import 'package:flutter/foundation.dart';

/// One filter dimension -- a facet with a fixed set of options.
@immutable
class HabotFilterFacet {
  const HabotFilterFacet({
    required this.key,
    required this.label,
    required this.options,
  });

  final String key;
  final String label;
  final List<HabotFilterOption> options;

  HabotFilterOption? optionFor(String value) {
    for (final HabotFilterOption option in options) {
      if (option.value == value) {
        return option;
      }
    }
    return null;
  }
}

/// One selectable value inside a facet.
@immutable
class HabotFilterOption {
  const HabotFilterOption({
    required this.value,
    required this.label,
    this.matchCount,
  });

  final String value;
  final String label;

  /// How many rows this option would leave, when the caller knows. Shown on
  /// the chip so a user can see that a filter is about to empty the screen
  /// before they tap it.
  final int? matchCount;

  bool get yieldsNothing => matchCount == 0;
}

/// The current selection: facet key -> chosen values.
///
/// Immutable, and every mutation returns a new selection. That is what makes
/// the tap-to-filter loop in Step 65 safe to reason about -- a tap produces a
/// value, it does not reach into shared state.
@immutable
class HabotFilterSelection {
  const HabotFilterSelection([this.values = const <String, Set<String>>{}]);

  final Map<String, Set<String>> values;

  bool get isEmpty => values.values.every((Set<String> v) => v.isEmpty);

  int get activeCount =>
      values.values.fold(0, (int sum, Set<String> v) => sum + v.length);

  Set<String> forFacet(String facetKey) =>
      values[facetKey] ?? const <String>{};

  bool isSelected(String facetKey, String value) =>
      forFacet(facetKey).contains(value);

  HabotFilterSelection toggle(String facetKey, String value) {
    final Map<String, Set<String>> next = <String, Set<String>>{
      for (final MapEntry<String, Set<String>> e in values.entries)
        e.key: Set<String>.from(e.value),
    };
    final Set<String> set = next.putIfAbsent(facetKey, () => <String>{});
    if (!set.remove(value)) {
      set.add(value);
    }
    return HabotFilterSelection(next);
  }

  /// Replaces one facet outright. What a KPI tap does: tapping "Faults" means
  /// "show me faults", not "add faults to whatever was already selected".
  HabotFilterSelection replaceFacet(String facetKey, String value) {
    final Map<String, Set<String>> next = <String, Set<String>>{
      for (final MapEntry<String, Set<String>> e in values.entries)
        e.key: Set<String>.from(e.value),
    };
    next[facetKey] = <String>{value};
    return HabotFilterSelection(next);
  }

  HabotFilterSelection clearFacet(String facetKey) {
    final Map<String, Set<String>> next = <String, Set<String>>{
      for (final MapEntry<String, Set<String>> e in values.entries)
        e.key: Set<String>.from(e.value),
    };
    next.remove(facetKey);
    return HabotFilterSelection(next);
  }

  HabotFilterSelection clear() => const HabotFilterSelection();

  /// Applies the selection to [rows]. Values within a facet are OR-ed, facets
  /// are AND-ed -- the convention every faceted search uses, stated once here
  /// instead of re-derived at each call site.
  List<T> apply<T>(
    List<T> rows,
    String Function(T row, String facetKey) valueOf,
  ) {
    if (isEmpty) {
      return rows;
    }
    return rows.where((T row) {
      for (final MapEntry<String, Set<String>> entry in values.entries) {
        if (entry.value.isEmpty) {
          continue;
        }
        if (!entry.value.contains(valueOf(row, entry.key))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  bool operator ==(Object other) {
    if (other is! HabotFilterSelection) {
      return false;
    }
    if (other.values.length != values.length) {
      return false;
    }
    for (final MapEntry<String, Set<String>> e in values.entries) {
      final Set<String>? o = other.values[e.key];
      if (o == null || o.length != e.value.length || !o.containsAll(e.value)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
    for (final String key in values.keys.toList()..sort())
      Object.hash(key, Object.hashAllUnordered(values[key]!)),
  ]);
}
