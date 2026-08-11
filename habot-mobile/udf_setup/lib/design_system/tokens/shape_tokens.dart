/// AISS: RCGLA-001-A01 -- corner + border variables.
/// AISS: TTMCS-001-A01 -- "Component container borders match rigid brand theme
/// rules precisely."
///
/// Source of truth: `lib/design_system/tokens/tokens.json`.
library;

class HabotShape {
  const HabotShape._();

  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 28;

  /// Stadium / pill. Any radius >= half the height renders fully round.
  static const double full = 999;

  static const double borderWidth = 1;
  static const double focusBorderWidth = 2;

  static const List<double> allRadii = <double>[none, xs, sm, md, lg, xl];
}
