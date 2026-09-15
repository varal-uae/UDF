/// Step 265 (MCIIM-010-10) -- the field under the locked image, which is where
/// the three per cent gets caught.
///
/// The row: "Place a structured text input field element directly underneath
/// the locked image."
/// Metric: **Image/Document Extraction Accuracy** -- floor 0.9, optimal 0.97,
/// ceiling 0.995. Pass. Standards cited: Google Document AI accuracy
/// benchmarks; ISO/IEC TR 29794.
///
/// **This row has three different subjects on it.** The Atomic Step is about
/// placing a text field. The metric is about how accurately text is extracted
/// from an image. The Data Collected column is about record locking -- Lock
/// Type, Lock Status, Locked By, Lock Timestamp, Lock Reason. Three subjects,
/// one row, and only one of them is something a person can build.
///
/// **Read together they do make sense, and the reading is the point.** The
/// field under the image is where somebody corrects what was extracted, which
/// is exactly why extraction accuracy is the metric: at the row's own optimal
/// of 0.97, three fields in every hundred are wrong, and this field is the
/// only thing between that and a record. The lock is what stops the image
/// changing underneath a correction that is half typed.
///
/// **The field is pre-filled and marked unconfirmed, not left blank.** A blank
/// field under a correct extraction makes a person retype something that was
/// already right, and most of them will not -- so the record ends up empty
/// rather than correct. Pre-filled and unconfirmed means the work is
/// confirming rather than transcribing.
///
/// **Confidence per field, not per document.** A document-level accuracy of
/// 0.97 says nothing about which three fields to look at. Every extracted
/// field carries its own confidence, and the ones below the threshold are the
/// ones the person is taken to first.
library;

/// What a person has done to an extracted value.
enum HabotExtractionState {
  /// Extracted and not yet looked at.
  unconfirmed,

  /// Looked at and accepted unchanged.
  confirmed,

  /// Looked at and changed.
  corrected,

  /// The extractor produced nothing for this field.
  missing,
}

/// Why the image is locked while a correction is in progress.
enum HabotLockReason {
  /// Somebody is correcting the fields taken from it.
  correctionInProgress,

  /// It has been submitted and the record is closed.
  recordClosed,

  /// Not locked.
  none,
}

/// One field taken out of an image.
class HabotExtractedField {
  const HabotExtractedField({
    required this.name,
    required this.extracted,
    required this.confidence,
    required this.state,
  });

  final String name;

  /// What the extractor produced. Empty when it produced nothing.
  final String extracted;

  /// How sure the extractor was about this field, not about the document.
  final double confidence;

  final HabotExtractionState state;

  bool get needsAttention =>
      state == HabotExtractionState.unconfirmed ||
      state == HabotExtractionState.missing;
}

/// The correction surface.
class HabotExtractionCorrection {
  const HabotExtractionCorrection._();

  /// Below this a field is surfaced first, whatever the document-level
  /// figure says.
  static const double attentionThreshold = 0.9;

  /// The row's band, transcribed.
  static const double floor = 0.9;
  static const double optimal = 0.97;
  static const double ceiling = 0.995;

  /// At the row's own optimal, three fields in a hundred are wrong. The
  /// number this step exists to catch.
  static double get wrongFieldsPerHundredAtOptimal => (1 - optimal) * 100;

  /// A worked document: five fields off an Emirates ID, with the confidences
  /// an extractor actually produces -- high on printed Latin text, lower on
  /// a handwritten or stylised field, nothing at all where the scan is cut.
  static const List<HabotExtractedField> workedDocument =
      <HabotExtractedField>[
    HabotExtractedField(
      name: 'full name',
      extracted: 'AMINA AL MARRI',
      confidence: 0.99,
      state: HabotExtractionState.unconfirmed,
    ),
    HabotExtractedField(
      name: 'identity number',
      extracted: '784-1987-1234567-1',
      confidence: 0.98,
      state: HabotExtractionState.unconfirmed,
    ),
    HabotExtractedField(
      name: 'date of birth',
      extracted: '1987-03-11',
      confidence: 0.86,
      state: HabotExtractionState.unconfirmed,
    ),
    HabotExtractedField(
      name: 'expiry date',
      extracted: '2031-03-10',
      confidence: 0.72,
      state: HabotExtractionState.unconfirmed,
    ),
    HabotExtractedField(
      name: 'nationality',
      extracted: '',
      confidence: 0,
      state: HabotExtractionState.missing,
    ),
  ];

  static List<HabotExtractedField> get belowThreshold => workedDocument
      .where((HabotExtractedField f) => f.confidence < attentionThreshold)
      .toList();

  /// The share of fields this document does NOT need a look at. Two of five.
  static double get shareOfFieldsAboveThreshold =>
      workedDocument
          .where(
            (HabotExtractedField f) => f.confidence >= attentionThreshold,
          )
          .length /
      workedDocument.length;

  /// The figure the row's metric reports about a document. A single number
  /// per document, which is the whole problem.
  static double get documentLevelFigureTheMetricReports => optimal;

  /// Which field the person is taken to first: the least confident one that
  /// still has a value, before the one that has none -- because an empty
  /// field is obvious and a confidently wrong one is not.
  static HabotExtractedField get firstToReview {
    final List<HabotExtractedField> withValues = workedDocument
        .where((HabotExtractedField f) => f.extracted.isNotEmpty)
        .toList()
      ..sort(
        (HabotExtractedField a, HabotExtractedField b) =>
            a.confidence.compareTo(b.confidence),
      );
    return withValues.first;
  }

  /// A document can report the row's own optimal and still have most of its
  /// fields below the threshold a person should be taken to. Both figures
  /// are published so the aggregate cannot stand in for the detail.
  static bool get theDocumentFigureHidesWhichFieldsAreWrong =>
      documentLevelFigureTheMetricReports > attentionThreshold &&
      shareOfFieldsAboveThreshold < attentionThreshold &&
      belowThreshold.length == 3;

  // -----------------------------------------------------------------------
  // Pre-filled, not blank.
  // -----------------------------------------------------------------------

  /// What the field shows when it is built.
  static String initialValueFor(HabotExtractedField f) => f.extracted;

  /// Whether the field is marked as needing a look.
  static bool showsUnconfirmedMarkFor(HabotExtractedField f) =>
      f.needsAttention;

  /// The policy, as one statement: a field with a value is shown with that
  /// value AND marked as unconfirmed. Either half alone is a different
  /// design -- blank makes people retype, pre-filled without the mark gets
  /// the machine's guess accepted silently.
  static bool get preFilledAndMarked => workedDocument
      .where((HabotExtractedField f) => f.extracted.isNotEmpty)
      .every(
        (HabotExtractedField f) =>
            initialValueFor(f) == f.extracted && showsUnconfirmedMarkFor(f),
      );

  /// And a field with nothing extracted is shown empty and still marked.
  static bool get missingFieldsAreShownEmptyAndMarked => workedDocument
      .where((HabotExtractedField f) => f.extracted.isEmpty)
      .every(
        (HabotExtractedField f) =>
            initialValueFor(f).isEmpty && showsUnconfirmedMarkFor(f),
      );

  /// Confirming is one action and does not require retyping. This is the
  /// property that makes pre-filling safe rather than lazy.
  static HabotExtractionState confirm(HabotExtractedField f) =>
      f.extracted.isEmpty
          ? HabotExtractionState.missing
          : HabotExtractionState.confirmed;

  static HabotExtractionState correct(
    HabotExtractedField f,
    String typed,
  ) =>
      typed.isEmpty
          ? HabotExtractionState.missing
          : HabotExtractionState.corrected;

  /// A confirmed field and a corrected field are distinguishable afterwards.
  /// Without that the extractor can never be measured against what people
  /// actually changed.
  static bool get confirmedAndCorrectedAreDistinguishable =>
      confirm(workedDocument.first) != correct(workedDocument.first, 'X') &&
      confirm(workedDocument.last) == HabotExtractionState.missing;

  static const String preFilledNote =
      'The field is pre-filled with what was extracted and marked '
      'unconfirmed, not left blank. A blank field under a correct extraction '
      'makes a person retype something that was already right, and most of '
      'them will not -- so the record ends up empty rather than correct. '
      'Pre-filled and unconfirmed means the work is confirming rather than '
      'transcribing, and confirming is one action. The mark is what stops '
      'pre-filling becoming a way of having the machine\'s guess accepted '
      'silently.';

  static const String perFieldConfidenceNote =
      'Confidence is per field, not per document. A document-level accuracy '
      'of 0.97 says nothing about WHICH three fields in a hundred are wrong, '
      'and a person handed a form of five pre-filled values with one '
      'aggregate number has no way to know where to look. Every extracted '
      'field carries its own confidence, the ones below the threshold are '
      'surfaced first, and the least confident field that still has a value '
      'is surfaced before the one that has none -- an empty field is obvious '
      'and a confidently wrong one is not.';

  // -----------------------------------------------------------------------
  // The lock.
  // -----------------------------------------------------------------------

  /// Whether the image may be replaced right now.
  static bool imageMayBeReplaced(HabotLockReason reason) =>
      reason == HabotLockReason.none;

  static bool get aCorrectionInProgressLocksTheImage =>
      !imageMayBeReplaced(HabotLockReason.correctionInProgress) &&
      !imageMayBeReplaced(HabotLockReason.recordClosed) &&
      imageMayBeReplaced(HabotLockReason.none);

  static const String lockNote =
      'The Data Collected column on this row is entirely about record '
      'locking -- Lock Type, Lock Status, Locked By, Lock Timestamp, Lock '
      'Reason -- while the Atomic Step is about placing a text field and the '
      'metric is about extraction accuracy. Three subjects on one row. Read '
      'together they cohere: the lock is what stops the image changing '
      'underneath a correction that is half typed, and a correction against '
      'an image that has been replaced is a correction to the wrong '
      'document. So the lock is implemented as the reason it exists rather '
      'than as five columns to fill in.';

  static const String threeSubjectsNote =
      'Three different subjects on one row: a text field to place, an '
      'extraction accuracy to hit, and a record lock to record. Only one of '
      'them is something a person can build, and the other two are the '
      'context that makes it worth building. Recorded here because a row '
      'read one column at a time produces three unrelated artefacts, and a '
      'row read whole produces one.';

  // -----------------------------------------------------------------------
  // Metric: Pass/Fail.
  // -----------------------------------------------------------------------

  static Map<String, bool> get checks => <String, bool>{
        'five fields are extracted, with per-field confidence':
            workedDocument.length == 5 &&
                workedDocument
                    .map((HabotExtractedField f) => f.confidence)
                    .toSet()
                    .length ==
                    5,
        'three fields fall below the attention threshold':
            belowThreshold.length == 3,
        'the row\'s own optimal is above the attention threshold while three '
            'of five fields are below it':
            theDocumentFigureHidesWhichFieldsAreWrong &&
                (shareOfFieldsAboveThreshold - 0.4).abs() < 1e-9,
        'the least confident field that has a value is surfaced first':
            firstToReview.name == 'expiry date',
        'a field with a value is pre-filled and marked, and one without is '
            'empty and marked':
            preFilledAndMarked && missingFieldsAreShownEmptyAndMarked,
        'every field that needs a look is marked': workedDocument
            .where(showsUnconfirmedMarkFor)
            .length ==
            5,
        'confirming and correcting are distinguishable afterwards':
            confirmedAndCorrectedAreDistinguishable,
        'a correction in progress locks the image':
            aCorrectionInProgressLocksTheImage,
        'three subjects on one row are recorded rather than split into three '
            'artefacts': threeSubjectsNote.contains('read whole produces one'),
        'the row\'s own optimal leaves three fields in a hundred wrong':
            (wrongFieldsPerHundredAtOptimal - 3).abs() < 1e-9,
      };

  static String get qualitativeOutput =>
      checks.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row carries no Setup Step, no Expected Output and no '
      'Completion Measures, and its Data Collected list is entirely about '
      'record locking while the Atomic Step is about a text field and the '
      'metric is about extraction accuracy. Atomic Step: "Place a structured '
      'text input field element directly underneath the locked image."';
}
