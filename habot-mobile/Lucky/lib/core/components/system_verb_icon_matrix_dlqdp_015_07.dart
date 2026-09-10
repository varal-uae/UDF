// DLQDP-015-07 — System-Verb Icon Mapping Matrix and strict 24x24dp iconography enforcement.
// Provides system-action-only SVG icon mapping, phantom padding hit areas, and vertical margin variables for stacked cards.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SystemVerb {
  create,
  read,
  update,
  delete,
  submit,
  cancel,
  approve,
  reject,
  search,
  filter,
  refresh,
  download,
  upload,
  share,
  settings,
  help,
  close,
  back,
  next,
  previous,
}

class SystemVerbIconSpec {
  const SystemVerbIconSpec({
    required this.assetName,
    required this.assetType,
    required this.assetLocation,
    required this.assetVersion,
    required this.assetSize,
    required this.assetMetadata,
    required this.semanticLabel,
  });

  final String assetName;
  final String assetType;
  final String assetLocation;
  final String assetVersion;
  final double assetSize;
  final String assetMetadata;
  final String semanticLabel;
}

class SystemVerbIconMatrix {
  const SystemVerbIconMatrix._();

  static const double boundingBox = 24.0;
  static const double phantomPadding = 12.0;
  static const double stackedCardVerticalMargin = 8.0;

  static const Map<SystemVerb, SystemVerbIconSpec> matrix = {
    SystemVerb.create: SystemVerbIconSpec(
      assetName: 'system_create',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/create.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Create',
    ),
    SystemVerb.read: SystemVerbIconSpec(
      assetName: 'system_read',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/read.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Read',
    ),
    SystemVerb.update: SystemVerbIconSpec(
      assetName: 'system_update',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/update.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Update',
    ),
    SystemVerb.delete: SystemVerbIconSpec(
      assetName: 'system_delete',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/delete.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Delete',
    ),
    SystemVerb.submit: SystemVerbIconSpec(
      assetName: 'system_submit',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/submit.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Submit',
    ),
    SystemVerb.cancel: SystemVerbIconSpec(
      assetName: 'system_cancel',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/cancel.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Cancel',
    ),
    SystemVerb.approve: SystemVerbIconSpec(
      assetName: 'system_approve',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/approve.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Approve',
    ),
    SystemVerb.reject: SystemVerbIconSpec(
      assetName: 'system_reject',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/reject.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Reject',
    ),
    SystemVerb.search: SystemVerbIconSpec(
      assetName: 'system_search',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/search.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Search',
    ),
    SystemVerb.filter: SystemVerbIconSpec(
      assetName: 'system_filter',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/filter.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Filter',
    ),
    SystemVerb.refresh: SystemVerbIconSpec(
      assetName: 'system_refresh',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/refresh.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Refresh',
    ),
    SystemVerb.download: SystemVerbIconSpec(
      assetName: 'system_download',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/download.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Download',
    ),
    SystemVerb.upload: SystemVerbIconSpec(
      assetName: 'system_upload',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/upload.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Upload',
    ),
    SystemVerb.share: SystemVerbIconSpec(
      assetName: 'system_share',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/share.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Share',
    ),
    SystemVerb.settings: SystemVerbIconSpec(
      assetName: 'system_settings',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/settings.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Settings',
    ),
    SystemVerb.help: SystemVerbIconSpec(
      assetName: 'system_help',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/help.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Help',
    ),
    SystemVerb.close: SystemVerbIconSpec(
      assetName: 'system_close',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/close.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Close',
    ),
    SystemVerb.back: SystemVerbIconSpec(
      assetName: 'system_back',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/back.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Back',
    ),
    SystemVerb.next: SystemVerbIconSpec(
      assetName: 'system_next',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/next.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Next',
    ),
    SystemVerb.previous: SystemVerbIconSpec(
      assetName: 'system_previous',
      assetType: 'svg',
      assetLocation: 'assets/icons/system_verbs/previous.svg',
      assetVersion: '1.0.0',
      assetSize: 24.0,
      assetMetadata: 'geometric machine-action icon',
      semanticLabel: 'Previous',
    ),
  };

  static SystemVerbIconSpec specFor(SystemVerb verb) {
    final spec = matrix[verb];
    if (spec == null) {
      throw StateError('No system verb icon mapping for $verb');
    }
    return spec;
  }
}

class SystemVerbIcon extends StatelessWidget {
  const SystemVerbIcon({
    super.key,
    required this.verb,
    this.phantomPadding = SystemVerbIconMatrix.phantomPadding,
  });

  final SystemVerb verb;
  final double phantomPadding;

  @override
  Widget build(BuildContext context) {
    final spec = SystemVerbIconMatrix.specFor(verb);
    final minHitSize = SystemVerbIconMatrix.boundingBox + (phantomPadding * 2);
    return Semantics(
      label: spec.semanticLabel,
      button: true,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minHitSize,
          minHeight: minHitSize,
        ),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: SizedBox(
          width: SystemVerbIconMatrix.boundingBox,
          height: SystemVerbIconMatrix.boundingBox,
          child: SvgPicture.asset(
            spec.assetLocation,
            width: SystemVerbIconMatrix.boundingBox,
            height: SystemVerbIconMatrix.boundingBox,
            fit: BoxFit.contain,
            semanticsLabel: spec.semanticLabel,
          ),
        ),
      ),
    );
  }
}

class SystemVerbStackedCardSpacer extends StatelessWidget {
  const SystemVerbStackedCardSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: SystemVerbIconMatrix.stackedCardVerticalMargin);
  }
}
