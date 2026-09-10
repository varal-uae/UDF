// DLQDP-015-10 — System-Verb Icon Mapping Matrix.
// Enforces strict 24x24dp structural iconography mapped only to system actions, with phantom hit-area padding and SVG-only vector delivery.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SystemVerb {
  create,
  read,
  update,
  delete,
  search,
  filter,
  sort,
  refresh,
  share,
  download,
  upload,
  settings,
  help,
  close,
  back,
  next,
  confirm,
  cancel,
  warning,
  success,
  error,
}

class SystemVerbIconMapping {
  SystemVerbIconMapping._();

  static const double structuralIconSize = 24.0;
  static const double phantomHitAreaSize = 48.0;

  static const Map<SystemVerb, String> _svgAssets = <SystemVerb, String>{
    SystemVerb.create: 'assets/icons/system/verb_create.svg',
    SystemVerb.read: 'assets/icons/system/verb_read.svg',
    SystemVerb.update: 'assets/icons/system/verb_update.svg',
    SystemVerb.delete: 'assets/icons/system/verb_delete.svg',
    SystemVerb.search: 'assets/icons/system/verb_search.svg',
    SystemVerb.filter: 'assets/icons/system/verb_filter.svg',
    SystemVerb.sort: 'assets/icons/system/verb_sort.svg',
    SystemVerb.refresh: 'assets/icons/system/verb_refresh.svg',
    SystemVerb.share: 'assets/icons/system/verb_share.svg',
    SystemVerb.download: 'assets/icons/system/verb_download.svg',
    SystemVerb.upload: 'assets/icons/system/verb_upload.svg',
    SystemVerb.settings: 'assets/icons/system/verb_settings.svg',
    SystemVerb.help: 'assets/icons/system/verb_help.svg',
    SystemVerb.close: 'assets/icons/system/verb_close.svg',
    SystemVerb.back: 'assets/icons/system/verb_back.svg',
    SystemVerb.next: 'assets/icons/system/verb_next.svg',
    SystemVerb.confirm: 'assets/icons/system/verb_confirm.svg',
    SystemVerb.cancel: 'assets/icons/system/verb_cancel.svg',
    SystemVerb.warning: 'assets/icons/system/verb_warning.svg',
    SystemVerb.success: 'assets/icons/system/verb_success.svg',
    SystemVerb.error: 'assets/icons/system/verb_error.svg',
  };

  static const Set<String> _forbiddenHumanCentricTokens = <String>{
    'person',
    'people',
    'human',
    'face',
    'avatar',
    'user',
    'man',
    'woman',
    'child',
  };

  static String svgAssetFor(SystemVerb verb) {
    final String asset = _svgAssets[verb]!;
    _assertStrictSystemVerbAsset(asset);
    return asset;
  }

  static void _assertStrictSystemVerbAsset(String asset) {
    final String lower = asset.toLowerCase();
    for (final String token in _forbiddenHumanCentricTokens) {
      if (lower.contains(token)) {
        throw ArgumentError.value(
          asset,
          'asset',
          'Human-centric iconography is not permitted in system-verb mapping.',
        );
      }
    }
  }

  static Widget buildIcon(
    SystemVerb verb, {
    Key? key,
    Color? color,
    String? semanticLabel,
  }) {
    return SizedBox(
      key: key,
      width: structuralIconSize,
      height: structuralIconSize,
      child: SvgPicture.asset(
        svgAssetFor(verb),
        width: structuralIconSize,
        height: structuralIconSize,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: semanticLabel,
      ),
    );
  }

  static Widget buildTouchTarget(
    SystemVerb verb, {
    Key? key,
    VoidCallback? onTap,
    Color? color,
    String? semanticLabel,
  }) {
    return Semantics(
      key: key,
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: phantomHitAreaSize / 2,
        containedInkWell: false,
        child: SizedBox(
          width: phantomHitAreaSize,
          height: phantomHitAreaSize,
          child: Center(
            child: buildIcon(
              verb,
              color: color,
              semanticLabel: semanticLabel,
            ),
          ),
        ),
      ),
    );
  }
}
