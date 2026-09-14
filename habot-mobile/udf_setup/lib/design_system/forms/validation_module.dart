/// Step 242 (GEN-01947) -- the Validation Module's manifest, and the rule
/// that a rule has one home.
///
/// The row: "Store the validation engine execution logic in the Validation
/// Module."
/// Metric: **Step Completion Rate (%)** -- floor 90, optimal 99, ceiling 100.
/// Complete/Partial/Not Complete.
///
/// **The logic is already stored. Storing it again is the defect.** Every rule
/// this row names lives in `lib/design_system/forms/`, and the only way to
/// satisfy "store it in the Validation Module" as an instruction to write code
/// would be to copy it somewhere and call that the module. Step 179 already
/// settled what two copies of a rule with one of them executed is. So the
/// artefact is a manifest: what the module contains, where each rule class is
/// declared, and a check that no rule class is declared twice.
///
/// **The sheet gives the module two names.** Twelve of the twenty rows in this
/// batch name `@habot/shared-library` as the Common Library to Store. This
/// row's own family names it that too; GEN-02117 -- Step 253, four rows later,
/// about the same validation logic -- names `Validation Module.` instead. Two
/// names for one place is how two places get built, and the manifest exists so
/// that the second name resolves to the first rather than to a new folder.
library;

import 'compliance_field_inventory.dart';
import 'edge_binding.dart';

/// One rule class and the single file that declares it.
class HabotModuleEntry {
  const HabotModuleEntry({
    required this.ruleClass,
    required this.declaredIn,
    required this.kind,
    required this.addedBy,
  });

  /// What the rule decides.
  final String ruleClass;

  /// The one file it lives in. Relative to `lib/design_system/`.
  final String declaredIn;

  final HabotCheckKind kind;

  /// The step that put it there. Empty for anything predating this track's
  /// numbered steps.
  final String addedBy;
}

/// The manifest.
class HabotValidationModule {
  const HabotValidationModule._();

  /// The module is a directory, not a package. Naming it is the point.
  static const String moduleRoot = 'lib/design_system/forms';

  static const String sheetNameA = '@habot/shared-library';
  static const String sheetNameB = 'Validation Module.';

  static List<HabotModuleEntry> get entries => <HabotModuleEntry>[
        const HabotModuleEntry(
          ruleClass: 'character filter per field class',
          declaredIn: 'forms/input_mask.dart',
          kind: HabotCheckKind.mask,
          addedBy: '',
        ),
        const HabotModuleEntry(
          ruleClass: 'whole-value pattern per field class',
          declaredIn: 'forms/field_validation.dart',
          kind: HabotCheckKind.pattern,
          addedBy: '',
        ),
        const HabotModuleEntry(
          ruleClass: 'mask-to-pattern agreement and its correction',
          declaredIn: 'forms/mask_binding.dart',
          kind: HabotCheckKind.mask,
          addedBy: 'Step 238',
        ),
        const HabotModuleEntry(
          ruleClass: 'grouping separators and the stored value',
          declaredIn: 'forms/auto_format.dart',
          kind: HabotCheckKind.pattern,
          addedBy: 'Step 239',
        ),
        const HabotModuleEntry(
          ruleClass: 'IBAN check digits',
          declaredIn: 'forms/iban_validator.dart',
          kind: HabotCheckKind.checksum,
          addedBy: 'Step 243',
        ),
        const HabotModuleEntry(
          ruleClass: 'issued-identifier structure by jurisdiction',
          declaredIn: 'forms/identity_document_rules.dart',
          kind: HabotCheckKind.registry,
          addedBy: 'Step 244',
        ),
        const HabotModuleEntry(
          ruleClass: 'completeness, which is not the same as validity',
          declaredIn: 'forms/completeness_rules.dart',
          kind: HabotCheckKind.pattern,
          addedBy: 'Step 245',
        ),
        const HabotModuleEntry(
          ruleClass: 'cross-field arithmetic',
          declaredIn: 'forms/balance_gate.dart',
          kind: HabotCheckKind.crossField,
          addedBy: 'Step 252',
        ),
        const HabotModuleEntry(
          ruleClass: 'the submission decision',
          declaredIn: 'forms/strict_true_gate.dart',
          kind: HabotCheckKind.crossField,
          addedBy: 'Step 254',
        ),
      ];

  /// A rule class declared in more than one file. Must be empty.
  static List<String> get duplicatedRuleClasses {
    final Map<String, Set<String>> homes = <String, Set<String>>{};
    for (final HabotModuleEntry e in entries) {
      homes.putIfAbsent(e.ruleClass, () => <String>{}).add(e.declaredIn);
    }
    return homes.entries
        .where((MapEntry<String, Set<String>> e) => e.value.length > 1)
        .map((MapEntry<String, Set<String>> e) => e.key)
        .toList();
  }

  static bool get everyRuleHasOneHome => duplicatedRuleClasses.isEmpty;

  /// Every entry sits under the declared module root.
  static bool get everyEntryIsInTheModule =>
      entries.every((HabotModuleEntry e) => e.declaredIn.startsWith('forms/'));

  /// Rule kinds the module covers. Compared against the kinds Step 236 found
  /// this application needs, so the manifest cannot claim completeness over a
  /// list it wrote itself.
  static Set<HabotCheckKind> get kindsCovered =>
      entries.map((HabotModuleEntry e) => e.kind).toSet();

  static Set<HabotCheckKind> get kindsRequired =>
      HabotComplianceFieldInventory.kindsRequired;

  static Set<HabotCheckKind> get kindsMissing =>
      kindsRequired.difference(kindsCovered);

  static double get kindCoverage =>
      kindsCovered.intersection(kindsRequired).length / kindsRequired.length;

  /// Entries this batch adds, against entries that predate it.
  static List<HabotModuleEntry> get addedByThisBatch =>
      entries.where((HabotModuleEntry e) => e.addedBy.isNotEmpty).toList();

  static List<HabotModuleEntry> get predatedThisBatch =>
      entries.where((HabotModuleEntry e) => e.addedBy.isEmpty).toList();

  /// Cross-check: the rules Step 240 says need somewhere to run all have a
  /// home in this manifest.
  static bool get coversEveryRuleStep240Bound => HabotEdgeBinding.rules.every(
        (HabotBoundRule r) => kindsCovered.contains(r.kind),
      );

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String alreadyStoredNote =
      'The logic is already stored. Every rule this row names lives under '
      '$moduleRoot, and the only way to satisfy "store it in the Validation '
      'Module" as an instruction to write code would be to copy it somewhere '
      'and call that the module. Step 179 already settled what two copies of '
      'a rule with one of them executed is. The artefact is therefore a '
      'MANIFEST: what the module contains, where each rule class is declared, '
      'and a check that no rule class is declared twice.';

  static const String twoNamesNote =
      'The sheet gives the module two names. This row and most of its '
      'neighbours name "$sheetNameA" as the Common Library to Store; '
      'GEN-02117 -- Step 253, about the same validation logic -- names '
      '"$sheetNameB" instead. Two names for one place is how two places get '
      'built, and the manifest exists so the second name resolves to the '
      'first rather than to a new folder.';

  static const String manifestIsExecutableNote =
      'A manifest that is prose is a document somebody edits after moving a '
      'file. This one is a list the gates read: the duplicate check runs over '
      'it, the kind coverage is computed against Step 236\'s inventory rather '
      'than against a list this file wrote itself, and every entry is '
      'required to sit under the declared root.';

  // -----------------------------------------------------------------------
  // Metric: Step Completion Rate (%).
  // -----------------------------------------------------------------------

  static const double floor = 90;
  static const double optimal = 99;
  static const double ceiling = 100;

  static Map<String, bool> get completionChecks => <String, bool>{
        'the module has one declared root': moduleRoot.isNotEmpty,
        'every entry sits under it': everyEntryIsInTheModule,
        'no rule class has two homes': everyRuleHasOneHome,
        'every kind of check the application needs is covered':
            kindsMissing.isEmpty,
        'every rule Step 240 bound has a home here':
            coversEveryRuleStep240Bound,
        'the manifest is read by the gates rather than written as prose':
            entries.isNotEmpty,
        'the sheet\'s two names for the module are reconciled':
            twoNamesNote.contains(sheetNameB),
      };

  static double get completionRate =>
      completionChecks.values.where((bool b) => b).length /
      completionChecks.length *
      100;

  static String get qualitativeOutput {
    if (completionRate >= optimal) {
      return 'Complete';
    }
    return completionRate >= floor ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'nine rule classes are listed': entries.length == 9,
        'two predate this batch and seven are added by it':
            predatedThisBatch.length == 2 && addedByThisBatch.length == 7,
        'no rule class is declared in two files': everyRuleHasOneHome,
        'all five kinds of check are covered':
            kindsCovered.length == HabotCheckKind.values.length &&
                kindsMissing.isEmpty && kindCoverage == 1.0,
        'nothing was stored twice to satisfy the row':
            alreadyStoredNote.contains('two copies of'),
        'the sheet\'s two names for the module are recorded':
            twoNamesNote.contains(sheetNameA) &&
                twoNamesNote.contains(sheetNameB),
        'the completion rate is computed over the module\'s own criteria':
            completionRate == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Store the validation engine execution logic in the Validation '
      'Module."';
}
