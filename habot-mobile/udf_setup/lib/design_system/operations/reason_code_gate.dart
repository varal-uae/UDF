/// Step 213 (GEN-01562) -- the mandatory reason code in front of a rejection.
///
/// The row: "Program a mandatory reason-code drop-down gate that requires input
/// before an order rejection can be submitted."
/// Metric: Fraud Detection False-Positive Rate -- <5% / <1% / <10%.
///
/// **A drop-down with a selected first item is not mandatory.** This is the
/// commonest way the requirement gets implemented and silently fails: the
/// control shows a value, the validation sees a value, and the reviewer never
/// touched it. Every rejection then carries whichever code happens to sort
/// first, and the code that sorts first becomes 60% of the rejection data.
/// The selection here starts as null and null is not a code.
///
/// **The codes are what the metric is made of.** A false-positive rate is not
/// one number; it is computed by grouping rejections by reason and finding
/// which reasons turn out to have been wrong. That makes the code list a
/// measurement instrument, and two properties follow: it must be closed and
/// versioned, because a code added mid-quarter splits a series; and the share
/// of rejections landing on "Other" has to be watched, because a catch-all
/// absorbing a third of the volume makes every group under-counted by an
/// unknown amount.
///
/// **"Other" needs its text or it is not a code.** A free-text requirement
/// behind the catch-all is the only thing that stops it being the fast path.
library;

/// The kind of thing a reason code is about. Used for grouping, so a new code
/// joins an existing series rather than starting its own.
enum HabotReasonFamily {
  /// Something about the payment instrument.
  payment,

  /// Something about the account or its history.
  account,

  /// Something about the order itself.
  order,

  /// Something about the service or the operator's capacity.
  operational,

  /// None of the above.
  other,
}

/// One reason code.
class HabotReasonCode {
  const HabotReasonCode({
    required this.code,
    required this.label,
    required this.family,
    required this.requiresFreeText,
    required this.sinceVersion,
    this.retiredInVersion,
  });

  /// Stable identifier. Never reused, never renamed -- a renamed code breaks
  /// every historical series that grouped on it.
  final String code;

  /// What the reviewer reads.
  final String label;

  final HabotReasonFamily family;

  /// Whether selecting this code also demands typed detail.
  final bool requiresFreeText;

  /// The list version this code appeared in.
  final int sinceVersion;

  /// The version it stopped being offered in. Retired rather than deleted, so
  /// old rejections still resolve to a label.
  final int? retiredInVersion;

  bool isOfferedIn(int version) =>
      sinceVersion <= version &&
      (retiredInVersion == null || retiredInVersion! > version);
}

/// The state of the gate in front of a rejection.
class HabotReasonSelection {
  const HabotReasonSelection({this.code, this.detail = ''});

  /// Null until the reviewer chooses. Null is not a code.
  final HabotReasonCode? code;

  /// Free text, where the code demands it.
  final String detail;

  bool get hasCode => code != null;
}

/// The gate.
class HabotReasonCodeGate {
  const HabotReasonCodeGate._();

  /// The current list version.
  static const int listVersion = 3;

  /// Minimum characters of detail behind a code that requires it. Short enough
  /// to be reasonable during a queue, long enough that "x" does not pass.
  static const int minimumDetailLength = 12;

  /// The closed list.
  static const List<HabotReasonCode> codes = <HabotReasonCode>[
    HabotReasonCode(
      code: 'PAY_AVS_MISMATCH',
      label: 'Billing address does not match',
      family: HabotReasonFamily.payment,
      requiresFreeText: false,
      sinceVersion: 1,
    ),
    HabotReasonCode(
      code: 'PAY_ISSUER_DECLINE',
      label: 'Issuer declined',
      family: HabotReasonFamily.payment,
      requiresFreeText: false,
      sinceVersion: 1,
    ),
    HabotReasonCode(
      code: 'ACC_NEW_HIGH_VALUE',
      label: 'New account, high-value first order',
      family: HabotReasonFamily.account,
      requiresFreeText: false,
      sinceVersion: 1,
    ),
    HabotReasonCode(
      code: 'ACC_PRIOR_CHARGEBACK',
      label: 'Prior chargeback on this account',
      family: HabotReasonFamily.account,
      requiresFreeText: false,
      sinceVersion: 1,
    ),
    HabotReasonCode(
      code: 'ORD_DETAILS_INCONSISTENT',
      label: 'Order details inconsistent',
      family: HabotReasonFamily.order,
      requiresFreeText: true,
      sinceVersion: 2,
    ),
    HabotReasonCode(
      code: 'OPS_CAPACITY',
      label: 'Cannot be fulfilled',
      family: HabotReasonFamily.operational,
      requiresFreeText: false,
      sinceVersion: 2,
    ),
    HabotReasonCode(
      code: 'ACC_VELOCITY',
      label: 'Unusual ordering velocity',
      family: HabotReasonFamily.account,
      requiresFreeText: false,
      sinceVersion: 1,
      retiredInVersion: 3,
    ),
    HabotReasonCode(
      code: 'OTHER',
      label: 'Other',
      family: HabotReasonFamily.other,
      requiresFreeText: true,
      sinceVersion: 1,
    ),
  ];

  /// What the drop-down offers now.
  static List<HabotReasonCode> offered({int version = listVersion}) =>
      codes.where((HabotReasonCode c) => c.isOfferedIn(version)).toList();

  /// What a historical rejection resolves to, including retired codes.
  static HabotReasonCode? resolve(String code) {
    for (final HabotReasonCode c in codes) {
      if (c.code == code) {
        return c;
      }
    }
    return null;
  }

  /// A retired code still resolves. Deleting it would leave old rejections
  /// pointing at nothing, which is how a series becomes uncountable.
  static bool get retiredCodesStillResolve =>
      resolve('ACC_VELOCITY') != null &&
      !resolve('ACC_VELOCITY')!.isOfferedIn(listVersion);

  /// Nothing is selected until the reviewer selects it.
  static const HabotReasonSelection initialSelection = HabotReasonSelection();

  static bool get initialSelectionIsEmpty => !initialSelection.hasCode;

  /// The gate itself.
  static bool maySubmit(HabotReasonSelection selection) {
    final HabotReasonCode? code = selection.code;
    if (code == null) {
      return false;
    }
    if (!code.isOfferedIn(listVersion)) {
      return false;
    }
    if (code.requiresFreeText) {
      return selection.detail.trim().length >= minimumDetailLength;
    }
    return true;
  }

  /// Why submit is blocked, for the reviewer.
  static String blockReason(HabotReasonSelection selection) {
    if (!selection.hasCode) {
      return 'Choose a reason before rejecting this order.';
    }
    if (selection.code!.requiresFreeText &&
        selection.detail.trim().length < minimumDetailLength) {
      return 'Add at least $minimumDetailLength characters of detail.';
    }
    return '';
  }

  /// The gate blocks rather than warns after the fact.
  static const bool blocksSubmission = true;

  /// What a drop-down whose first item is pre-selected would submit with: the
  /// first offered code, carrying it into the data as though it were chosen.
  static HabotReasonCode get codeANaiveDropDownWouldSubmit =>
      offered().first;

  // -----------------------------------------------------------------------
  // The code list as a measurement instrument.
  // -----------------------------------------------------------------------

  /// Share of rejections that landed on the catch-all.
  static double otherShare(Map<String, int> rejectionsByCode) {
    final int total = rejectionsByCode.values.fold(0, (int a, int b) => a + b);
    if (total == 0) {
      return 0;
    }
    return (rejectionsByCode['OTHER'] ?? 0) / total;
  }

  /// Above this, the catch-all is absorbing enough volume that every other
  /// group is under-counted by an unknown amount and the list needs work.
  static const double otherShareCeiling = 0.15;

  static bool catchAllIsHealthy(Map<String, int> rejectionsByCode) =>
      otherShare(rejectionsByCode) <= otherShareCeiling;

  /// Grouped counts, which is the form the false-positive rate is computed in.
  static Map<HabotReasonFamily, int> byFamily(
    Map<String, int> rejectionsByCode,
  ) {
    final Map<HabotReasonFamily, int> out = <HabotReasonFamily, int>{
      for (final HabotReasonFamily f in HabotReasonFamily.values) f: 0,
    };
    rejectionsByCode.forEach((String code, int n) {
      final HabotReasonCode? c = resolve(code);
      if (c != null) {
        out[c.family] = out[c.family]! + n;
      }
    });
    return out;
  }

  static bool get codesAreUnique =>
      codes.map((HabotReasonCode c) => c.code).toSet().length == codes.length;

  static bool get everyFamilyHasACode => HabotReasonFamily.values.every(
        (HabotReasonFamily f) =>
            codes.any((HabotReasonCode c) => c.family == f),
      );

  // -----------------------------------------------------------------------
  // Metric: Fraud Detection False-Positive Rate. <5% / <1% / <10%.
  // -----------------------------------------------------------------------

  static const double floorRate = 0.05;
  static const double optimalRate = 0.01;
  static const double ceilingRate = 0.10;
  static const bool lowerIsBetter = true;

  static String qualitativeOutput(double rate) {
    if (rate < optimalRate) {
      return 'Good';
    }
    if (rate < floorRate) {
      return 'Average';
    }
    return 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'nothing is selected until the reviewer selects it':
            initialSelectionIsEmpty && !maySubmit(initialSelection),
        'the gate blocks submission rather than warning afterwards':
            blocksSubmission,
        'the catch-all requires typed detail':
            resolve('OTHER')!.requiresFreeText &&
                !maySubmit(
                  HabotReasonSelection(code: resolve('OTHER'), detail: 'x'),
                ),
        'a code with enough detail submits': maySubmit(
          HabotReasonSelection(
            code: resolve('OTHER'),
            detail: 'Duplicate of order 4471',
          ),
        ),
        'a retired code cannot be chosen now': !maySubmit(
          HabotReasonSelection(code: resolve('ACC_VELOCITY')),
        ),
        'a retired code still resolves for historical rejections':
            retiredCodesStillResolve,
        'codes are unique': codesAreUnique,
        'every family has at least one code': everyFamilyHasACode,
        'the catch-all share is watched rather than assumed':
            !catchAllIsHealthy(
                  <String, int>{'OTHER': 40, 'OPS_CAPACITY': 60},
                ) &&
                catchAllIsHealthy(
                  <String, int>{'OTHER': 5, 'OPS_CAPACITY': 95},
                ),
      };

  static double get adherence =>
      checks.values.where((bool b) => b).length / checks.length;

  static const String preselectedIsNotMandatoryNote =
      'A drop-down showing a value satisfies every validation that checks for '
      'a value, and the reviewer never touched it. Every rejection then '
      'carries whichever code sorts first, and that code becomes the majority '
      'of the rejection data. The selection starts as null and null is not a '
      'code.';

  static const String codesAreTheInstrumentNote =
      'A false-positive rate is computed by grouping rejections by reason and '
      'finding which reasons turned out to be wrong. That makes this list a '
      'measurement instrument: closed, versioned, codes never renamed or '
      'reused, retired rather than deleted. A code added mid-quarter splits a '
      'series and nothing in the data says so.';

  static const String catchAllNote =
      'A catch-all absorbing a third of rejections makes every other group '
      'under-counted by an unknown amount, and the rate computed from them is '
      'confident and wrong. The Other share is watched against a declared '
      'ceiling, and the catch-all demands typed detail so it is not the fast '
      'path out of the gate.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Program a mandatory reason-code drop-down gate that requires input '
      'before an order rejection can be submitted."';
}
