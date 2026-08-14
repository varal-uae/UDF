import 'package:flutter/material.dart';

import '../feedback/failure_reason_catalog.dart';
import '../telemetry/rating_diagnostic_telemetry.dart';
import '../utils/validated_form.dart';
import 'ec_cta_button.dart';

// IS27-FEBFL-024-AS01-A01 — Conditional visibility form behind rating steps.
//
// Flow:
//   1. User selects rating (1–5)
//   2. If score <= 3 → diagnostic panel slides in (client-side, instant)
//   3. Checklist of failure reasons + required details textarea
//   4. Submit locked until ≥1 checkbox + non-empty details
//   5. High ratings (4–5) skip diagnostic — submit enabled immediately

class PerformanceEvaluationForm extends StatefulWidget {
  const PerformanceEvaluationForm({
    super.key,
    this.onSubmitted,
    this.sessionId,
    this.userId,
    this.minDetailLength = 10,
  });

  final ValueChanged<RatingDiagnosticPayload>? onSubmitted;
  final String? sessionId;
  final String? userId;
  final int minDetailLength;

  @override
  State<PerformanceEvaluationForm> createState() =>
      _PerformanceEvaluationFormState();
}

class _PerformanceEvaluationFormState extends State<PerformanceEvaluationForm> {
  final _registry     = ValidatedFieldRegistry();
  final _formKey      = GlobalKey<FormState>();
  final _detailsCtrl  = TextEditingController();

  int? _score;
  final Set<FailureReason> _selected = {};

  bool get _needsDiagnostic =>
      _score != null && _score! <= lowRatingThreshold;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _onScoreSelected(int score) {
    _registry.unregister('diagnostic_checklist');
    _registry.unregister('diagnostic_details');
    _registry.unregister('rating_only');

    setState(() {
      _score = score;
      _selected.clear();
      _detailsCtrl.clear();
    });

    if (score <= lowRatingThreshold) {
      _registry.register('diagnostic_checklist', required: true);
      _registry.register('diagnostic_details', required: true);
      _registry.setValidity('diagnostic_checklist', isValid: false);
      _registry.setValidity('diagnostic_details', isValid: false);
    } else {
      _registry.register('rating_only', required: true);
      _registry.setValidity('rating_only', isValid: true);
    }
  }

  void _toggleReason(FailureReason reason, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(reason);
      } else {
        _selected.remove(reason);
      }
    });
    _registry.setValidity(
      'diagnostic_checklist',
      isValid: _selected.isNotEmpty,
    );
  }

  void _onDetailsChanged(String value) {
    _registry.setValidity(
      'diagnostic_details',
      isValid: value.trim().length >= widget.minDetailLength,
    );
  }

  Future<void> _submit() async {
    if (_score == null) return;

    if (_needsDiagnostic) {
      if (!_registry.isAllValid) return;
      if !(_formKey.currentState?.validate() ?? false)) return;
    }

    final payload = RatingDiagnosticPayload(
      score:     _score!,
      reasons:   _selected.toList(),
      details:   _needsDiagnostic ? _detailsCtrl.text.trim() : '',
      timestamp: DateTime.now(),
    );

    if (_needsDiagnostic) {
      await RatingDiagnosticTelemetry.dispatch(
        payload:   payload,
        sessionId: widget.sessionId,
        userId:    widget.userId,
      );
    }

    widget.onSubmitted?.call(payload);
  }

  bool get _canSubmit {
    if (_score == null) return false;
    if (!_needsDiagnostic) return true;
    return _registry.isAllValid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValidatedForm(
      formKey:  _formKey,
      registry: _registry,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How was your experience?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _RatingRow(
            selected: _score,
            onSelected: _onScoreSelected,
          ),
          const SizedBox(height: 16),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _needsDiagnostic
                ? _DiagnosticPanel(
                    selected: _selected,
                    detailsController: _detailsCtrl,
                    minDetailLength: widget.minDetailLength,
                    onReasonToggled: _toggleReason,
                    onDetailsChanged: _onDetailsChanged,
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          ListenableBuilder(
            listenable: _registry,
            builder: (_, __) => EcCtaButton(
              label: 'Submit',
              onPressed: _canSubmit ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star rating row ───────────────────────────────────────────────────────────

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.selected,
    required this.onSelected,
  });

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final score = i + 1;
        final filled = selected != null && score <= selected!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            tooltip: '$score star${score > 1 ? 's' : ''}',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => onSelected(score),
            icon: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 36,
              color: filled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }),
    );
  }
}

// ── Diagnostic panel (score <= 3) ─────────────────────────────────────────────

class _DiagnosticPanel extends StatelessWidget {
  const _DiagnosticPanel({
    required this.selected,
    required this.detailsController,
    required this.minDetailLength,
    required this.onReasonToggled,
    required this.onDetailsChanged,
  });

  final Set<FailureReason> selected;
  final TextEditingController detailsController;
  final int minDetailLength;
  final void Function(FailureReason, bool) onReasonToggled;
  final ValueChanged<String> onDetailsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.errorContainer.withOpacity(0.35),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_outlined,
                    color: theme.colorScheme.error, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Help us improve — what went wrong?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...FailureReasonCatalog.all.map((reason) {
              return CheckboxListTile(
                value: selected.contains(reason),
                onChanged: (v) => onReasonToggled(reason, v ?? false),
                title: Text(
                  reason.label,
                  style: theme.textTheme.bodyMedium,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),

            const SizedBox(height: 8),
            TextFormField(
              controller: detailsController,
              onChanged: onDetailsChanged,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Describe what happened *',
                hintText: 'Provide specific details so we can fix the issue…',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              validator: (v) {
                if (v == null || v.trim().length < minDetailLength) {
                  return 'Enter at least $minDetailLength characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Stand-alone diagnostic block — use when rating is managed externally.
class LowRatingDiagnosticForm extends StatelessWidget {
  const LowRatingDiagnosticForm({
    super.key,
    required this.score,
    required this.registry,
    required this.detailsController,
    this.minDetailLength = 10,
    this.onReasonChanged,
    this.onDetailsChanged,
  });

  final int score;
  final ValidatedFieldRegistry registry;
  final TextEditingController detailsController;
  final int minDetailLength;
  final VoidCallback? onReasonChanged;
  final ValueChanged<String>? onDetailsChanged;

  @override
  Widget build(BuildContext context) {
    if (score > lowRatingThreshold) return const SizedBox.shrink();

    return _DiagnosticPanelWrapper(
      registry: registry,
      detailsController: detailsController,
      minDetailLength: minDetailLength,
      onReasonChanged: onReasonChanged,
      onDetailsChanged: onDetailsChanged,
    );
  }
}

class _DiagnosticPanelWrapper extends StatefulWidget {
  const _DiagnosticPanelWrapper({
    required this.registry,
    required this.detailsController,
    required this.minDetailLength,
    this.onReasonChanged,
    this.onDetailsChanged,
  });

  final ValidatedFieldRegistry registry;
  final TextEditingController detailsController;
  final int minDetailLength;
  final VoidCallback? onReasonChanged;
  final ValueChanged<String>? onDetailsChanged;

  @override
  State<_DiagnosticPanelWrapper> createState() =>
      _DiagnosticPanelWrapperState();
}

class _DiagnosticPanelWrapperState extends State<_DiagnosticPanelWrapper> {
  final Set<FailureReason> _selected = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.registry.register('diagnostic_checklist', required: true);
      widget.registry.register('diagnostic_details', required: true);
      widget.registry.setValidity('diagnostic_checklist', isValid: false);
      widget.registry.setValidity('diagnostic_details', isValid: false);
    });
  }

  void _toggle(FailureReason reason, bool on) {
    setState(() {
      if (on) {
        _selected.add(reason);
      } else {
        _selected.remove(reason);
      }
    });
    widget.registry.setValidity(
      'diagnostic_checklist',
      isValid: _selected.isNotEmpty,
    );
    widget.onReasonChanged?.call();
  }

  void _details(String v) {
    widget.registry.setValidity(
      'diagnostic_details',
      isValid: v.trim().length >= widget.minDetailLength,
    );
    widget.onDetailsChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    return _DiagnosticPanel(
      selected: _selected,
      detailsController: widget.detailsController,
      minDetailLength: widget.minDetailLength,
      onReasonToggled: _toggle,
      onDetailsChanged: _details,
    );
  }
}
