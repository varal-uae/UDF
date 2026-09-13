// FIEVR-008-A08 — Predictive Word-of-Mouth Selection Dropdown & Autocomplete Interface.
// Enforces standardized acquisition origin selection, suppresses loose free-text entries,
// and physically freezes continuation triggers when channel validation fails (Poka-Yoke).

import 'dart:async';
import 'package:flutter/material.dart';

/// Acquisition Channel Model representing validated word-of-mouth and organic sources.
class AcquisitionChannel {
  final String code;
  final String label;
  final String category;
  final bool isGenericOther;

  const AcquisitionChannel({
    required this.code,
    required this.label,
    required this.category,
    this.isGenericOther = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcquisitionChannel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => label;
}

/// Telemetry execution event model matching atomic audit requirements.
class ChannelStepTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus; // 'Pass' or 'Fail'
  final String? selectedChannelCode;

  const ChannelStepTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    this.selectedChannelCode,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome,
        'userId': userId,
        'completionStatus': completionStatus,
        'actionTimestamp': DateTime.now().toIso8601String(),
        'selectedChannelCode': selectedChannelCode,
      };
}

/// Signature for handling telemetry events.
typedef TelemetryCallback = void Function(ChannelStepTelemetry event);

/// Signature for completing step after valid channel selection.
typedef OnboardingContinueCallback = void Function(
    AcquisitionChannel selectedChannel);

/// Standard Acquisition Origin Options
const List<AcquisitionChannel> kDefaultAcquisitionChannels = [
  AcquisitionChannel(
    code: 'WOM_JLT_PARENT_COMMUNITY',
    label: 'JLT Nursery Parent Recommendation',
    category: 'Word of Mouth',
  ),
  AcquisitionChannel(
    code: 'WOM_FRIEND_FAMILY',
    label: 'Friend or Family Member',
    category: 'Word of Mouth',
  ),
  AcquisitionChannel(
    code: 'WOM_PLAYGROUP_WHATSAPP',
    label: 'Local Community / WhatsApp Playgroup',
    category: 'Word of Mouth',
  ),
  AcquisitionChannel(
    code: 'WOM_COWORKER',
    label: 'Work Colleague / Office Parent Group',
    category: 'Word of Mouth',
  ),
  AcquisitionChannel(
    code: 'LOCAL_EVENT_POPUP',
    label: 'JLT Community Park Pop-up Event',
    category: 'Community Event',
  ),
  AcquisitionChannel(
    code: 'ORGANIC_SEARCH_LOCAL',
    label: 'Online Search (Nursery in JLT)',
    category: 'Search & Maps',
  ),
  AcquisitionChannel(
    code: 'ACQ_OTHER_GENERIC',
    label: 'Other Organic Mention',
    category: 'General',
    isGenericOther: true,
  ),
];

/// Predictive word-of-mouth autocomplete widget with Poka-Yoke continuation freeze.
class PredictiveWordOfMouthDropdownFievr008A08 extends StatefulWidget {
  final String userId;
  final String stepExecutionId;
  final List<AcquisitionChannel> channels;
  final OnboardingContinueCallback? onContinue;
  final TelemetryCallback? onTelemetryLogged;
  final double otherOptionThresholdRatio;

  const PredictiveWordOfMouthDropdownFievr008A08({
    super.key,
    required this.userId,
    required this.stepExecutionId,
    this.channels = kDefaultAcquisitionChannels,
    this.onContinue,
    this.onTelemetryLogged,
    this.otherOptionThresholdRatio = 0.20,
  });

  @override
  State<PredictiveWordOfMouthDropdownFievr008A08> createState() =>
      _PredictiveWordOfMouthDropdownFievr008A08State();
}

class _PredictiveWordOfMouthDropdownFievr008A08State
    extends State<PredictiveWordOfMouthDropdownFievr008A08> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  AcquisitionChannel? _selectedChannel;
  String? _validationError;
  bool _isLockedSubmitting = false;
  int _totalConversionsTracked = 0;
  int _otherConversionsTracked = 0;
  bool _alertThresholdTriggered = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChannelSelected(AcquisitionChannel channel) {
    setState(() {
      _selectedChannel = channel;
      _searchController.text = channel.label;
      _validationError = null;
    });
  }

  void _validateAndSubmit() {
    // Poka-Yoke: Continuation physically freezes if channel parameter is null
    if (_selectedChannel == null) {
      setState(() {
        _validationError =
            'Selection required: Please select a verified referral source from the suggestions.';
      });

      _emitTelemetry(
        executionStatus: 'VALIDATION_BLOCKED',
        outcome: 'Poka-Yoke gate prevented continuation: null channel',
        completionStatus: 'Fail',
      );
      return;
    }

    setState(() {
      _isLockedSubmitting = true;
      _totalConversionsTracked += 1;
      if (_selectedChannel!.isGenericOther) {
        _otherConversionsTracked += 1;
      }
      // Self-Chasing check: Alert if 'Other' exceeds configured threshold (e.g. 20%)
      if (_totalConversionsTracked > 0 &&
          (_otherConversionsTracked / _totalConversionsTracked) >
              widget.otherOptionThresholdRatio) {
        _alertThresholdTriggered = true;
      }
    });

    _emitTelemetry(
      executionStatus: 'SUCCESS',
      outcome: 'Channel verified and locked: ${_selectedChannel!.code}',
      completionStatus: 'Pass',
      selectedChannelCode: _selectedChannel!.code,
    );

    widget.onContinue?.call(_selectedChannel!);
  }

  void _emitTelemetry({
    required String executionStatus,
    required String outcome,
    required String completionStatus,
    String? selectedChannelCode,
  }) {
    final telemetry = ChannelStepTelemetry(
      stepExecutionId: widget.stepExecutionId,
      executionStatus: executionStatus,
      executionTimestamp: DateTime.now(),
      stepOutcome: outcome,
      userId: widget.userId,
      completionStatus: completionStatus,
      selectedChannelCode: selectedChannelCode,
    );
    widget.onTelemetryLogged?.call(telemetry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelectionValid = _selectedChannel != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
        [
          Text(
            'How Did You Hear About Us?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap below to choose your organic referral origin. Predictive suggestions update as you type.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Predictive Material 3 Autocomplete with strict selection enforcement
          RawAutocomplete<AcquisitionChannel>(
            textEditingController: _searchController,
            focusNode: _focusNode,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return widget.channels;
              }
              final query = textEditingValue.text.toLowerCase();
              return widget.channels.where((channel) =>
                  channel.label.toLowerCase().contains(query) ||
                  channel.category.toLowerCase().contains(query));
            },
            displayStringForOption: (AcquisitionChannel option) => option.label,
            onSelected: _onChannelSelected,
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: fieldController,
                focusNode: fieldFocusNode,
                decoration: InputDecoration(
                  labelText: 'Referral or Community Channel',
                  hintText: 'Start typing e.g. JLT, Playgroup...',
                  prefixIcon: const Icon(Icons.record_voice_over_outlined),
                  suffixIcon: _selectedChannel != null
                      ? IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _selectedChannel = null;
                              fieldController.clear();
                            });
                          },
                        )
                      : const Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  errorText: _validationError,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                ),
                // Completely disables loose free-text submission on Enter
                onSubmitted: (_) {
                  if (_selectedChannel == null) {
                    setState(() {
                      _validationError =
                          'Please select an option from the predictive list.';
                    });
                  }
                },
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<AcquisitionChannel> onSelected,
              Iterable<AcquisitionChannel> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 260,
                      maxWidth: 360,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        final isSelected = option == _selectedChannel;
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            option.isGenericOther
                                ? Icons.more_horiz
                                : Icons.groups_outlined,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            option.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            option.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check, color: theme.colorScheme.primary)
                              : null,
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          if (_alertThresholdTriggered)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Audit alert: Generic "Other" rate exceeded 20%. Channel list scheduled for refresh.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Mistake-Proofing continuation trigger:
          // Physically freezes (disabled) until a valid predictive selection is registered
          FilledButton.icon(
            onPressed:
                (!isSelectionValid || _isLockedSubmitting) ? null : _validateAndSubmit,
            icon: _isLockedSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(
              _isLockedSubmitting
                  ? 'Verifying Attribution...'
                  : isSelectionValid
                      ? 'Confirm Referral Origin'
                      : 'Select Referral Origin to Continue',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
