/// AISS: GEN-01297-A01 -- "Implement an empty state container with custom
/// illustrations to display when search queries return no results."
///
/// An empty state is not "nothing to draw". It is a specific message with a
/// specific next action, and the failure mode this component exists to prevent
/// is the blank rectangle that leaves a user unsure whether the app is broken,
/// still loading, or genuinely has nothing to show.
///
/// So the type system does the enforcing: there is no way to construct an
/// empty state without a reason, and every reason carries a headline, a body
/// and (where one exists) an action. The reason also fixes the illustration,
/// which is why a caller cannot pick a cheerful graphic for a failure.
library;

import 'package:flutter/material.dart';

import '../resilience/error_templates.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// Why a surface has nothing to show. Each value is a different sentence to
/// the user, which is the whole point of distinguishing them.
enum HabotEmptyReason {
  /// A search ran and matched nothing. The one the step names explicitly.
  noSearchResults,

  /// A filter is active and excludes everything.
  filteredOut,

  /// The collection is genuinely empty and the user can create the first item.
  nothingYet,

  /// The data could not be loaded. Distinct from empty on purpose -- telling a
  /// user "no results" when the network failed is a lie.
  unavailable,
}

/// The copy and illustration for one reason.
class HabotEmptyStateSpec {
  const HabotEmptyStateSpec({
    required this.reason,
    required this.icon,
    required this.headline,
    required this.body,
    required this.actionLabel,
  });

  final HabotEmptyReason reason;
  final IconData icon;
  final String headline;
  final String body;

  /// Null when there is no honest action to offer.
  final String? actionLabel;

  bool get hasAction => actionLabel != null;
}

class HabotEmptyStates {
  const HabotEmptyStates._();

  static const Map<HabotEmptyReason, HabotEmptyStateSpec> _specs =
      <HabotEmptyReason, HabotEmptyStateSpec>{
        HabotEmptyReason.noSearchResults: HabotEmptyStateSpec(
          reason: HabotEmptyReason.noSearchResults,
          icon: Icons.search_off,
          headline: 'No matches',
          body:
              'Nothing here matches what you searched for. Try fewer words, or '
              'check the spelling.',
          actionLabel: 'Clear search',
        ),
        HabotEmptyReason.filteredOut: HabotEmptyStateSpec(
          reason: HabotEmptyReason.filteredOut,
          icon: Icons.filter_alt_off,
          headline: 'Everything is filtered out',
          body:
              'There are items here, but your current filters hide all of '
              'them.',
          actionLabel: 'Reset filters',
        ),
        HabotEmptyReason.nothingYet: HabotEmptyStateSpec(
          reason: HabotEmptyReason.nothingYet,
          icon: Icons.inbox_outlined,
          headline: 'Nothing here yet',
          body: 'When there is something to show, it will appear here.',
          actionLabel: null,
        ),
        HabotEmptyReason.unavailable: HabotEmptyStateSpec(
          reason: HabotEmptyReason.unavailable,
          icon: Icons.cloud_off,
          headline: 'Cannot load this right now',
          body:
              'We could not reach your data. This is not the same as having '
              'none -- try again in a moment.',
          actionLabel: 'Try again',
        ),
      };

  static HabotEmptyStateSpec of(HabotEmptyReason reason) => _specs[reason]!;

  static Iterable<HabotEmptyStateSpec> get all => _specs.values;

  /// Every reason is covered. Adding an enum value without copy fails this.
  static bool get isComplete => _specs.length == HabotEmptyReason.values.length;

  /// The same jargon ban REF-197 applies to error copy. An empty state that
  /// says "null result set" is an error message wearing a disguise.
  static List<String> get forbiddenJargon => HabotErrorTemplates.forbiddenJargon;
}

/// The empty-state container.
class HabotEmptyState extends StatelessWidget {
  const HabotEmptyState({required this.reason, this.onAction, super.key});

  final HabotEmptyReason reason;

  /// Wired only when the spec offers an action. Passing one for a reason with
  /// no action label does nothing -- the copy is what decides.
  final VoidCallback? onAction;

  HabotEmptyStateSpec get spec => HabotEmptyStates.of(reason);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: HabotFeedback.emptyStateMaxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(HabotSpacing.lg),
          child: _EmptyStateBody(spec: spec, onAction: onAction),
        ),
      ),
    );
  }
}

class _EmptyStateBody extends StatelessWidget {
  const _EmptyStateBody({required this.spec, required this.onAction});

  final HabotEmptyStateSpec spec;
  final VoidCallback? onAction;

  bool get _showsAction => spec.hasAction && onAction != null;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          spec.icon,
          size: HabotFeedback.emptyStateIconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: HabotFeedback.emptyStateGap),
        _centred(spec.headline, theme.textTheme.titleMedium),
        const SizedBox(height: HabotFeedback.emptyStateGap),
        _centred(spec.body, theme.textTheme.bodyMedium),
        if (_showsAction) const SizedBox(height: HabotSpacing.md),
        if (_showsAction)
          FilledButton(onPressed: onAction, child: Text(spec.actionLabel!)),
      ],
    );
  }

  Widget _centred(String text, TextStyle? style) =>
      Text(text, style: style, textAlign: TextAlign.center);
}
