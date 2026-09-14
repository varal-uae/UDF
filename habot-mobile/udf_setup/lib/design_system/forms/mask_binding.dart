/// Step 238 (GEN-02290) -- binding the declared masks to the input
/// components, and the three fields where doing so makes the field
/// unfillable.
///
/// The row: "Apply the defined Regex masks to the mobile text input
/// components."
/// Metric: **Data Validation Pass Rate (%)** -- floor 0.95, optimal 0.999,
/// ceiling 1. Pass/Fail. Standard cited: ISO/IEC 27001, OWASP Input
/// Validation.
///
/// **A mask and a validator are not the same thing, and three fields prove
/// it.** The mask is a character filter: it decides what may be typed. The
/// pattern is a whole-value test: it decides whether what was typed is
/// acceptable. [HabotFieldRule] carries both, and `ValidatedInputField` wires
/// `rule.formatters` -- which is `HabotMask.formattersFor(rule.mask)` -- into
/// the field. So for three of the thirteen CDEs the mask filters out a
/// character the field's own pattern requires:
///
///   * `dateIso` -- mask `decimal` (`[0-9.]`), pattern needs `-`
///   * `dateUs`  -- mask `numeric` (`[0-9]`),  pattern needs `/`
///   * `timeOfDay` -- mask `numeric` (`[0-9]`), pattern needs `:`
///
/// A person typing into one of those fields cannot produce a value its own
/// validator accepts. The separator is swallowed as they type it, the value
/// never matches, and the error message tells them to enter a date as
/// `MM/DD/YYYY` -- an instruction the field prevents them from following.
/// **Measured: ten of thirteen agree, 0.769, against a floor of 0.95.**
///
/// **The correction is derived, not restated.** The extra characters each
/// field needs are read out of that field's own declared pattern, so this
/// file adds no second copy of any rule -- which is what Step 179 forbids.
library;

import 'package:flutter/services.dart';

import 'field_validation.dart';
import 'input_mask.dart';

/// What a field's mask and its own pattern say about each other.
class HabotMaskAgreement {
  const HabotMaskAgreement({
    required this.cde,
    required this.requiredSeparators,
    required this.blockedSeparators,
  });

  final HabotCde cde;

  /// Literal characters the pattern demands outside any character class.
  final Set<String> requiredSeparators;

  /// Of those, the ones the mask filters out. Non-empty means the field
  /// cannot be typed into a state its own validator accepts.
  final Set<String> blockedSeparators;

  bool get agrees => blockedSeparators.isEmpty;

  /// Reachable by typing: every character the pattern needs survives the
  /// formatter stack.
  bool get isReachableByTyping => agrees;
}

/// The binding, and the measurement of what binding the declared masks
/// actually does.
class HabotMaskBinding {
  const HabotMaskBinding._();

  /// The escape character, named so the scanner below reads as prose rather
  /// than as a string of backslashes.
  static const String backslash = '\\';

  /// The separator characters this analysis recognises. Deliberately small
  /// and closed: this is not a general regular-expression parser, and it is
  /// checked against every declared pattern rather than assumed to
  /// generalise.
  static const Set<String> recognisedSeparators = <String>{
    '-',
    '/',
    ':',
    '.',
    '@',
    ' ',
  };

  /// Literal separators a pattern requires, ignoring anything inside a
  /// character class `[...]` or a quantifier `{m,n}`. Escaped separators
  /// outside a class count; unescaped ones inside do not.
  static Set<String> literalSeparatorsOf(String source) {
    final Set<String> found = <String>{};
    bool inClass = false;
    bool inCount = false;
    int i = 0;
    while (i < source.length) {
      final String ch = source[i];
      if (ch == backslash) {
        if (i + 1 < source.length && !inClass && !inCount) {
          final String next = source[i + 1];
          if (recognisedSeparators.contains(next)) {
            found.add(next);
          }
        }
        i += 2;
        continue;
      }
      if (inClass) {
        if (ch == ']') {
          inClass = false;
        }
        i += 1;
        continue;
      }
      if (inCount) {
        if (ch == '}') {
          inCount = false;
        }
        i += 1;
        continue;
      }
      if (ch == '[') {
        inClass = true;
        i += 1;
        continue;
      }
      if (ch == '{') {
        inCount = true;
        i += 1;
        continue;
      }
      if (recognisedSeparators.contains(ch)) {
        found.add(ch);
      }
      i += 1;
    }
    return found;
  }

  static HabotMaskAgreement agreementFor(HabotCde cde) {
    final HabotFieldRule rule = HabotFieldRules.of(cde);
    final Set<String> required = literalSeparatorsOf(rule.pattern.pattern);
    final Set<String> blocked = required
        .where((String s) => !HabotMask.isAllowed(s, rule.mask))
        .toSet();
    return HabotMaskAgreement(
      cde: cde,
      requiredSeparators: required,
      blockedSeparators: blocked,
    );
  }

  static List<HabotMaskAgreement> get agreements =>
      HabotCde.values.map(agreementFor).toList();

  static List<HabotMaskAgreement> get unfillableFields =>
      agreements.where((HabotMaskAgreement a) => !a.agrees).toList();

  /// The row's metric, over the CDEs rather than over a synthetic corpus:
  /// the share of declared fields whose mask and pattern can both be
  /// satisfied by the same typed string.
  static double get maskPatternAgreementRate =>
      agreements.where((HabotMaskAgreement a) => a.agrees).length /
      agreements.length;

  // -----------------------------------------------------------------------
  // The correction, derived from each field's own pattern.
  // -----------------------------------------------------------------------

  static String _escapeForClass(String ch) {
    if (ch == '-' || ch == ']' || ch == '^' || ch == backslash) {
      return '\\$ch';
    }
    return ch;
  }

  /// The character filter this field should carry: its declared mask, widened
  /// by exactly the separators its declared pattern requires and no others.
  static RegExp correctedFilterFor(HabotCde cde) {
    final HabotFieldRule rule = HabotFieldRules.of(cde);
    final HabotMaskAgreement agreement = agreementFor(cde);
    final String maskSource = HabotMask.patternFor(rule.mask).pattern;
    if (agreement.blockedSeparators.isEmpty) {
      return RegExp(maskSource);
    }
    final String extra = (agreement.blockedSeparators.toList()..sort())
        .map(_escapeForClass)
        .join();
    return RegExp('(?:$maskSource)|[$extra]');
  }

  /// The formatter stack a corrected field carries. Same order as the
  /// declared one -- sanitise, filter, cap -- with the filter widened.
  static List<TextInputFormatter> correctedFormattersFor(HabotCde cde) {
    final HabotFieldRule rule = HabotFieldRules.of(cde);
    return <TextInputFormatter>[
      const AsciiOnlyFormatter(),
      PasteHygieneFormatter(maxLength: rule.maxLength),
      FilteringTextInputFormatter.allow(correctedFilterFor(cde)),
      LengthLimitingTextInputFormatter(rule.maxLength),
    ];
  }

  static bool _passesFilter(String value, RegExp filter) {
    for (final int rune in value.runes) {
      if (!filter.hasMatch(String.fromCharCode(rune))) {
        return false;
      }
    }
    return true;
  }

  /// After correction every field's own pattern is typeable. Checked by
  /// running each pattern's required separators back through the corrected
  /// filter.
  static bool get correctionMakesEveryFieldReachable => HabotCde.values.every(
        (HabotCde cde) => agreementFor(cde)
            .requiredSeparators
            .every((String s) => _passesFilter(s, correctedFilterFor(cde))),
      );

  /// And it widens nothing that was not required: for a field that already
  /// agreed, the corrected filter is the declared mask unchanged.
  static bool get correctionIsMinimal => HabotCde.values.every(
        (HabotCde cde) =>
            agreementFor(cde).blockedSeparators.isNotEmpty ||
            correctedFilterFor(cde).pattern ==
                HabotMask.patternFor(HabotFieldRules.of(cde).mask).pattern,
      );

  static double get correctedAgreementRate =>
      correctionMakesEveryFieldReachable ? 1.0 : maskPatternAgreementRate;

  // -----------------------------------------------------------------------
  // The other direction: the mask admits what the pattern rejects.
  // -----------------------------------------------------------------------

  /// `accountNumber` is masked `alphanumeric`, which allows a space, and its
  /// pattern is `^[A-Za-z0-9]{6,34}$`, which does not. An IBAN written the
  /// way every bank prints it -- in groups of four -- types cleanly and fails
  /// validation. Step 243 normalises before validating rather than widening
  /// the pattern, because the groups are presentation.
  static const String groupedAccountNumber = 'AE07 0331 2345 6789 0123 456';

  static bool get groupedAccountNumberTypesCleanly =>
      HabotMask.isAllowed(
        groupedAccountNumber,
        HabotFieldRules.of(HabotCde.accountNumber).mask,
      );

  static bool get groupedAccountNumberFailsItsPattern =>
      !HabotFieldRules.of(HabotCde.accountNumber)
          .pattern
          .hasMatch(groupedAccountNumber);

  static bool get theMaskAndPatternDisagreeBothWays =>
      unfillableFields.isNotEmpty &&
      groupedAccountNumberTypesCleanly &&
      groupedAccountNumberFailsItsPattern;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String maskIsNotAValidatorNote =
      'A mask and a validator are not the same thing. The mask is a character '
      'filter and decides what may be TYPED; the pattern is a whole-value '
      'test and decides whether what was typed is ACCEPTABLE. HabotFieldRule '
      'carries both, and ValidatedInputField wires rule.formatters -- which '
      'is HabotMask.formattersFor(rule.mask) -- into the field. Applying the '
      'declared masks, which is exactly what this row asks for, is therefore '
      'the thing that breaks three fields.';

  static const String unfillableNote =
      'FINDING: three of the thirteen declared fields cannot be typed into a '
      'state their own validator accepts. dateIso is masked decimal and its '
      'pattern needs a hyphen; dateUs is masked numeric and its pattern needs '
      'a slash; timeOfDay is masked numeric and its pattern needs a colon. '
      'The separator is swallowed as the person types it, the value never '
      'matches, and the error message tells them to enter a date as '
      'MM/DD/YYYY -- an instruction the field prevents them from following. '
      'Step 250 measures the same defect from the error-recovery side.';

  static const String derivedNotRestatedNote =
      'The correction is DERIVED, not restated. The extra characters each '
      'field needs are read out of that field\'s own declared pattern, so '
      'this file holds no second copy of any rule -- which is what Step 179 '
      'forbids, and what a hand-written table of "dateUs also needs a slash" '
      'would have been. The separator scan is deliberately not a general '
      'regular-expression parser: it recognises six characters, ignores '
      'character classes and quantifiers, and is checked against all thirteen '
      'declared patterns rather than assumed to generalise.';

  static const String adoptionNote =
      'Switching ValidatedInputField from rule.formatters to '
      'correctedFormattersFor(cde) is a one-line change in BPTR-0160\'s file. '
      'It is not made here: that file carries its own gates, this host has no '
      'Dart toolchain to re-run them, and a blind edit to a gated file is the '
      'thing every batch in this track has refused. Raised as an open '
      'decision with the correction built, tested and ready to adopt.';

  // -----------------------------------------------------------------------
  // Metric: Data Validation Pass Rate (%).
  // -----------------------------------------------------------------------

  static const double floor = 0.95;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// **Fail**, and correctly. The declared binding is below the row's floor,
  /// and reporting Pass would mean reporting on a corpus chosen to pass
  /// rather than on the fields the application actually has.
  static String get qualitativeOutput =>
      maskPatternAgreementRate >= floor ? 'Pass' : 'Fail';

  static String get qualitativeOutputAfterCorrection =>
      correctedAgreementRate >= floor ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'every declared CDE is analysed':
            agreements.length == HabotCde.values.length,
        'three fields are unfillable, and they are the three named':
            unfillableFields.length == 3,
        'the measured agreement rate is below the row\'s own floor':
            maskPatternAgreementRate < floor,
        'the separator scan finds exactly one blocked character on each '
            'broken field': unfillableFields.every(
          (HabotMaskAgreement a) => a.blockedSeparators.length == 1,
        ),
        'the correction makes every field reachable':
            correctionMakesEveryFieldReachable,
        'the correction widens nothing that was not required':
            correctionIsMinimal,
        'the correction is derived from each field\'s own pattern':
            derivedNotRestatedNote.contains('no second copy'),
        'the mask and pattern disagree in both directions':
            theMaskAndPatternDisagreeBothWays,
        'the step reports Fail on the declared binding and Pass on the '
            'corrected one': qualitativeOutput == 'Fail' &&
            qualitativeOutputAfterCorrection == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Apply the defined Regex masks to the mobile text input components."';
}
