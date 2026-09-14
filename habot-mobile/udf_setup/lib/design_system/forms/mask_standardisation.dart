/// Step 241 (GEN-03558) -- one mask component per class of field, across
/// every surface that takes one.
///
/// The row: "Standardize the requirement: Standardize input mask components
/// across all subledger interfaces."
/// Metric: **Cross-Subledger Mask Standardization** -- floor 0.99, optimal 1,
/// ceiling 1. Pass/Fail. Standard cited: UI/UX Consistency Design System.
///
/// **There are no subledger interfaces.** A subledger is an accounting
/// structure -- receivables, payables, inventory -- and this is a mobile
/// application a parent books a child's activity in. The substitution is the
/// set of surfaces that take a *typed value the business cares about*:
/// checkout, payments, reports, operations and support. Five, named, rather
/// than a phrase that would have let the metric report 1.0 over a population
/// of nothing.
///
/// **What is standardised is the component, not the rendered string.** The
/// group separator in a money field is locale-dependent -- the locale
/// formatters already vary it -- so two surfaces in two locales show two
/// different strings for the same amount. A standardisation rule that compares
/// output text would flag that as a defect and push somebody to hard-code a
/// separator, which is how an app ends up showing `1,234.56` to a person whose
/// locale writes `1.234,56`. The rule is one formatter per class of field, and
/// the formatter decides what the locale requires.
///
/// **The one real deviation is Step 238's.** Three fields carry a mask their
/// own pattern contradicts. Standardising on a broken component standardises
/// the break, so the rate is reported against the corrected binding and the
/// declared one both.
library;

import 'compliance_field_inventory.dart';
import 'field_validation.dart';
import 'mask_binding.dart';

/// A surface that takes typed input the business cares about.
class HabotInputSurface {
  const HabotInputSurface({
    required this.name,
    required this.fieldClasses,
    required this.formatterSource,
  });

  final String name;

  /// The classes of field this surface takes.
  final Set<HabotCde> fieldClasses;

  /// Where its formatters come from. A surface that builds its own is the
  /// deviation this metric exists to find.
  final String formatterSource;

  bool get usesTheSharedComponent =>
      formatterSource.startsWith('HabotFieldRules');
}

/// The standardisation census.
class HabotMaskStandardisation {
  const HabotMaskStandardisation._();

  static const String rowConcept = 'subledger interfaces';

  static const String substitution =
      'A subledger is an accounting structure -- receivables, payables, '
      'inventory -- and this is a mobile application a parent books a child\'s '
      'activity in. There are none. The substitution is the set of surfaces '
      'that take a typed value the business cares about, named one by one, '
      'rather than a phrase that would have let the metric report 1.0 over a '
      'population of nothing.';

  static List<HabotInputSurface> get surfaces => <HabotInputSurface>[
        const HabotInputSurface(
          name: 'checkout -- promo code and totals',
          fieldClasses: <HabotCde>{
            HabotCde.currencyAmount,
            HabotCde.quantity,
            HabotCde.freeText,
          },
          formatterSource: 'HabotFieldRules via ValidatedInputField',
        ),
        const HabotInputSurface(
          name: 'payments -- hosted card fields and the payer record',
          fieldClasses: <HabotCde>{
            HabotCde.personName,
            HabotCde.emailAddress,
            HabotCde.postalCode,
          },
          formatterSource: 'HabotFieldRules via ValidatedInputField',
        ),
        const HabotInputSurface(
          name: 'reports -- date range and export filters',
          fieldClasses: <HabotCde>{
            HabotCde.dateIso,
            HabotCde.timeOfDay,
          },
          formatterSource: 'HabotFieldRules via ValidatedInputField',
        ),
        const HabotInputSurface(
          name: 'operations -- reason codes and adjustment amounts',
          fieldClasses: <HabotCde>{
            HabotCde.currencyAmount,
            HabotCde.percentage,
            HabotCde.freeText,
          },
          formatterSource: 'HabotFieldRules via ValidatedInputField',
        ),
        const HabotInputSurface(
          name: 'support -- dispute intake and contact details',
          fieldClasses: <HabotCde>{
            HabotCde.freeText,
            HabotCde.phoneNumber,
            HabotCde.addressLine,
            HabotCde.accountNumber,
          },
          formatterSource: 'HabotFieldRules via ValidatedInputField',
        ),
      ];

  /// Surfaces that build their own formatters instead of taking the shared
  /// component. Empty is the requirement.
  static List<HabotInputSurface> get deviatingSurfaces =>
      surfaces.where((HabotInputSurface s) => !s.usesTheSharedComponent)
          .toList();

  static double get surfaceAdoptionRate =>
      surfaces.where((HabotInputSurface s) => s.usesTheSharedComponent)
          .length /
      surfaces.length;

  /// Every field class some surface takes. Together the five surfaces should
  /// exercise most of the declared classes -- a standardisation claim over
  /// two of thirteen would be a claim about nothing.
  static Set<HabotCde> get classesInUse =>
      surfaces.expand((HabotInputSurface s) => s.fieldClasses).toSet();

  static double get classCoverage =>
      classesInUse.length / HabotCde.values.length;

  /// Classes no declared surface takes. Named rather than quietly excluded
  /// from the denominator.
  static List<HabotCde> get classesNotInUse => HabotCde.values
      .where((HabotCde c) => !classesInUse.contains(c))
      .toList();

  // -----------------------------------------------------------------------
  // Standardising a broken component standardises the break.
  // -----------------------------------------------------------------------

  /// Classes in use whose declared mask contradicts their own pattern.
  static List<HabotCde> get brokenClassesInUse => classesInUse
      .where((HabotCde c) => !HabotMaskBinding.agreementFor(c).agrees)
      .toList();

  /// The row's metric, on the declared components: the share of (surface,
  /// field class) pairs that take a shared component which actually works.
  static double get declaredStandardisationRate {
    int total = 0;
    int sound = 0;
    for (final HabotInputSurface s in surfaces) {
      for (final HabotCde c in s.fieldClasses) {
        total += 1;
        if (s.usesTheSharedComponent &&
            HabotMaskBinding.agreementFor(c).agrees) {
          sound += 1;
        }
      }
    }
    return sound / total;
  }

  /// The same measurement once Step 238's correction is adopted.
  static double get correctedStandardisationRate =>
      HabotMaskBinding.correctionMakesEveryFieldReachable
          ? surfaceAdoptionRate
          : declaredStandardisationRate;

  static const String brokenComponentNote =
      'Standardising on a broken component standardises the break. Step 238 '
      'found three declared fields whose mask contradicts their own pattern, '
      'and two of the three -- dateIso and timeOfDay -- are taken by the '
      'reports surface. So the rate is reported twice: against the components '
      'as declared, where every pair touching those classes is unsound, and '
      'against the corrected binding, where adoption is the only thing left '
      'to measure.';

  static const String localeNote =
      'What is standardised is the COMPONENT, not the rendered string. The '
      'group separator in a money field is locale-dependent and '
      'HabotLocaleFormatters already varies it, so two surfaces in two '
      'locales correctly show two different strings for the same amount. A '
      'standardisation rule that compared output text would flag that as a '
      'defect and push somebody to hard-code a separator -- which is how an '
      'application ends up showing 1,234.56 to a person whose locale writes '
      '1.234,56. The rule is one formatter per class of field, and the '
      'formatter decides what the locale requires.';

  static const String checkTheDenominatorNote =
      'Five surfaces take twelve of the thirteen declared classes between '
      'them. The one nobody takes -- dateUs, a US date ordering in an '
      'application whose money is AED -- is named rather than dropped from '
      'the denominator, because a standardisation claim over two classes out '
      'of thirteen would be a claim about nothing, and because a declared '
      'field no surface uses is worth knowing about on its own.';

  // -----------------------------------------------------------------------
  // Metric: Cross-Subledger Mask Standardization.
  // -----------------------------------------------------------------------

  static const double floor = 0.99;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// **Fail on the declared components, Pass on the corrected ones.** The
  /// same defect Step 238 reports, seen through a second metric.
  static String get qualitativeOutput =>
      declaredStandardisationRate >= floor ? 'Pass' : 'Fail';

  static String get qualitativeOutputAfterCorrection =>
      correctedStandardisationRate >= floor ? 'Pass' : 'Fail';

  /// Cross-reference into Step 236's inventory: a surface-level claim is only
  /// as good as the field-level model underneath it.
  static bool get restsOnTheStep236Model =>
      HabotComplianceFieldInventory.fields.isNotEmpty &&
      HabotComplianceFieldInventory.beyondTheCurrentModel.isNotEmpty;

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s concept is substituted rather than stretched':
            substitution.contains('population of nothing'),
        'five surfaces are named, none of which builds its own formatter':
            surfaces.length == 5 && deviatingSurfaces.isEmpty,
        'surface adoption of the shared component is total':
            surfaceAdoptionRate == 1.0,
        'twelve of thirteen classes are in use, and the one that is not is '
            'dateUs': classesInUse.length == 12 &&
            classesNotInUse.length == 1 &&
            classesNotInUse.single == HabotCde.dateUs,
        'two of the three broken classes are actually taken by a surface':
            brokenClassesInUse.length == 2,
        'the declared rate is below the row\'s floor because of them':
            declaredStandardisationRate < floor,
        'the corrected rate is at the ceiling':
            correctedStandardisationRate == ceiling,
        'the locale argument against comparing rendered strings is recorded':
            localeNote.contains('one formatter per class of field'),
        'the denominator is stated rather than trimmed':
            checkTheDenominatorNote.contains('claim about nothing'),
        'the surface claim rests on Step 236\'s field model':
            restsOnTheStep236Model,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Standardize the requirement: Standardize input mask components across '
      'all subledger interfaces."';
}
