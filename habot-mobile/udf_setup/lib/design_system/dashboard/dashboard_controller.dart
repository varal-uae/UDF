/// AISS: GEN-04880-A01 -- "Implement the self-chasing automation behavior:
/// Clicking any KPI card automatically applies the corresponding filter."
/// Metric: Automation Trigger Reliability Rate -- Floor >=99.0% successful
/// automated triggers, Optimal 99.9%, Ceiling 100%.
///
/// The step that closes the loop, and the last of the batch: the dashboard
/// shows a number, the number is tappable, the tap narrows the dashboard.
/// It needs the cards (Steps 52, 54), the summary (Step 62) and the filters
/// (Steps 63-64) all to exist, which is why nothing else could go after it.
///
/// The metric is measurable here, unlike most of the batch, because the
/// trigger is a tap rather than a background job: drive N taps, count how many
/// produced the expected selection, report the rate. A trigger that fires
/// 99 times in 100 is a bug you can only find by counting, so the counter is
/// part of the controller rather than a test fixture.
///
/// "AUTOMATICALLY APPLIES THE CORRESPONDING FILTER" is the requirement, and
/// the load-bearing word is *corresponding*. A KPI that maps to no filter must
/// not be tappable at all -- a card that looks interactive and does nothing is
/// worse than one that looks inert. `HabotKpi.filterKey` being null is how
/// that is expressed, and `HabotKpiCard.isActionable` is where it is enforced.
library;

import 'package:flutter/foundation.dart';

import 'filter_model.dart';
import 'kpi_card.dart';

/// One recorded trigger, so the reliability rate is computed from evidence
/// rather than asserted.
@immutable
class HabotTriggerRecord {
  const HabotTriggerRecord({
    required this.kpiId,
    required this.expectedFacet,
    required this.expectedValue,
    required this.succeeded,
    this.reason,
  });

  final String kpiId;
  final String? expectedFacet;
  final String? expectedValue;
  final bool succeeded;

  /// Why it did not fire, when it did not. Null on success.
  final String? reason;
}

/// The dashboard's filter state, and the tap that drives it.
class HabotDashboardController extends ChangeNotifier {
  HabotDashboardController({
    required this.facetKey,
    HabotFilterSelection? initial,
  }) : _selection = initial ?? const HabotFilterSelection();

  /// The facet a KPI tap writes into. One facet, named up front: a KPI that
  /// could target any facet would make "the corresponding filter" a runtime
  /// guess.
  final String facetKey;

  HabotFilterSelection _selection;
  final List<HabotTriggerRecord> _triggers = <HabotTriggerRecord>[];

  HabotFilterSelection get selection => _selection;

  List<HabotTriggerRecord> get triggers =>
      List<HabotTriggerRecord>.unmodifiable(_triggers);

  int get triggerCount => _triggers.length;

  int get successfulTriggers =>
      _triggers.where((HabotTriggerRecord t) => t.succeeded).length;

  /// The metric: share of automated triggers that produced the intended
  /// selection, as a percentage. 100 when nothing has been triggered, because
  /// a rate over zero events is not a failure.
  double get reliabilityRate =>
      _triggers.isEmpty ? 100 : (successfulTriggers / _triggers.length) * 100;

  /// Floor: ">=99.0% successful automated triggers".
  static const double floorReliability = 99.0;
  static const double optimalReliability = 99.9;

  bool get meetsFloor => reliabilityRate >= floorReliability;

  /// The self-chasing behaviour. Returns true when the tap changed the
  /// selection.
  ///
  /// Every call is recorded, including the ones that legitimately do nothing,
  /// because a reliability rate computed only over the successes is 100% by
  /// construction and therefore worthless.
  bool applyFromKpi(HabotKpi kpi) {
    final String? key = kpi.filterKey;
    if (key == null) {
      _triggers.add(
        HabotTriggerRecord(
          kpiId: kpi.id,
          expectedFacet: facetKey,
          expectedValue: null,
          succeeded: false,
          reason: 'KPI declares no filterKey, so no card was tappable',
        ),
      );
      return false;
    }
    final HabotFilterSelection before = _selection;
    // Replace, not toggle: tapping "Faults" means "show me faults", not "add
    // faults to whatever was already selected". Tapping the same card again
    // clears it, so the gesture is its own undo.
    _selection = before.isSelected(facetKey, key)
        ? before.clearFacet(facetKey)
        : before.replaceFacet(facetKey, key);
    final bool changed = _selection != before;
    _triggers.add(
      HabotTriggerRecord(
        kpiId: kpi.id,
        expectedFacet: facetKey,
        expectedValue: key,
        succeeded: changed,
        reason: changed ? null : 'selection did not change',
      ),
    );
    if (changed) {
      notifyListeners();
    }
    return changed;
  }

  /// Applies a selection from the filter sheet. Not recorded as an automated
  /// trigger -- a person choosing a filter is not automation, and counting it
  /// would inflate the rate the metric is about.
  void applyFromSheet(HabotFilterSelection selection) {
    if (selection == _selection) {
      return;
    }
    _selection = selection;
    notifyListeners();
  }

  void clear() {
    if (_selection.isEmpty) {
      return;
    }
    _selection = const HabotFilterSelection();
    notifyListeners();
  }

  /// Whether [kpi] is the one the current selection came from. The card
  /// carrying the active filter reads as selected, so the loop is visible in
  /// both directions rather than only forwards.
  bool isActive(HabotKpi kpi) =>
      kpi.filterKey != null && _selection.isSelected(facetKey, kpi.filterKey!);

  void resetTriggerLog() {
    _triggers.clear();
  }
}
