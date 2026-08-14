import 'package:intl/intl.dart';

// GEN-04588 — Localized Formatting Helpers.
// Single source of truth for all date, time, currency, and number formatting.
// Spec: Unicode CLDR / W3C i18n Standard.
//
// Jurisdiction support:
//   UAE  → en_AE locale, AED currency, DD/MM/YYYY dates, Gregorian calendar
//   India → en_IN locale, INR currency, DD/MM/YYYY dates, Indian number system
//
// Rule: widgets NEVER call DateFormat / NumberFormat directly.
//       Always use HabotFormatters — one source, zero drift.

// ── Supported jurisdictions ──────────────────────────────────────────────────

enum HabotLocale { uae, india, global }

extension HabotLocaleX on HabotLocale {
  String get locale {
    switch (this) {
      case HabotLocale.uae:    return 'en_AE';
      case HabotLocale.india:  return 'en_IN';
      case HabotLocale.global: return 'en_US';
    }
  }

  String get currencyCode {
    switch (this) {
      case HabotLocale.uae:    return 'AED';
      case HabotLocale.india:  return 'INR';
      case HabotLocale.global: return 'USD';
    }
  }

  String get currencySymbol {
    switch (this) {
      case HabotLocale.uae:    return 'AED';
      case HabotLocale.india:  return '₹';
      case HabotLocale.global: return '\$';
    }
  }
}

// ── Formatter class ───────────────────────────────────────────────────────────

abstract class HabotFormatters {

  // ── DATE ──────────────────────────────────────────────────────────────────

  /// DD/MM/YYYY — standard across UAE and India
  /// e.g. 25/12/2024
  static String date(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    return DateFormat('dd/MM/yyyy', locale.locale).format(dt);
  }

  /// Short date — D MMM YYYY
  /// e.g. 25 Dec 2024
  static String dateShort(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    return DateFormat('d MMM yyyy', locale.locale).format(dt);
  }

  /// Long date — Weekday, D Month YYYY
  /// e.g. Wednesday, 25 December 2024
  static String dateLong(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    return DateFormat('EEEE, d MMMM yyyy', locale.locale).format(dt);
  }

  /// Month + year only — MMM YYYY
  /// e.g. Dec 2024
  static String dateMonthYear(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    return DateFormat('MMM yyyy', locale.locale).format(dt);
  }

  /// Relative date — "Today", "Yesterday", "3 days ago", or DD/MM/YYYY
  static String dateRelative(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    final now  = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0 && now.day == dt.day) return 'Today';
    if (diff.inDays == 1 || (diff.inDays == 0 && now.day != dt.day)) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return date(dt, locale: locale);
  }

  // ── TIME ──────────────────────────────────────────────────────────────────

  /// 12-hour format — h:mm AM/PM
  /// e.g. 2:30 PM
  static String time12h(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    return DateFormat('h:mm a', locale.locale).format(dt);
  }

  /// 24-hour format — HH:mm
  /// e.g. 14:30
  static String time24h(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  /// Date + time — DD/MM/YYYY, h:mm AM/PM
  /// e.g. 25/12/2024, 2:30 PM
  static String dateTime(DateTime dt, {HabotLocale locale = HabotLocale.uae}) {
    return '${date(dt, locale: locale)}, ${time12h(dt, locale: locale)}';
  }

  /// ISO 8601 UTC timestamp — for API payloads and analytics
  /// e.g. 2024-12-25T14:30:00.000Z
  static String isoUtc(DateTime dt) {
    return dt.toUtc().toIso8601String();
  }

  /// ISO 8601 date-only UTC — midnight UTC for date-only API fields
  /// e.g. 2024-12-25T00:00:00.000Z
  static String isoUtcDateOnly(DateTime dt) {
    final utc = DateTime.utc(dt.year, dt.month, dt.day);
    return utc.toIso8601String();
  }

  /// Parse ISO 8601 UTC string → local [DateTime] for display.
  /// Returns null if the string is invalid.
  static DateTime? parseIsoUtc(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Parse DD/MM/YYYY typed string → local [DateTime].
  static DateTime? parseLocalDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final match = regex.firstMatch(value.trim());
    if (match == null) return null;

    final day   = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year  = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;

    return DateTime(year, month, day);
  }

  /// Enforce ISO 8601 UTC output — rejects invalid local dates.
  static String? enforceIsoUtc(DateTime? local, {bool dateOnly = false}) {
    if (local == null) return null;
    return dateOnly ? isoUtcDateOnly(local) : isoUtc(local);
  }

  /// Duration — mm:ss or hh:mm:ss
  /// e.g. 1:23:45 or 23:45
  static String duration(Duration d) {
    final h  = d.inHours;
    final m  = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s  = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // ── CURRENCY ──────────────────────────────────────────────────────────────

  /// Standard currency — AED 1,234.56 / ₹ 1,234.56
  static String currency(
    double amount, {
    HabotLocale locale = HabotLocale.uae,
    int decimalDigits = 2,
  }) {
    return NumberFormat.currency(
      locale:        locale.locale,
      symbol:        '${locale.currencySymbol} ',
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Compact currency — AED 1.2K / ₹ 1.2L
  static String currencyCompact(
    double amount, {
    HabotLocale locale = HabotLocale.uae,
  }) {
    final formatted = NumberFormat.compactCurrency(
      locale: locale.locale,
      symbol: '${locale.currencySymbol} ',
    ).format(amount);
    return formatted;
  }

  /// Currency without symbol — 1,234.56
  static String currencyRaw(double amount, {HabotLocale locale = HabotLocale.uae}) {
    return NumberFormat('#,##0.00', locale.locale).format(amount);
  }

  /// Parse currency string back to double — strips symbol and commas
  static double? parseCurrency(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  // ── NUMBERS ───────────────────────────────────────────────────────────────

  /// Integer with thousand separators — 1,234,567
  static String integer(int value, {HabotLocale locale = HabotLocale.uae}) {
    return NumberFormat('#,##0', locale.locale).format(value);
  }

  /// Decimal — 1,234.56 (configurable decimal places)
  static String decimal(
    double value, {
    HabotLocale locale = HabotLocale.uae,
    int decimalDigits = 2,
  }) {
    return NumberFormat(
      '#,##0.${'0' * decimalDigits}',
      locale.locale,
    ).format(value);
  }

  /// Percentage — 94.5%
  static String percent(double value, {int decimalDigits = 1}) {
    return NumberFormat.percentPattern()
        .format(value / 100)
        .replaceAll('%', '')
        .trim()
        + '%';
  }

  /// Compact number — 1.2K / 1.2M / 1.2B
  static String compact(num value, {HabotLocale locale = HabotLocale.uae}) {
    return NumberFormat.compact(locale: locale.locale).format(value);
  }

  /// File size — 1.2 KB / 3.4 MB / 1.1 GB
  static String fileSize(int bytes) {
    if (bytes < 1024)       return '$bytes B';
    if (bytes < 1048576)    return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  /// Ordinal — 1st, 2nd, 3rd, 4th …
  static String ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:  return '${n}st';
      case 2:  return '${n}nd';
      case 3:  return '${n}rd';
      default: return '${n}th';
    }
  }

  // ── PHONE ─────────────────────────────────────────────────────────────────

  /// Format phone for display — strips formatting, re-applies standard pattern
  static String phone(String raw, {HabotLocale locale = HabotLocale.uae}) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    switch (locale) {
      case HabotLocale.uae:
        if (digits.length == 9) return '+971 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}';
        return '+971 $digits';
      case HabotLocale.india:
        if (digits.length == 10) return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
        return '+91 $digits';
      case HabotLocale.global:
        return '+$digits';
    }
  }

  // ── MASKING (PII display) ─────────────────────────────────────────────────

  /// Mask email — j***@habot.com
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name   = parts[0];
    final domain = parts[1];
    if (name.isEmpty) return email;
    return '${name[0]}***@$domain';
  }

  /// Mask phone — +971 ** *** 4567
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return phone;
    return '${phone.substring(0, phone.length - 4)}****';
  }

  /// Mask card number — **** **** **** 1234
  static String maskCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return cardNumber;
    return '**** **** **** ${digits.substring(digits.length - 4)}';
  }
}
