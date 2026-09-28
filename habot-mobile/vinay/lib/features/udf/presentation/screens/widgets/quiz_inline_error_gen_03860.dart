// GEN-03860 — Quiz Inline Error Message Widget.
// Displays an inline M3 error message if any quiz response is incorrect, with sub-16ms render latency target and single-column responsive layout.

import 'package:flutter/material.dart';

/// Mock data representing a quiz question and user response for local validation.
class QuizResponseModel {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;

  const QuizResponseModel({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.selectedIndex,
  });

  bool get isIncorrect => selectedIndex != null && selectedIndex != correctIndex;
  bool get isUnanswered => selectedIndex == null;
}

/// Local mock repository providing dummy quiz data.
class MockQuizRepository {
  static const List<QuizResponseModel> sampleResponses = [
    QuizResponseModel(
      questionId: 'q1',
      questionText: 'What is the primary purpose of Material Design 3?',
      options: ['Personalization', 'Obfuscation', 'Deprecation', 'Isolation'],
      correctIndex: 0,
      selectedIndex: 0, // Correct
    ),
    QuizResponseModel(
      questionId: 'q2',
      questionText: 'Which widget is used for M3 elevated cards?',
      options: ['Card', 'ElevatedCard', 'Container', 'Material'],
      correctIndex: 0,
      selectedIndex: 2, // Incorrect
    ),
    QuizResponseModel(
      questionId: 'q3',
      questionText: 'What is the minimum touch target size in M3?',
      options: ['24x24dp', '32x32dp', '48x48dp', '64x64dp'],
      correctIndex: 2,
      selectedIndex: 1, // Incorrect
    ),
  ];
}

/// Core widget that displays inline error messages for incorrect quiz responses.
/// Follows M3 guidelines, WCAG 2.1 AA accessibility, and mobile-first responsive design.
class QuizInlineErrorWidget extends StatelessWidget {
  final List<QuizResponseModel> responses;

  const QuizInlineErrorWidget({
    super.key,
    required this.responses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final incorrectResponses = responses.where((r) => r.isIncorrect).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Results',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (incorrectResponses.isNotEmpty) ...[
                _buildGlobalErrorBanner(theme, incorrectResponses.length),
                const SizedBox(height: 24),
              ],
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isMobile ? 2.5 : 3.0,
                ),
                itemCount: responses.length,
                itemBuilder: (context, index) {
                  final response = responses[index];
                  return _QuizResponseCard(
                    response: response,
                    colorScheme: colorScheme,
                    textTheme: theme.textTheme,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlobalErrorBanner(ThemeData theme, int errorCount) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$errorCount response(s) incorrect. Please review the highlighted items below.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizResponseCard extends StatelessWidget {
  final QuizResponseModel response;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _QuizResponseCard({
    required this.response,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = response.isIncorrect;
    final Color cardColor = hasError
        ? colorScheme.errorContainer.withOpacity(0.3)
        : colorScheme.surfaceContainerHighest.withOpacity(0.3);
    final Color borderColor = hasError
        ? colorScheme.error
        : colorScheme.outlineVariant;

    return Semantics(
      label: hasError
          ? 'Incorrect answer for ${response.questionText}'
          : 'Correct or pending answer for ${response.questionText}',
      child: Material(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        color: cardColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: hasError ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  response.questionText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              if (hasError) ...[
                Row(
                  children: [
                    Icon(
                      Icons.cancel_rounded,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Incorrect. Selected: ${response.options[response.selectedIndex!]}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else if (!response.isUnanswered) ...[
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Correct',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone preview wrapper to demonstrate usage with mock data.
class QuizInlineErrorPreview extends StatelessWidget {
  const QuizInlineErrorPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-03860 Quiz Validation'),
      ),
      body: SingleChildScrollView(
        child: QuizInlineErrorWidget(
          responses: MockQuizRepository.sampleResponses,
        ),
      ),
    );
  }
}
