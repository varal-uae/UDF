import 'package:flutter/material.dart';

import '../../shared/layout/screen_size_provider.dart';
import 'habot_formatters.dart';

// PSAEG-007 — Date/Time ISO 8601 Enforcer.
//
// Native MD3 date/time pickers with a single enforcement pipeline:
//   pick locally → display in user's timezone → emit ISO 8601 UTC for API
//
// Spec:
//   - Material Date/Time visual components (showDatePicker / showTimePicker)
//   - UTC conversion handled silently — widgets emit isoUtc strings only
//   - Timezone-aware local display via HabotFormatters
//   - Desktop/wide: centered picker dialog (Flutter default)
//   - Mobile: native MD3 bottom-sheet style pickers

/// Result of a date/time selection through the enforcer pipeline.
class Iso8601Selection {
  const Iso8601Selection({
    required this.local,
    required this.isoUtc,
  });

  /// User-facing local datetime (device timezone).
  final DateTime local;

  /// API-safe ISO 8601 UTC string — always use this for payloads.
  final String isoUtc;
}

/// Central enforcer — all date/time values pass through here before API emit.
abstract class Iso8601DateEnforcer {
  /// Converts local selection to enforced ISO 8601 UTC string.
  static String enforce(DateTime local, {bool dateOnly = false}) {
    return dateOnly
        ? HabotFormatters.isoUtcDateOnly(local)
        : HabotFormatters.isoUtc(local);
  }

  /// Parses API ISO string back to local display value.
  static DateTime? fromApi(String? isoUtc) => HabotFormatters.parseIsoUtc(isoUtc);

  /// Opens native MD3 date picker. Returns null if cancelled.
  static Future<Iso8601Selection?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    HabotLocale locale = HabotLocale.uae,
    bool dateOnly = true,
  }) async {
    final now   = DateTime.now();
    final initial = initialDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(now.year - 100),
      lastDate:  lastDate  ?? DateTime(now.year + 10),
      locale: Locale(locale.locale.split('_').first, locale.locale.split('_').last),
      helpText: 'Select date',
      cancelText: 'Cancel',
      confirmText: 'OK',
      builder: (ctx, child) => _themedPicker(ctx, child),
    );

    if (picked == null) return null;

    final local = DateTime(picked.year, picked.month, picked.day);
    return Iso8601Selection(
      local: local,
      isoUtc: enforce(local, dateOnly: dateOnly),
    );
  }

  /// Opens date then time picker. Returns combined local + ISO UTC.
  static Future<Iso8601Selection?> pickDateTime(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    HabotLocale locale = HabotLocale.uae,
  }) async {
    final dateResult = await pickDate(
      context,
      initialDate: initialDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: locale,
      dateOnly: false,
    );
    if (dateResult == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime ?? dateResult.local),
      helpText: 'Select time',
      cancelText: 'Cancel',
      confirmText: 'OK',
      builder: (ctx, child) => _themedPicker(ctx, child),
    );

    if (time == null) return null;

    final local = DateTime(
      dateResult.local.year,
      dateResult.local.month,
      dateResult.local.day,
      time.hour,
      time.minute,
    );

    return Iso8601Selection(
      local: local,
      isoUtc: enforce(local),
    );
  }

  static Widget _themedPicker(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        dialogTheme: DialogThemeData(
          alignment: ScreenSizeProvider.of(context).isCompact
              ? Alignment.bottomCenter
              : Alignment.center,
        ),
      ),
      child: child!,
    );
  }
}

// ── Picker field widget ───────────────────────────────────────────────────────

enum HabotDatePickerMode { date, dateTime }

/// MD3 date/time picker field — displays local, emits ISO 8601 UTC.
class HabotDatePickerField extends FormField<Iso8601Selection> {
  HabotDatePickerField({
    super.key,
    this.label = 'Date',
    this.hint,
    this.mode = HabotDatePickerMode.date,
    this.locale = HabotLocale.uae,
    this.initialIsoUtc,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.onChanged,
    this.enabled = true,
  }) : super(
          initialValue: initialIsoUtc != null
              ? _selectionFromIso(initialIsoUtc, locale)
              : null,
          validator: (value) {
            if (validator != null) return validator(value?.isoUtc);
            return null;
          },
          builder: (field) {
            final selection = field.value;
            final theme = Theme.of(field.context);
            final display = selection != null
                ? (mode == HabotDatePickerMode.dateTime
                    ? HabotFormatters.dateTime(selection.local, locale: locale)
                    : HabotFormatters.date(selection.local, locale: locale))
                : hint ?? 'Select date';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: enabled
                      ? () => _openPicker(
                            field: field,
                            mode: mode,
                            locale: locale,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            onChanged: onChanged,
                          )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: label,
                      errorText: field.errorText,
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabled: enabled,
                    ),
                    child: Text(
                      display,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: selection != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                if (selection != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'API: ${selection.isoUtc}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        );

  final String label;
  final String? hint;
  final HabotDatePickerMode mode;
  final HabotLocale locale;
  final String? initialIsoUtc;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String? isoUtc)? validator;
  final ValueChanged<Iso8601Selection>? onChanged;
  final bool enabled;

  static Iso8601Selection? _selectionFromIso(String iso, HabotLocale locale) {
    final local = HabotFormatters.parseIsoUtc(iso);
    if (local == null) return null;
    return Iso8601Selection(local: local, isoUtc: iso);
  }

  static Future<void> _openPicker({
    required FormFieldState<Iso8601Selection> field,
    required HabotDatePickerMode mode,
    required HabotLocale locale,
    DateTime? firstDate,
    DateTime? lastDate,
    ValueChanged<Iso8601Selection>? onChanged,
  }) async {
    final Iso8601Selection? result;
    if (mode == HabotDatePickerMode.dateTime) {
      result = await Iso8601DateEnforcer.pickDateTime(
        field.context,
        initialDateTime: field.value?.local,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: locale,
      );
    } else {
      result = await Iso8601DateEnforcer.pickDate(
        field.context,
        initialDate: field.value?.local,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: locale,
      );
    }

    if (result == null) return;
    field.didChange(result);
    onChanged?.call(result);
  }
}
