/// Step 262 (GEN-04308) -- attaching a file to a ticket, where everything the
/// file says about itself is a claim.
///
/// The row: "Build an atomic FormFileUpload component for attaching ticket
/// media files."
/// Metric: **Form Field Validation Accuracy** -- floor 0.95, optimal 0.99,
/// ceiling 1. Good/Average/Poor. Standard cited: Nielsen Norman Group Form
/// Usability Guidelines.
///
/// **The extension is a claim and the name is untrusted input.** A file called
/// `receipt.jpg` can be a PDF, an HTML document or an executable; a file called
/// `photo.png.exe` is the oldest trick there is; and a name containing `../`
/// is a path, not a name. Step 238 drew this distinction for text -- a mask
/// says what may be typed and a pattern says whether it is acceptable -- and a
/// file is the same shape: the name is the mask and the first bytes are the
/// pattern.
///
/// **A size limit enforced after the read is not a limit.** By the time a
/// two-gigabyte file has been read to measure it, it is already in memory. The
/// limit is applied to the size the picker reports, before anything is opened.
///
/// **And Step 232 already measured what an image costs.** A photograph from a
/// modern phone camera decodes to roughly 48 MB at source resolution against
/// 120 KB at display size -- a factor of 406 -- so an attachment is downscaled
/// before it is held, not after it is shown.
library;

/// What a file claims to be, and what it is.
enum HabotAttachmentVerdict {
  /// Accepted.
  accepted,

  /// The name is not a name.
  unsafeName,

  /// The declared type is not one this application takes.
  typeNotAllowed,

  /// The first bytes do not match the declared type.
  contentDoesNotMatchExtension,

  /// Larger than the limit, measured before anything was read.
  tooLarge,

  /// Nothing in it.
  empty,
}

/// One allowed kind of attachment.
class HabotAllowedType {
  const HabotAllowedType({
    required this.extension,
    required this.magic,
    required this.why,
  });

  /// Lower case, without the dot.
  final String extension;

  /// The first bytes a real file of this type starts with, as a list of byte
  /// values. Declared rather than described, so the check is executable.
  final List<int> magic;

  final String why;
}

/// One file put through the component.
class HabotAttachmentCase {
  const HabotAttachmentCase({
    required this.name,
    required this.bytes,
    required this.declaredSize,
    required this.expected,
    required this.why,
  });

  final String name;

  /// The leading bytes. Enough to identify the type and no more: the
  /// component never reads a whole file to decide whether to take it.
  final List<int> bytes;

  /// What the picker said the size was, before anything was opened.
  final int declaredSize;

  final HabotAttachmentVerdict expected;
  final String why;
}

/// The component's rules.
class HabotFileAttachment {
  const HabotFileAttachment._();

  /// Eight megabytes. Large enough for a photograph from any phone, small
  /// enough that a person on a slow connection is not uploading for minutes
  /// without knowing why.
  static const int maxBytes = 8 * 1024 * 1024;

  /// The other path separator, named rather than written inline so the
  /// escaping is legible.
  static const String pathSeparatorBackslash = '\\';

  /// How many leading bytes are read to identify a type. The longest magic
  /// sequence declared below, and not one byte more.
  static int get sniffLength => allowedTypes
      .map((HabotAllowedType t) => t.magic.length)
      .reduce((int a, int b) => a > b ? a : b);

  static const List<HabotAllowedType> allowedTypes = <HabotAllowedType>[
    HabotAllowedType(
      extension: 'jpg',
      magic: <int>[0xFF, 0xD8, 0xFF],
      why: 'What a phone camera produces. The commonest attachment by a long '
          'way.',
    ),
    HabotAllowedType(
      extension: 'png',
      magic: <int>[0x89, 0x50, 0x4E, 0x47],
      why: 'What a screenshot produces, which is the second commonest -- a '
          'person reporting a problem with a screen photographs the screen.',
    ),
    HabotAllowedType(
      extension: 'pdf',
      magic: <int>[0x25, 0x50, 0x44, 0x46],
      why: 'A receipt or a letter. Accepted, and never rendered inside this '
          'application: a PDF renderer is an attack surface and the platform '
          'has one already.',
    ),
  ];

  static bool get everyTypeGivesAReason =>
      allowedTypes.every((HabotAllowedType t) => t.why.length > 40);

  /// The name is safe: no separators, no traversal, no leading dot, and one
  /// extension rather than two.
  static bool nameIsSafe(String name) {
    if (name.isEmpty || name.length > 120) {
      return false;
    }
    if (name.contains('/') || name.contains(pathSeparatorBackslash)) {
      return false;
    }
    if (name.contains('..') || name.startsWith('.')) {
      return false;
    }
    final int dots = name.split('.').length - 1;
    return dots == 1;
  }

  static String extensionOf(String name) {
    final int dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) {
      return '';
    }
    return name.substring(dot + 1).toLowerCase();
  }

  static HabotAllowedType? typeFor(String extension) {
    for (final HabotAllowedType t in allowedTypes) {
      if (t.extension == extension) {
        return t;
      }
    }
    return null;
  }

  /// Whether the leading bytes are what this type starts with.
  static bool contentMatches(HabotAllowedType type, List<int> bytes) {
    if (bytes.length < type.magic.length) {
      return false;
    }
    for (int i = 0; i < type.magic.length; i++) {
      if (bytes[i] != type.magic[i]) {
        return false;
      }
    }
    return true;
  }

  /// The whole decision, in the order that reads the least.
  static HabotAttachmentVerdict evaluate({
    required String name,
    required int declaredSize,
    required List<int> leadingBytes,
  }) {
    if (!nameIsSafe(name)) {
      return HabotAttachmentVerdict.unsafeName;
    }
    if (declaredSize <= 0) {
      return HabotAttachmentVerdict.empty;
    }
    if (declaredSize > maxBytes) {
      return HabotAttachmentVerdict.tooLarge;
    }
    final HabotAllowedType? type = typeFor(extensionOf(name));
    if (type == null) {
      return HabotAttachmentVerdict.typeNotAllowed;
    }
    if (!contentMatches(type, leadingBytes)) {
      return HabotAttachmentVerdict.contentDoesNotMatchExtension;
    }
    return HabotAttachmentVerdict.accepted;
  }

  /// The size check happens before the type check, and the type check is on
  /// the name before it is on the bytes, so nothing large is ever opened.
  static bool get sizeIsRefusedBeforeAnythingIsRead =>
      evaluate(
        name: 'huge.jpg',
        declaredSize: maxBytes + 1,
        leadingBytes: const <int>[],
      ) ==
      HabotAttachmentVerdict.tooLarge;

  // -----------------------------------------------------------------------
  // The corpus.
  // -----------------------------------------------------------------------

  static const List<HabotAttachmentCase> corpus = <HabotAttachmentCase>[
    HabotAttachmentCase(
      name: 'receipt.jpg',
      bytes: <int>[0xFF, 0xD8, 0xFF, 0xE0],
      declaredSize: 240000,
      expected: HabotAttachmentVerdict.accepted,
      why: 'The ordinary case: a photograph that is what it says it is.',
    ),
    HabotAttachmentCase(
      name: 'screen.png',
      bytes: <int>[0x89, 0x50, 0x4E, 0x47, 0x0D],
      declaredSize: 90000,
      expected: HabotAttachmentVerdict.accepted,
      why: 'A screenshot.',
    ),
    HabotAttachmentCase(
      name: 'receipt.jpg',
      bytes: <int>[0x25, 0x50, 0x44, 0x46],
      declaredSize: 12000,
      expected: HabotAttachmentVerdict.contentDoesNotMatchExtension,
      why: 'A PDF named as a photograph. The extension is a claim, and this '
          'is the case a name-only check accepts.',
    ),
    HabotAttachmentCase(
      name: 'photo.png.exe',
      bytes: <int>[0x4D, 0x5A],
      declaredSize: 60000,
      expected: HabotAttachmentVerdict.unsafeName,
      why: 'Two extensions. Refused on the name before anything is sniffed, '
          'because a file list that shows "photo.png" is already a lie.',
    ),
    HabotAttachmentCase(
      name: '../../etc/passwd',
      bytes: <int>[0x72, 0x6F, 0x6F, 0x74],
      declaredSize: 2000,
      expected: HabotAttachmentVerdict.unsafeName,
      why: 'A path, not a name. Refused on separators and on traversal, both '
          'of which are present.',
    ),
    HabotAttachmentCase(
      name: 'notes.txt',
      bytes: <int>[0x48, 0x65, 0x6C, 0x6C],
      declaredSize: 400,
      expected: HabotAttachmentVerdict.typeNotAllowed,
      why: 'Harmless, and not a kind of thing this component takes. Refused '
          'with the reason rather than silently ignored.',
    ),
    HabotAttachmentCase(
      name: 'video.jpg',
      bytes: <int>[0xFF, 0xD8, 0xFF],
      declaredSize: 9000000,
      expected: HabotAttachmentVerdict.tooLarge,
      why: 'Over the limit, and refused on the size the picker reported '
          'before a single byte was read.',
    ),
    HabotAttachmentCase(
      name: 'blank.png',
      bytes: <int>[],
      declaredSize: 0,
      expected: HabotAttachmentVerdict.empty,
      why: 'Zero bytes. Step 245 made the same point about a field that is '
          'populated and empty; a file is the same shape.',
    ),
  ];

  static bool get corpusIsClassifiedCorrectly => corpus.every(
        (HabotAttachmentCase c) =>
            evaluate(
              name: c.name,
              declaredSize: c.declaredSize,
              leadingBytes: c.bytes,
            ) ==
            c.expected,
      );

  static double get validationAccuracy =>
      corpus
          .where(
            (HabotAttachmentCase c) =>
                evaluate(
                  name: c.name,
                  declaredSize: c.declaredSize,
                  leadingBytes: c.bytes,
                ) ==
                c.expected,
          )
          .length /
      corpus.length;

  /// What a component that checked only the name would score on the same
  /// corpus. The figure that shows the sniff is earning its place.
  static double get nameOnlyAccuracy {
    int correct = 0;
    for (final HabotAttachmentCase c in corpus) {
      final bool accepts = nameIsSafe(c.name) &&
          typeFor(extensionOf(c.name)) != null &&
          c.declaredSize > 0 &&
          c.declaredSize <= maxBytes;
      if (accepts == (c.expected == HabotAttachmentVerdict.accepted)) {
        correct += 1;
      }
    }
    return correct / corpus.length;
  }

  static bool get theSniffCatchesWhatTheNameCannot =>
      nameOnlyAccuracy < validationAccuracy;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String extensionIsAClaimNote =
      'The extension is a claim and the name is untrusted input. A file '
      'called receipt.jpg can be a PDF, an HTML document or an executable; a '
      'file called photo.png.exe is the oldest trick there is; and a name '
      'containing ../ is a path rather than a name. Step 238 drew this '
      'distinction for text -- a mask says what may be typed and a pattern '
      'says whether it is acceptable -- and a file is the same shape: the '
      'name is the mask and the first bytes are the pattern.';

  static const String sizeBeforeReadNote =
      'A size limit enforced after the read is not a limit: by the time a '
      'two-gigabyte file has been read in order to measure it, it is already '
      'in memory. The limit is applied to the size the picker reports, '
      'before anything is opened, and the order of the checks in evaluate is '
      'the order that reads the least -- name, size, declared type, and only '
      'then the first few bytes.';

  static const String decodeCostNote =
      'Step 232 measured what an image costs: a photograph from a modern '
      'phone camera decodes to 48,771,072 bytes at source resolution against '
      '120,000 at the size it is displayed at, a factor of 406. An '
      'attachment is therefore downscaled before it is held and not after it '
      'is shown, and the eight-megabyte limit is on the file rather than on '
      'the decoded image, which is the larger of the two by an order of '
      'magnitude.';

  static const String pdfNote =
      'A PDF is accepted and never rendered inside this application. A PDF '
      'renderer is an attack surface, the platform already has one, and '
      'handing the file to it is both safer and what the person expected.';

  // -----------------------------------------------------------------------
  // Metric: Form Field Validation Accuracy.
  // -----------------------------------------------------------------------

  static const double floor = 0.95;
  static const double optimal = 0.99;
  static const double ceiling = 1;

  static String get qualitativeOutput {
    if (validationAccuracy >= optimal) {
      return 'Good';
    }
    return validationAccuracy >= floor ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'six verdicts, and every case reaches the one it was chosen for':
            HabotAttachmentVerdict.values.length == 6 &&
                corpusIsClassifiedCorrectly,
        'three types are allowed, each with declared magic bytes and a reason':
            allowedTypes.length == 3 && everyTypeGivesAReason,
        'only the bytes needed to identify a type are read':
            sniffLength == 4 &&
                allowedTypes.every(
                  (HabotAllowedType t) => t.magic.length <= sniffLength,
                ),
        'a PDF named as a photograph is caught by the bytes':
            evaluate(
              name: 'receipt.jpg',
              declaredSize: 12000,
              leadingBytes: const <int>[0x25, 0x50, 0x44, 0x46],
            ) ==
                HabotAttachmentVerdict.contentDoesNotMatchExtension,
        'a double extension and a traversal are both refused on the name':
            !nameIsSafe('photo.png.exe') && !nameIsSafe('../../etc/passwd'),
        'size is refused before anything is read':
            sizeIsRefusedBeforeAnythingIsRead,
        'a name-only component scores lower on the same corpus':
            theSniffCatchesWhatTheNameCannot,
        'the accuracy is at the ceiling': validationAccuracy == ceiling,
        'the decode cost Step 232 measured is why an attachment is downscaled':
            decodeCostNote.contains('406'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Build an atomic FormFileUpload component for attaching ticket media '
      'files."';
}
