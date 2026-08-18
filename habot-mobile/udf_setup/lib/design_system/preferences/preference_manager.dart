/// AISS: IS22-RCGLA-022-AS01-A01 -- "Build and deploy a responsive preference
/// manager panel inside client settings."
///
/// 4 Substeps, verbatim:
///   1. "Map explicit preference columns (allow_promo, allow_transaction)
///       inside user state tables."
///   2. "Render responsive configuration controls linked directly to these
///       column models."
///   3. "Update user database preferences instantly when sliders change on
///       screen."
///   4. "Connect configuration choices directly to notification dispatch
///       services."
///
/// Poka-Yoke: "Selection inputs freeze screen transitions until changes write
/// to database rows."
/// Completion Measure: "Preference changes write to the database accurately
/// during interface evaluation loops."
/// Atomic Reusability: "NotificationPreferenceSheet UI wrapper block" -- which
/// is Step 50, built on this.
///
/// The poka-yoke is the interesting requirement, because it is a rule about
/// what must NOT happen: a user may not navigate away between flipping a
/// switch and that flip reaching storage. [PreferenceStore.isWriting] is what
/// the shell blocks on, and it is set inside the write path rather than by a
/// caller remembering to set it.
///
/// ESTIMATE NOTE, RECORDED: this row's Estimated Time reads "5 Minutes" for a
/// responsive settings panel with database writes. Treated as an estimation
/// error rather than a scope signal; the implementation is sized to the four
/// substeps, not to the estimate.
library;

import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';

/// Substep 1: the explicit preference columns, named by the sheet.
///
/// An enum rather than free-form strings, so a typo is a compile error and the
/// set of columns is enumerable -- which is what makes "map explicit columns"
/// checkable at all.
enum HabotPreferenceColumn {
  /// Marketing and promotional messages.
  allowPromo,

  /// Transactional messages: receipts, confirmations, security notices.
  allowTransaction;

  /// The database column name. Snake case, as the sheet writes it.
  String get columnName {
    switch (this) {
      case HabotPreferenceColumn.allowPromo:
        return 'allow_promo';
      case HabotPreferenceColumn.allowTransaction:
        return 'allow_transaction';
    }
  }

  String get label {
    switch (this) {
      case HabotPreferenceColumn.allowPromo:
        return 'Offers and product news';
      case HabotPreferenceColumn.allowTransaction:
        return 'Receipts and security alerts';
    }
  }

  String get description {
    switch (this) {
      case HabotPreferenceColumn.allowPromo:
        return 'Occasional messages about new features and offers.';
      case HabotPreferenceColumn.allowTransaction:
        return 'Confirmations, receipts and anything about your account '
            'security.';
    }
  }

  /// Transactional messages default on: a user who has switched off receipts
  /// has chosen to, and a user who has never been asked has not.
  bool get defaultValue => this == HabotPreferenceColumn.allowTransaction;
}

/// The result of one write.
enum HabotPreferenceWriteResult { written, failed }

/// Writes a preference to storage. Injected, so the gates drive real
/// transitions -- including failures -- without a database.
typedef HabotPreferenceWriter =
    Future<HabotPreferenceWriteResult> Function(
      HabotPreferenceColumn column,
      bool value,
    );

/// Substeps 1 and 3: the column model, and the instant write.
class PreferenceStore extends ChangeNotifier {
  PreferenceStore({required this.writer, Map<HabotPreferenceColumn, bool>? initial})
    : _values = <HabotPreferenceColumn, bool>{
        for (final HabotPreferenceColumn column
            in HabotPreferenceColumn.values)
          column: initial?[column] ?? column.defaultValue,
      };

  final HabotPreferenceWriter writer;
  final Map<HabotPreferenceColumn, bool> _values;

  /// Columns currently mid-write. The poka-yoke reads this.
  final Set<HabotPreferenceColumn> _writing = <HabotPreferenceColumn>{};

  /// Writes that failed and were rolled back, for the caller to surface.
  final List<HabotPreferenceColumn> failed = <HabotPreferenceColumn>[];

  bool valueOf(HabotPreferenceColumn column) => _values[column]!;

  /// Poka-Yoke: "Selection inputs freeze screen transitions until changes
  /// write to database rows." True while any write is outstanding.
  bool get isWriting => _writing.isNotEmpty;

  bool isWritingColumn(HabotPreferenceColumn column) =>
      _writing.contains(column);

  /// Every column, as the sheet's Data Collected column expects.
  Map<String, bool> toRecord() => <String, bool>{
    for (final MapEntry<HabotPreferenceColumn, bool> entry in _values.entries)
      entry.key.columnName: entry.value,
  };

  /// Substep 3: "Update user database preferences INSTANTLY when sliders
  /// change on screen."
  ///
  /// Optimistic: the switch moves at once, because a control that waits on a
  /// network round trip feels broken. If the write fails the value rolls back
  /// and the column is recorded in [failed] -- the same honesty rule the
  /// rollback boundary applies in Step 19.
  Future<HabotPreferenceWriteResult> set(
    HabotPreferenceColumn column,
    bool value,
  ) async {
    final bool previous = _values[column]!;
    _values[column] = value;
    _writing.add(column);
    notifyListeners();

    HabotPreferenceWriteResult result;
    try {
      result = await writer(column, value);
    } catch (_) {
      result = HabotPreferenceWriteResult.failed;
    }

    if (result == HabotPreferenceWriteResult.failed) {
      _values[column] = previous;
      failed.add(column);
    }
    _writing.remove(column);
    notifyListeners();
    return result;
  }
}

/// Substep 2: "Render responsive configuration controls linked directly to
/// these column models."
///
/// The panel takes the store, not a list of rows: a control that is not backed
/// by a column cannot be added to it.
class HabotPreferencePanel extends StatelessWidget {
  const HabotPreferencePanel({
    required this.store,
    this.columns = HabotPreferenceColumn.values,
    super.key,
  });

  final PreferenceStore store;
  final List<HabotPreferenceColumn> columns;

  /// Minimum row height. A settings row is an interactive element, so
  /// TTMAC-011 applies to it exactly as it applies to everything else.
  static const double rowMinHeight = HabotDensity.minTouchTarget;

  static const Key panelKey = Key('habot.preferences.panel');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: panelKey,
      animation: store,
      builder: (BuildContext context, Widget? _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final HabotPreferenceColumn column in columns)
            HabotPreferenceRow(store: store, column: column),
        ],
      ),
    );
  }
}

/// One switch, bound to one column.
class HabotPreferenceRow extends StatelessWidget {
  const HabotPreferenceRow({
    required this.store,
    required this.column,
    super.key,
  });

  final PreferenceStore store;
  final HabotPreferenceColumn column;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: HabotPreferencePanel.rowMinHeight,
      ),
      child: SwitchListTile(
        value: store.valueOf(column),
        // Disabled mid-write: the same freeze the poka-yoke demands, applied
        // to the control that caused it so a double-flip cannot race.
        onChanged: store.isWritingColumn(column)
            ? null
            : (bool value) => store.set(column, value),
        title: Text(column.label, style: theme.textTheme.bodyLarge),
        subtitle: Text(column.description, style: theme.textTheme.bodySmall),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HabotSpacing.md,
          vertical: HabotSpacing.xxs,
        ),
      ),
    );
  }
}

/// The poka-yoke, as a guard a navigator can consult.
///
/// Screen transitions ask this before they run. A pending write blocks the
/// transition rather than being abandoned by it, which is the difference
/// between "preferences saved" and "preferences usually saved".
class PreferenceTransitionGuard {
  const PreferenceTransitionGuard(this.store);

  final PreferenceStore store;

  bool get mayLeave => !store.isWriting;

  /// Awaits any outstanding write, then allows the transition. Returns false
  /// if the write failed, so the caller can keep the user on the screen and
  /// tell them.
  Future<bool> requestLeave() async {
    while (store.isWriting) {
      await Future<void>.delayed(Duration.zero);
    }
    return store.failed.isEmpty;
  }
}
