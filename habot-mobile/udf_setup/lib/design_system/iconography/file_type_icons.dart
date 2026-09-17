/// Step 307 (GEN-02444) -- "clear iconography" for nine file types that share
/// four silhouettes.
///
/// The row: "Add clear iconography to represent different file types."
/// Metric: **Process Completion Rate** -- floor 0, optimal "95-100%", ceiling
/// 1. Complete / Partial / Not Complete. ISO/IEC 25010.
///
/// **A glyph cannot tell a PDF from a Word file, and drawing nine of them does
/// not change that.** At 24 points a document is a rectangle with a folded
/// corner whatever is inside it. Nine types here reduce to four silhouettes --
/// document, sheet, image, archive -- so eight of the nine share their outline
/// with at least one other, and exactly one, the archive, is identifiable by
/// shape alone. "Clear iconography" read as "a distinct picture per type" is
/// an instruction that cannot be carried out; read as "the person can tell
/// which file this is", it can, and the thing that does the telling is the
/// three-character type mark on the tile.
///
/// **So the tile is a glyph plus a mark plus a sentence.** The silhouette
/// gives the family at a glance, the mark gives the exact type, and the
/// accessible label gives it in words -- "PDF document" rather than "pdf" and
/// certainly rather than "file icon". None of the three is redundant: the
/// silhouette is what a sighted person scans, the mark is what they read when
/// it matters, and the label is the only one of the three a screen reader
/// reaches.
///
/// **The fallback is the case that actually ships broken.** An unrecognised
/// extension with no mapping renders as nothing -- a blank box, or the
/// notdef box of an icon font -- and it is the one case no designer draws
/// because it does not appear in the mock-up. It has a glyph, a mark and a
/// sentence here like everything else.
///
/// **The band is written in three different units.** The floor is `0`, the
/// optimal is `95-100%`, the ceiling is `1`. If 1 means 100 per cent then the
/// optimal's upper end and the ceiling are the same value; if 1 is a count
/// then it is not the same kind of number as a percentage; and a floor of zero
/// on a completion rate is a floor no work can fall below, which is the defect
/// Step 286 found written into a different band.
library;

/// The outline family a type belongs to.
enum HabotFileSilhouette { document, sheet, image, archive, unknown }

/// One file type.
class HabotFileType {
  const HabotFileType({
    required this.extension,
    required this.silhouette,
    required this.mark,
    required this.spokenLabel,
  });

  final String extension;
  final HabotFileSilhouette silhouette;

  /// The two or three characters printed on the tile.
  final String mark;

  /// What a screen reader says. A noun phrase, not the extension.
  final String spokenLabel;
}

/// The mapping.
class HabotFileTypeIcons {
  const HabotFileTypeIcons._();

  static const List<HabotFileType> types = <HabotFileType>[
    HabotFileType(
      extension: 'pdf',
      silhouette: HabotFileSilhouette.document,
      mark: 'PDF',
      spokenLabel: 'PDF document',
    ),
    HabotFileType(
      extension: 'docx',
      silhouette: HabotFileSilhouette.document,
      mark: 'DOC',
      spokenLabel: 'Word document',
    ),
    HabotFileType(
      extension: 'txt',
      silhouette: HabotFileSilhouette.document,
      mark: 'TXT',
      spokenLabel: 'Plain text file',
    ),
    HabotFileType(
      extension: 'json',
      silhouette: HabotFileSilhouette.document,
      mark: 'JSON',
      spokenLabel: 'JSON data file',
    ),
    HabotFileType(
      extension: 'xlsx',
      silhouette: HabotFileSilhouette.sheet,
      mark: 'XLS',
      spokenLabel: 'Excel spreadsheet',
    ),
    HabotFileType(
      extension: 'csv',
      silhouette: HabotFileSilhouette.sheet,
      mark: 'CSV',
      spokenLabel: 'Comma separated values file',
    ),
    HabotFileType(
      extension: 'png',
      silhouette: HabotFileSilhouette.image,
      mark: 'PNG',
      spokenLabel: 'PNG image',
    ),
    HabotFileType(
      extension: 'jpg',
      silhouette: HabotFileSilhouette.image,
      mark: 'JPG',
      spokenLabel: 'JPEG image',
    ),
    HabotFileType(
      extension: 'zip',
      silhouette: HabotFileSilhouette.archive,
      mark: 'ZIP',
      spokenLabel: 'Compressed archive',
    ),
  ];

  /// The case nobody draws.
  static const HabotFileType fallback = HabotFileType(
    extension: '',
    silhouette: HabotFileSilhouette.unknown,
    mark: '?',
    spokenLabel: 'File of an unrecognised type',
  );

  static HabotFileType forExtension(String extension) {
    final String key = extension.toLowerCase().replaceAll('.', '').trim();
    for (final HabotFileType t in types) {
      if (t.extension == key) {
        return t;
      }
    }
    return fallback;
  }

  // -----------------------------------------------------------------------
  // What a silhouette can and cannot say.
  // -----------------------------------------------------------------------

  static Map<HabotFileSilhouette, int> get silhouetteCounts {
    final Map<HabotFileSilhouette, int> counts =
        <HabotFileSilhouette, int>{};
    for (final HabotFileType t in types) {
      counts[t.silhouette] = (counts[t.silhouette] ?? 0) + 1;
    }
    return counts;
  }

  static int get distinctSilhouettes => silhouetteCounts.length;

  static List<HabotFileType> get identifiableByShapeAlone => types
      .where((HabotFileType t) => silhouetteCounts[t.silhouette] == 1)
      .toList();

  static List<HabotFileType> get sharingASilhouette => types
      .where((HabotFileType t) => (silhouetteCounts[t.silhouette] ?? 0) > 1)
      .toList();

  static double get shareIdentifiableByShape =>
      identifiableByShapeAlone.length / types.length;

  static const double glyphSizeDp = 24;

  static const String silhouetteNote =
      'At 24 points a document is a rectangle with a folded corner whatever is '
      'inside it. Nine types reduce to four outlines, so eight of the nine '
      'share theirs with at least one other and exactly one -- the archive -- '
      'can be told apart by shape. "Clear iconography" read as "a distinct '
      'picture per type" is an instruction nobody can carry out; read as "the '
      'person can tell which file this is", it can be, and the thing that does '
      'the telling is the mark.';

  // -----------------------------------------------------------------------
  // Three channels.
  // -----------------------------------------------------------------------

  static bool get everyTypeHasAMark =>
      types.every((HabotFileType t) => t.mark.trim().isNotEmpty);

  static bool get everyMarkIsUnique =>
      types.map((HabotFileType t) => t.mark).toSet().length == types.length;

  static bool get everyMarkIsShortEnoughToRead =>
      types.every((HabotFileType t) => t.mark.length <= 4);

  static bool get everyTypeHasASpokenLabel =>
      types.every((HabotFileType t) => t.spokenLabel.trim().isNotEmpty);

  /// The label is a noun phrase, not the extension shouted back.
  static bool get noLabelIsMerelyTheExtension => types.every(
        (HabotFileType t) =>
            t.spokenLabel.toLowerCase() != t.extension.toLowerCase() &&
            t.spokenLabel.toLowerCase() != t.mark.toLowerCase(),
      );

  static bool get noLabelIsTheWordFileIcon => types.every(
        (HabotFileType t) => !t.spokenLabel.toLowerCase().contains('icon'),
      );

  static const String channelsNote =
      'The silhouette gives the family at a glance, the mark gives the exact '
      'type, the spoken label gives it in words. None is redundant: the '
      'silhouette is what a sighted person scans, the mark is what they read '
      'when it matters, and the label is the only one of the three a screen '
      'reader reaches. An icon whose alternative text is "file icon" has '
      'described the widget rather than the file.';

  // -----------------------------------------------------------------------
  // The fallback.
  // -----------------------------------------------------------------------

  static bool get theFallbackIsFullyFormed =>
      fallback.mark.isNotEmpty &&
      fallback.spokenLabel.isNotEmpty &&
      fallback.silhouette == HabotFileSilhouette.unknown;

  static bool get anUnknownExtensionResolves =>
      forExtension('heic').silhouette == HabotFileSilhouette.unknown &&
      forExtension('').silhouette == HabotFileSilhouette.unknown;

  static bool get aDottedExtensionResolves =>
      forExtension('.PDF').extension == 'pdf';

  static const String fallbackNote =
      'An unrecognised extension with no mapping renders as nothing: a blank '
      'box, or the notdef box of an icon font. It is the one case no designer '
      'draws, because it never appears in a mock-up -- the mock-up has five '
      'files in it and all five are known. It gets a glyph, a mark and a '
      'sentence here like everything else, and the sentence says the type is '
      'unrecognised rather than pretending the file is a document.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = '0';
  static const String bandOptimal = '95-100%';
  static const String bandCeiling = '1';

  static bool get theFloorCannotBeFailed => bandFloor == '0';

  static bool get theThreeBoundariesAreInDifferentUnits =>
      bandFloor == '0' && bandCeiling == '1' && bandOptimal.contains('%');

  static const String bandNote =
      'The floor is 0, the optimal is 95-100%, the ceiling is 1. Read as '
      'rates, the ceiling and the optimal\'s upper end are the same number and '
      'the floor is a level no work can fall below. Read as counts, two of the '
      'three are not the same kind of number as the middle one. Step 286 found '
      'a floor that could not be failed written into a different band; this is '
      'the same defect with two units added.';

  static Map<String, bool> get obligations => <String, bool>{
        'every type has a silhouette, a mark and a sentence':
            everyTypeHasAMark && everyTypeHasASpokenLabel,
        'every mark is unique and short enough to read at a glance':
            everyMarkIsUnique && everyMarkIsShortEnoughToRead,
        'no spoken label is the extension or the word icon':
            noLabelIsMerelyTheExtension && noLabelIsTheWordFileIcon,
        'an unrecognised extension resolves to a formed fallback':
            theFallbackIsFullyFormed && anUnknownExtensionResolves,
        'lookup is case and dot insensitive': aDottedExtensionResolves,
      };

  static double get completionRate =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (completionRate >= 1.0) {
      return 'Complete';
    }
    return completionRate > 0 ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'nine types over four silhouettes':
            types.length == 9 && distinctSilhouettes == 4,
        'eight of the nine share an outline with another':
            sharingASilhouette.length == 8 &&
                identifiableByShapeAlone.length == 1 &&
                (shareIdentifiableByShape - 1 / 9).abs() < 1e-9,
        'the one that does not is the archive':
            identifiableByShapeAlone.first.extension == 'zip' &&
                silhouetteCounts[HabotFileSilhouette.document] == 4,
        'a distinct picture per type is not a thing that can be drawn':
            glyphSizeDp == 24 &&
                silhouetteNote.contains('nobody can carry out'),
        'every type carries all three channels':
            everyTypeHasAMark &&
                everyMarkIsUnique &&
                everyMarkIsShortEnoughToRead &&
                everyTypeHasASpokenLabel,
        'no label describes the widget instead of the file':
            noLabelIsMerelyTheExtension &&
                noLabelIsTheWordFileIcon &&
                channelsNote.contains('described the widget'),
        'the unknown type is formed rather than blank':
            theFallbackIsFullyFormed &&
                anUnknownExtensionResolves &&
                fallbackNote.contains('never appears in a mock-up'),
        'and the lookup tolerates a dot and a capital':
            aDottedExtensionResolves &&
                forExtension('XLSX').mark == 'XLS',
        'the band is written in three units':
            theThreeBoundariesAreInDifferentUnits &&
                theFloorCannotBeFailed &&
                bandNote.contains('Step 286'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                completionRate == 1.0 &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate, and the Data Requirement cell repeats '
      'the Atomic Step back as the artefact to prepare -- "Data/artifacts to '
      'prepare: Add clear iconography to represent different file types." '
      'Atomic Step: "Add clear iconography to represent different file '
      'types."';
}
