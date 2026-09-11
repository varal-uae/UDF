// FEBFL-015-A19 — Secure Post-Session Evaluation View / AnonymizedReviewBox.
// Provides compact star rating and feedback fields, blocks submission without a rating, and reveals diagnostic reason fields for low scores.
import 'package:flutter/material.dart';

class AnonymizedReviewBoxFEBFL015A19 extends StatefulWidget {
  const AnonymizedReviewBoxFEBFL015A19({super.key, this.onSubmit});

  final ValueChanged<Map<String, Object?>>? onSubmit;

  @override
  State<AnonymizedReviewBoxFEBFL015A19> createState() => _AnonymizedReviewBoxFEBFL015A19State();
}

class _AnonymizedReviewBoxFEBFL015A19State extends State<AnonymizedReviewBoxFEBFL015A19> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _diagnosticController = TextEditingController();
  bool _showRatingError = false;

  bool get _isLowRating => _rating > 0 && _rating <= 2;

  @override
  void dispose() {
    _feedbackController.dispose();
    _diagnosticController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _rating > 0;
    setState(() => _showRatingError = !isValid);
    if (!isValid) return;

    final payload = <String, Object?>{
      'rating': _rating,
      'feedback': _feedbackController.text.trim(),
      'diagnosticReason': _isLowRating ? _diagnosticController.text.trim() : null,
      'completionStatus': 'Pass',
      'timestamp': DateTime.now().toIso8601String(),
    };

    widget.onSubmit?.call(payload);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evaluation submitted securely.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Secure post-session evaluation',
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Post-session evaluation', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Your feedback helps improve service quality.', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 20),
                Text('Overall rating', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    final selected = star <= _rating;
                    return Semantics(
                      button: true,
                      selected: _rating == star,
                      label: 'Rate $star out of 5',
                      child: IconButton(
                        onPressed: () => setState(() {
                          _rating = star;
                          _showRatingError = false;
                        }),
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        padding: EdgeInsets.zero,
                        iconSize: 36,
                        icon: Icon(
                          selected ? Icons.star_rounded : Icons.star_border_rounded,
                          color: selected ? colorScheme.primary : colorScheme.outline,
                        ),
                      ),
                    );
                  }),
                ),
                if (_showRatingError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Please select an overall rating.',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Feedback', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _feedbackController,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Tell us about your experience',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_isLowRating) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.error.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What went wrong?', style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onErrorContainer)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _diagnosticController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Reason for low rating',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Submit evaluation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
