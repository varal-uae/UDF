import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// RRCVG-018-05 — Feature Toggle Service.
// Spec: "Fetch all flag states dynamically during the startup sequence."
//       "App gracefully hides elements toggled off mid-session."
//       "Cache flags locally."
//
// Architecture:
//   - Fetches flags from remote at app startup (stub — wire endpoint when ready)
//   - Caches to shared_preferences for offline/fast reads
//   - FeatureFlagProvider (InheritedNotifier) — any widget reads flags via context
//   - FeatureGate widget — hides/shows children based on flag state

// ── Flag definitions ──────────────────────────────────────────────────────────

/// All feature flag keys. Add new flags here only — one source of truth.
enum FeatureFlag {
  dashboardV2,
  exportPdf,
  analyticsTracking,
  darkModeToggle,
  advancedSearch,
  betaForms,
  aiPromptBuilder,
  peerReview,
  bulkExport,
  adminPanel,
}

extension FeatureFlagX on FeatureFlag {
  String get key => name; // uses enum name as string key
}

// ── Flag service ──────────────────────────────────────────────────────────────

class FeatureFlagService extends ChangeNotifier {
  FeatureFlagService._();
  static final FeatureFlagService instance = FeatureFlagService._();

  final Map<String, bool> _flags = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Read a flag — defaults to false if not set (safe default = off).
  bool isEnabled(FeatureFlag flag) => _flags[flag.key] ?? false;

  /// Convenience operator: service[FeatureFlag.dashboardV2]
  bool operator [](FeatureFlag flag) => isEnabled(flag);

  // ── Startup fetch ───────────────────────────────────────────────────────────

  /// Call once at app startup — before MaterialApp renders.
  /// Loads cached flags first (instant), then fetches remote (background).
  Future<void> init() async {
    await _loadFromCache();
    _isLoaded = true;
    notifyListeners();
    // Background remote fetch — does not block startup
    _fetchRemote();
  }

  // ── Cache ───────────────────────────────────────────────────────────────────

  static const _cachePrefix = 'feature_flag_';

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final flag in FeatureFlag.values) {
      final cached = prefs.getBool('$_cachePrefix${flag.key}');
      if (cached != null) _flags[flag.key] = cached;
    }
  }

  Future<void> _saveToCache(Map<String, bool> flags) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in flags.entries) {
      await prefs.setBool('$_cachePrefix${entry.key}', entry.value);
    }
  }

  // ── Remote fetch ────────────────────────────────────────────────────────────

  /// ⏳ Stub — replace with real endpoint when Release Engineering provides URL.
  /// Expected response: { "flags": { "dashboardV2": true, "exportPdf": false, ... } }
  Future<void> _fetchRemote() async {
    try {
      // TODO: replace with HabotHttpClient.instance.get('/config/feature-flags')
      // final response = await HabotHttpClient.instance.get('/config/feature-flags');
      // final remoteFlags = Map<String, bool>.from(response.data['flags']);
      // _applyFlags(remoteFlags);

      // Dev defaults — used until remote endpoint is wired
      final devDefaults = {
        for (final f in FeatureFlag.values) f.key: true,
      };
      _applyFlags(devDefaults);
    } catch (e) {
      debugPrint('[FeatureFlags] Remote fetch failed — using cached: $e');
    }
  }

  void _applyFlags(Map<String, bool> incoming) {
    bool changed = false;
    for (final entry in incoming.entries) {
      if (_flags[entry.key] != entry.value) {
        _flags[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _saveToCache(_flags);
    }
  }

  /// Override a flag locally — for testing/QA only.
  void override(FeatureFlag flag, {required bool enabled}) {
    _flags[flag.key] = enabled;
    notifyListeners();
  }

  /// Reset all overrides — restores cached/remote values.
  Future<void> reset() async {
    _flags.clear();
    await _loadFromCache();
    notifyListeners();
  }
}

// ── InheritedNotifier provider ────────────────────────────────────────────────

class FeatureFlagProvider extends InheritedNotifier<FeatureFlagService> {
  const FeatureFlagProvider({
    super.key,
    required super.child,
  }) : super(notifier: const _ServiceRef._());

  // Use singleton directly
  static FeatureFlagService of(BuildContext context) =>
      FeatureFlagService.instance;
}

// Dummy ref — we use singleton, InheritedNotifier just triggers rebuilds
class _ServiceRef extends FeatureFlagService {
  const _ServiceRef._() : super._();
}

// ── FeatureGate widget ────────────────────────────────────────────────────────

/// Shows child only when the feature flag is enabled.
/// Gracefully hides/shows mid-session when flags change.
///
/// Usage:
/// ```dart
/// FeatureGate(
///   flag: FeatureFlag.exportPdf,
///   child: ExportButton(),
/// )
///
/// // With fallback
/// FeatureGate(
///   flag: FeatureFlag.dashboardV2,
///   child: DashboardV2(),
///   fallback: DashboardV1(),
/// )
/// ```
class FeatureGate extends StatelessWidget {
  const FeatureGate({
    super.key,
    required this.flag,
    required this.child,
    this.fallback,
  });

  final FeatureFlag flag;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FeatureFlagService.instance,
      builder: (context, _) {
        final enabled = FeatureFlagService.instance.isEnabled(flag);
        if (enabled) return child;
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
