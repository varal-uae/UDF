// SSELC-025-A01 — Screen size class definitions.
// Maps raw device pixel width to a named MD3 window size class.
// Reference: HC-NOM-0007 | Google Material Design window size classes.

enum SizeClass {
  /// < 600dp — compact mobile, 4-column grid, full-screen navigation.
  compact,

  /// 600–1200dp — medium tablet, split panel available.
  medium,

  /// ≥ 1200dp — expanded widescreen, full 60/40 split enforced.
  expanded,
}

extension SizeClassX on SizeClass {
  bool get isCompact  => this == SizeClass.compact;
  bool get isMedium   => this == SizeClass.medium;
  bool get isExpanded => this == SizeClass.expanded;

  /// Column count per MD3 responsive grid spec.
  int get columns {
    switch (this) {
      case SizeClass.compact:  return 4;
      case SizeClass.medium:   return 8;
      case SizeClass.expanded: return 12;
    }
  }
}
