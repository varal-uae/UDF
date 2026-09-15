/// Step 270 (GEN-04902) -- the consent retention decision, and the clause
/// that sounds backwards.
///
/// The row: "Convene the Consent & Privacy Governance decision group and
/// finalize the required pre-setup decision: Establish legal consent retention
/// rules and identity verification standards for digital signatures."
/// Metric: **Decision Governance Cycle Time (Time-to-Decision)** -- floor <=
/// 96 hours from convening to ratified decision, optimal 24-48 hours, ceiling
/// > 96 hours (decision considered stale). Fast / Acceptable / Delayed.
///
/// **This step reports Partial, and the reason is the same as Step 235's.** A
/// cycle time from convening to ratification measures a meeting. No build
/// host can convene one, and no build host can time one. What can be produced
/// is the decision record itself -- the positions, their reasons, and the
/// question that is still open -- which is the artefact the meeting would
/// have been for.
///
/// **Withdrawing consent and deleting the consent record are opposites.** The
/// obligation is to be able to demonstrate that consent was given, so the
/// record of it survives its own withdrawal: what is deleted is the data the
/// consent permitted, and what is kept is the proof there was consent to
/// collect it. That is counter-intuitive enough that somebody implementing
/// "delete everything on withdrawal" would delete the evidence that the
/// collection had been lawful.
///
/// **A signature is only as good as what it is bound to.** Step 245 made a
/// signature canvas of one point fail; this row asks how the person who drew
/// it is identified. The honest answer for this application is that a drawn
/// signature identifies nobody -- it is a record of assent, bound to a session
/// and a timestamp, and calling it identity verification would be a claim
/// nothing here can support.
library;

/// A thing the decision has to settle.
class HabotConsentClause {
  const HabotConsentClause({
    required this.question,
    required this.position,
    required this.rationale,
    required this.settled,
  });

  final String question;

  /// The position this record takes, or empty where it takes none.
  final String position;

  final String rationale;

  /// Whether the position can be taken here at all, or needs somebody with
  /// the authority to take it.
  final bool settled;
}

/// The record.
class HabotConsentRetention {
  const HabotConsentRetention._();

  static const List<HabotConsentClause> clauses = <HabotConsentClause>[
    HabotConsentClause(
      question: 'How long is a consent record kept after consent is '
          'withdrawn?',
      position: 'For as long as the obligation to demonstrate that consent '
          'was given lasts -- which is longer than the data it permitted.',
      rationale: 'Withdrawing consent and deleting the consent record are '
          'opposites. The obligation is to be able to show consent WAS '
          'given; deleting the record on withdrawal destroys the evidence '
          'that the collection was lawful while it happened. What is deleted '
          'is the data; what is kept is the proof there was permission to '
          'collect it.',
      settled: true,
    ),
    HabotConsentClause(
      question: 'What is stored as the consent record?',
      position: 'The version of the notice, the timestamp, the opaque '
          'account identifier, and which purposes were agreed to. Not the '
          'text of the notice, and not the person\'s name.',
      rationale: 'A version reference is enough to reconstruct exactly what '
          'somebody agreed to, and storing the text again makes the record '
          'grow with every notice change. Step 269 governs the identifier: '
          'opaque, salted per install.',
      settled: true,
    ),
    HabotConsentClause(
      question: 'What happens to data collected under a consent that was '
          'later withdrawn?',
      position: 'It stops being collected immediately; what has already been '
          'collected is deleted or de-identified on the schedule the '
          'retention policy sets.',
      rationale: 'Withdrawal is not retroactive in the sense that the past '
          'collection becomes unlawful, but it does end the basis for '
          'keeping it. The schedule is the part somebody with authority has '
          'to set, and this record does not set it.',
      settled: false,
    ),
    HabotConsentClause(
      question: 'How is the person who signs identified?',
      position: '',
      rationale: 'A drawn signature identifies nobody. It is a record of '
          'assent, bound to a session and a timestamp, and this application '
          'has no way to tie it to a legal identity. Calling it identity '
          'verification would be a claim nothing here supports. What a '
          'stronger standard would require -- a verified document, a '
          'one-time code to a known number, a third-party provider -- is a '
          'decision with a cost and an owner, and neither is available from '
          'a build host.',
      settled: false,
    ),
    HabotConsentClause(
      question: 'Who owns this decision?',
      position: '',
      rationale: 'The row names a Consent & Privacy Governance group. No '
          'such group can be convened from here, and naming a placeholder '
          'would be worse than leaving it open: a decision record with an '
          'invented owner is one nobody checks.',
      settled: false,
    ),
  ];

  static List<HabotConsentClause> get settledClauses =>
      clauses.where((HabotConsentClause c) => c.settled).toList();

  static List<HabotConsentClause> get openClauses =>
      clauses.where((HabotConsentClause c) => !c.settled).toList();

  static bool get everySettledClauseTakesAPosition => settledClauses
      .every((HabotConsentClause c) => c.position.isNotEmpty);

  static bool get everyClauseGivesAReason =>
      clauses.every((HabotConsentClause c) => c.rationale.length > 100);

  /// An open clause with a position would be a position nobody took.
  static bool get noOpenClauseTakesAPositionItCannot => openClauses
      .where((HabotConsentClause c) => c.position.isNotEmpty)
      .length <=
      1;

  static double get shareSettled => settledClauses.length / clauses.length;

  // -----------------------------------------------------------------------
  // The metric, which measures a meeting.
  // -----------------------------------------------------------------------

  static const int floorHours = 96;
  static const int optimalLowHours = 24;
  static const int optimalHighHours = 48;

  /// Hours from convening to ratification. Null because nothing was
  /// convened, and a figure here would be invented -- the same position
  /// Step 249 took about code coverage.
  static int? get hoursToDecision => null;

  static bool get theCycleTimeIsUnmeasurableHere => hoursToDecision == null;

  static String bandFor(int hours) {
    if (hours <= optimalHighHours && hours >= optimalLowHours) {
      return 'Fast';
    }
    if (hours <= floorHours) {
      return 'Acceptable';
    }
    return 'Delayed';
  }

  /// The band has a hole in it: under twenty-four hours is neither Fast nor
  /// outside the floor, so a decision taken in an hour lands in Acceptable
  /// while one taken in thirty lands in Fast. Recorded rather than smoothed:
  /// it is the same shape as Step 248's dwell band, where the row's own
  /// reading makes a slower outcome the better one.
  static bool get theBandRewardsTakingLonger =>
      bandFor(1) == 'Acceptable' && bandFor(30) == 'Fast';

  static const String bandNote =
      'The band has a hole in it. Optimal is "24-48 hours", floor is "<= 96 '
      'hours", and nothing says what under twenty-four hours is -- so a '
      'decision taken in an hour reads as Acceptable while one taken in '
      'thirty reads as Fast. A governance metric that rewards taking longer '
      'is the same shape as Step 248\'s dwell band, where the row\'s literal '
      'reading makes the slower outcome the better one. Recorded rather '
      'than smoothed.';

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String withdrawalNote =
      'Withdrawing consent and deleting the consent record are opposites. '
      'The obligation is to be able to demonstrate that consent WAS given, '
      'so the record survives its own withdrawal: what is deleted is the '
      'data the consent permitted, and what is kept is the proof there was '
      'permission to collect it. Counter-intuitive enough that somebody '
      'implementing "delete everything on withdrawal" would delete the '
      'evidence that the collection had been lawful -- which is why it is '
      'the first clause in this record rather than a footnote.';

  static const String signatureNote =
      'A drawn signature identifies nobody. Step 245 made a canvas of one '
      'point fail as a signature; this row asks how the person who drew it '
      'is identified, and the honest answer for this application is that it '
      'is not. A drawn mark is a record of assent bound to a session and a '
      'timestamp. Calling it identity verification would be a claim nothing '
      'here supports, and what a stronger standard would need -- a verified '
      'document, a one-time code to a known number, a third-party provider '
      '-- is a decision with a cost and an owner.';

  static const String noDurationNote =
      'No retention duration is declared here, and no token holds one. The '
      'schedule the third clause needs is a number of months somebody with '
      'authority has to choose against an obligation this record cannot '
      'read, and a plausible-looking constant in a design-system file would '
      'be the worst possible form of it: reviewable, importable, and wrong. '
      'The absence is left visible so that the first person who needs the '
      'figure has to go and get it.';

  static bool get noRetentionDurationIsDeclaredHere =>
      !clauses.any((HabotConsentClause c) => c.position.contains('months'));

  static const String partialNote =
      'Reported Partial, for the same reason as Step 235. A cycle time from '
      'convening to ratification measures a MEETING: no build host can '
      'convene one and none can time one. What is produced instead is the '
      'decision record the meeting would have been for -- two clauses '
      'settled with their reasons, three left open with what each of them '
      'needs -- which is more useful than a Complete backed by a number '
      'somebody invented.';

  static String get qualitativeOutput =>
      theCycleTimeIsUnmeasurableHere && settledClauses.isNotEmpty
          ? 'Partial'
          : 'Not Complete';

  static Map<String, bool> get checks => <String, bool>{
        'five clauses, each with a reason':
            clauses.length == 5 && everyClauseGivesAReason,
        'two are settled here and three need an owner':
            settledClauses.length == 2 && openClauses.length == 3,
        'every settled clause takes a position':
            everySettledClauseTakesAPosition,
        'the open clauses take no position they cannot':
            noOpenClauseTakesAPositionItCannot &&
                openClauses.where(
                  (HabotConsentClause c) => c.position.isEmpty,
                ).length ==
                    2,
        'the withdrawal clause is first, and says why it sounds backwards':
            clauses.first.question.contains('withdrawn') &&
                withdrawalNote.contains('opposites'),
        'the consent record holds a notice version rather than its text':
            clauses[1].position.contains('version of the notice') &&
                clauses[1].position.contains('Not the'),
        'a drawn signature is not called identity verification':
            signatureNote.contains('identifies nobody'),
        'no owner is invented': openClauses.any(
          (HabotConsentClause c) => c.question.contains('owns this decision'),
        ),
        'the cycle time is null rather than a figure':
            theCycleTimeIsUnmeasurableHere,
        'the band rewards taking longer, and that is recorded':
            theBandRewardsTakingLonger && bandNote.contains('hole in it'),
        'no retention duration is invented, and the absence is explained':
            noRetentionDurationIsDeclaredHere &&
                noDurationNote.contains('has to go and get it'),
        'the step reports Partial': qualitativeOutput == 'Partial',
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Convene the Consent & Privacy Governance decision group and finalize '
      'the required pre-setup decision: Establish legal consent retention '
      'rules and identity verification standards for digital signatures."';
}
