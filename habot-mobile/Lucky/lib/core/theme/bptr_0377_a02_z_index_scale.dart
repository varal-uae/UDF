// BPTR-0377-A02 — Z-Index Layering Scale design tokens.
// Defines five global elevation levels (base, raised, overlay, alert, criticalAlert)
// so that overlapping UI components never hide critical alerts on small screens.

/// Rigid Z-index scale ensuring critical alerts render on top.
/// Values map to Material elevation shadows and overlay layer ordering.
abstract final class Bptr0377A02ZIndexScale {
  Bptr0377A02ZIndexScale._();

  static const double base = 0.0;
  static const double raised = 1.0;
  static const double overlay = 4.0;
  static const double alert = 8.0;
  static const double criticalAlert = 16.0;

  static const List<double> globalElevationLevels = [
    base,
    raised,
    overlay,
    alert,
    criticalAlert,
  ];

  static const Map<String, double> semanticElevation = {
    'base': base,
    'raised': raised,
    'overlay': overlay,
    'alert': alert,
    'criticalAlert': criticalAlert,
  };

  /// Layer ordering for explicit Stack/Overlay composition.
  /// Higher values must be inserted later in the widget tree.
  static const int baseLayer = 0;
  static const int contentLayer = 10;
  static const int overlayLayer = 20;
  static const int alertLayer = 30;
  static const int criticalAlertLayer = 40;
}
