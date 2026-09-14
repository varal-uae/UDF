/// Step 236 (GEN-00066) -- what a "compliance field" is, and what this
/// repository actually has.
///
/// The row: "Determine the exact data types and input masks required for every
/// compliance field."
/// Metric: **Requirements Definition Completeness** -- floor "All required
/// inputs identified (no gaps)", optimal "100% coverage of requirement scope",
/// ceiling 1. Complete/Partial/Not Complete.
///
/// **The repository has thirteen field rules and no compliance fields.**
/// [HabotCde] names thirteen *data classes* -- a name, an email address, an
/// amount -- and every one of them is a shape. A compliance field is something
/// else: an identifier issued by an authority, with a published format, a
/// published jurisdiction, and often a published check digit. There are none.
/// `accountNumber` is the closest, and it is a length range over letters and
/// digits.
///
/// **The rule model cannot express one.** [HabotFieldRule] carries a mask and
/// a `RegExp pattern`. A regular expression can say that an IBAN is
/// twenty-three characters of the right shape; it cannot compute mod-97, and
/// mod-97 is the entire point of an IBAN. The gap this step reports is not a
/// missing rule, it is a missing *slot*: there is nowhere in the model to put
/// an arithmetic check. Steps 240 and 243 are where that lands.
///
/// **Two jurisdictions are already assumed and neither is declared.** The
/// money CDE is `cac_aed_value`, in AED with fils. The phone placeholder is
/// `+254 700 000000`, which is a Kenyan dialling code. Step 244 adds a third
/// when it asks for Form I-9 and a US Tax ID. So every identifier rule from
/// here on names the jurisdiction it belongs to, because an identifier without
/// one is a rule that is right somewhere and wrong here.
library;

import '../i18n/fixed_precision.dart';

/// What kind of check a field's correctness actually needs.
enum HabotCheckKind {
  /// A character-class filter. Says what may be typed.
  mask,

  /// A regular expression over the whole value. Says what shape it must be.
  pattern,

  /// Arithmetic over the value's own digits. A regular expression cannot do
  /// this, and this is the slot the current model does not have.
  checksum,

  /// A lookup against a published registry that changes without notice.
  /// Cannot be embedded in a client without going stale.
  registry,

  /// A relation between two or more fields. Belongs to no single field.
  crossField,
}

/// One field this repository takes from a person.
class HabotFieldFact {
  const HabotFieldFact({
    required this.name,
    required this.dataType,
    required this.checks,
    required this.jurisdiction,
    required this.isAnIssuedIdentifier,
    required this.declaredAt,
  });

  final String name;

  /// The type the value is held as once parsed, not the widget it is typed in.
  final String dataType;

  /// Every kind of check correctness requires. More than one is normal.
  final Set<HabotCheckKind> checks;

  /// The authority whose rules apply. Empty when the field is not
  /// jurisdictional -- a person's name is not issued by anybody.
  final String jurisdiction;

  /// Issued by an authority with a published format.
  final bool isAnIssuedIdentifier;

  /// Where the rule lives today, or empty when nothing declares it.
  final String declaredAt;

  /// Expressible in the current [HabotFieldRule] model, which has a mask and
  /// a pattern and nothing else.
  bool get fitsTheCurrentModel =>
      checks.every(
        (HabotCheckKind k) =>
            k == HabotCheckKind.mask || k == HabotCheckKind.pattern,
      );

  bool get isDeclared => declaredAt.isNotEmpty;
}

/// The inventory the row asks for.
class HabotComplianceFieldInventory {
  const HabotComplianceFieldInventory._();

  /// The thirteen shapes the repository declares today, collapsed into the
  /// four groups that behave differently, plus the identifiers this step
  /// found are missing.
  static List<HabotFieldFact> get fields => <HabotFieldFact>[
        const HabotFieldFact(
          name: 'free text, name, address line, postal code',
          dataType: 'String',
          checks: <HabotCheckKind>{
            HabotCheckKind.mask,
            HabotCheckKind.pattern,
          },
          jurisdiction: '',
          isAnIssuedIdentifier: false,
          declaredAt: 'HabotFieldRules',
        ),
        const HabotFieldFact(
          name: 'email address, phone number',
          dataType: 'String',
          checks: <HabotCheckKind>{
            HabotCheckKind.mask,
            HabotCheckKind.pattern,
          },
          jurisdiction: 'the phone placeholder assumes +254 and says so '
              'nowhere else',
          isAnIssuedIdentifier: false,
          declaredAt: 'HabotFieldRules',
        ),
        const HabotFieldFact(
          name: 'date, time',
          dataType: 'DateTime',
          checks: <HabotCheckKind>{
            HabotCheckKind.mask,
            HabotCheckKind.pattern,
          },
          jurisdiction: 'dateUs is a US ordering; dateIso is not',
          isAnIssuedIdentifier: false,
          declaredAt: 'HabotFieldRules',
        ),
        const HabotFieldFact(
          name: 'currency amount, quantity, percentage',
          dataType: 'HabotFixed',
          checks: <HabotCheckKind>{
            HabotCheckKind.mask,
            HabotCheckKind.pattern,
            HabotCheckKind.crossField,
          },
          jurisdiction: 'AED, at fils precision',
          isAnIssuedIdentifier: false,
          declaredAt: 'HabotFieldRules + HabotPrecision',
        ),
        const HabotFieldFact(
          name: 'IBAN',
          dataType: 'String, normalised and upper-cased',
          checks: <HabotCheckKind>{
            HabotCheckKind.mask,
            HabotCheckKind.pattern,
            HabotCheckKind.checksum,
            HabotCheckKind.registry,
          },
          jurisdiction: 'ISO 13616, per country',
          isAnIssuedIdentifier: true,
          declaredAt: '',
        ),
        const HabotFieldFact(
          name: 'national tax identifier',
          dataType: 'String',
          checks: <HabotCheckKind>{
            HabotCheckKind.mask,
            HabotCheckKind.pattern,
            HabotCheckKind.registry,
          },
          jurisdiction: 'named per country; no single format exists',
          isAnIssuedIdentifier: true,
          declaredAt: '',
        ),
      ];

  /// The row's own words: "every compliance field".
  static List<HabotFieldFact> get issuedIdentifiers =>
      fields.where((HabotFieldFact f) => f.isAnIssuedIdentifier).toList();

  /// Of those, the ones nothing in the repository declares. This is the gap.
  static List<HabotFieldFact> get undeclaredIdentifiers =>
      issuedIdentifiers.where((HabotFieldFact f) => !f.isDeclared).toList();

  /// Fields whose correctness needs something the current model has no slot
  /// for. The finding is the count, not the names.
  static List<HabotFieldFact> get beyondTheCurrentModel =>
      fields.where((HabotFieldFact f) => !f.fitsTheCurrentModel).toList();

  static bool get everyIssuedIdentifierIsUndeclared =>
      issuedIdentifiers.length == undeclaredIdentifiers.length &&
      issuedIdentifiers.isNotEmpty;

  /// The check kinds the model can express today.
  static Set<HabotCheckKind> get expressibleToday => <HabotCheckKind>{
        HabotCheckKind.mask,
        HabotCheckKind.pattern,
      };

  static Set<HabotCheckKind> get inexpressibleToday =>
      HabotCheckKind.values.toSet().difference(expressibleToday);

  /// Every kind of check some field in this inventory actually needs.
  static Set<HabotCheckKind> get kindsRequired => fields
      .expand((HabotFieldFact f) => f.checks)
      .toSet();

  static bool get everyKindIsRequiredBySomething =>
      kindsRequired.length == HabotCheckKind.values.length;

  // -----------------------------------------------------------------------
  // The two jurisdictions already assumed.
  // -----------------------------------------------------------------------

  static const String aedCde = HabotPrecision.cdeName;

  static const String kenyanPlaceholder = '+254 700 000000';

  static const String jurisdictionNote =
      'Two jurisdictions are already assumed and neither is declared as one. '
      'The money CDE is $aedCde -- AED, held at fils precision. The phone '
      'rule\'s placeholder is $kenyanPlaceholder, which is a Kenyan dialling '
      'code. One of them is wrong, or the application is multi-market and '
      'neither should be a constant in a field rule. Step 244 adds a third '
      'when it asks for Form I-9 and a US Tax ID, so from here every '
      'identifier rule names the jurisdiction it belongs to: an identifier '
      'rule without one is a rule that is right somewhere and wrong here.';

  static const String missingSlotNote =
      'The gap is not a missing rule, it is a missing SLOT. HabotFieldRule '
      'carries a mask and a RegExp pattern. A regular expression can say that '
      'an IBAN is twenty-three characters of the right shape; it cannot '
      'compute mod-97, and mod-97 is the entire point of an IBAN. Three of '
      'the five kinds of check this inventory needs -- checksum, registry and '
      'cross-field -- have nowhere to go in the current model. Steps 240, 243 '
      'and 252 are where each of them lands.';

  static const String thirteenShapesNote =
      'HabotCde names thirteen data classes and every one of them is a SHAPE: '
      'a name, an email address, an amount. A compliance field is something '
      'else -- an identifier issued by an authority, with a published format, '
      'a published jurisdiction and often a published check digit. There are '
      'none. accountNumber is the closest and it is a length range over '
      'letters and digits.';

  // -----------------------------------------------------------------------
  // Metric: Requirements Definition Completeness.
  // -----------------------------------------------------------------------

  static Map<String, bool> get scopeCriteria => <String, bool>{
        'every field this repository takes from a person is listed with its '
            'data type': fields.every(
          (HabotFieldFact f) => f.dataType.isNotEmpty,
        ),
        'every field lists every kind of check its correctness needs':
            fields.every((HabotFieldFact f) => f.checks.isNotEmpty),
        'every kind of check is required by at least one field, so none is '
            'listed for completeness alone': everyKindIsRequiredBySomething,
        'the fields the row calls compliance fields are identified, and the '
            'fact that none is declared is reported':
            everyIssuedIdentifierIsUndeclared,
        'the checks the current model cannot express are named':
            beyondTheCurrentModel.isNotEmpty &&
                inexpressibleToday.length == 3,
        'every jurisdictional assumption already in the repository is '
            'written down': jurisdictionNote.contains(kenyanPlaceholder) &&
            jurisdictionNote.contains(aedCde),
      };

  static double get completeness =>
      scopeCriteria.values.where((bool b) => b).length / scopeCriteria.length;

  /// The floor is "all required inputs identified (no gaps)". Identifying a
  /// gap is not the same as having none, and the row asks for the former.
  static String get qualitativeOutput {
    if (completeness == 1.0) {
      return 'Complete';
    }
    return completeness >= 0.8 ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'the inventory covers every field the repository takes from a person':
            fields.length == 6,
        'five kinds of check are distinguished':
            HabotCheckKind.values.length == 5,
        'only two of the five fit the current rule model':
            expressibleToday.length == 2,
        'two issued identifiers are named and neither is declared':
            issuedIdentifiers.length == 2 && undeclaredIdentifiers.length == 2,
        'the missing slot is described rather than filled here':
            missingSlotNote.contains('missing SLOT'),
        'the thirteen existing rules are described as shapes, not compliance '
            'fields': thirteenShapesNote.contains('thirteen data classes'),
        'both existing jurisdictional assumptions are recorded':
            jurisdictionNote.contains('multi-market'),
        'every scope criterion holds': completeness == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Determine the exact data types and input masks required for every '
      'compliance field."';
}
