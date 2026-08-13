import 'package:shared_preferences/shared_preferences.dart';

// VPVMP-021-02 — Form Auto-Save Service.
// Persists form field values to shared_preferences (local device cache).
// Activated by DebouncedFormField on every auto-save interval (800ms).
//
// Mistake-Proofing (Poka-Yoke):
//   Discards unfinished text if input length mismatches structure tracking rules.
//
// Self-Chasing:
//   Connection lag anomalies invoke this caching routine automatically,
//   securing user data persistence across navigation and app restarts.

class FormAutoSaveService {
  FormAutoSaveService._();
  static final FormAutoSaveService instance = FormAutoSaveService._();

  static const String _prefix = 'habot_form_autosave_';

  /// Saves [value] for [fieldKey] to local cache.
  /// Discards if [value] length is outside [minLength]..[maxLength] bounds.
  /// Pass null for min/maxLength to skip validation.
  Future<void> save({
    required String formId,
    required String fieldKey,
    required String value,
    int? minLength,
    int? maxLength,
  }) async {
    // Mistake-Proofing: discard if length mismatches structure tracking rules.
    if (minLength != null && value.length < minLength) return;
    if (maxLength != null && value.length > maxLength) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(formId, fieldKey), value);
  }

  /// Restores saved value for [fieldKey]. Returns null if nothing saved.
  Future<String?> restore({
    required String formId,
    required String fieldKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(formId, fieldKey));
  }

  /// Restores all saved fields for a [formId].
  Future<Map<String, String>> restoreAll({required String formId}) async {
    final prefs  = await SharedPreferences.getInstance();
    final keys   = prefs.getKeys().where((k) => k.startsWith('$_prefix${formId}_'));
    final result = <String, String>{};
    for (final k in keys) {
      final fieldKey = k.replaceFirst('$_prefix${formId}_', '');
      result[fieldKey] = prefs.getString(k) ?? '';
    }
    return result;
  }

  /// Clears all saved fields for a [formId] — call on successful form submit.
  Future<void> clear({required String formId}) async {
    final prefs = await SharedPreferences.getInstance();
    final keys  = prefs.getKeys().where((k) => k.startsWith('$_prefix${formId}_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  String _key(String formId, String fieldKey) =>
      '$_prefix${formId}_$fieldKey';
}
