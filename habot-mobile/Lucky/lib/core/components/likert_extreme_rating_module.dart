// IS35-CSIVW-022-AS01 — Extreme Score Text Expansion Constraints.
// Conditionally reveals a mandatory evidence text area when Likert score hits 1 or 5.
// Employs AnimatedSize for smooth height expansion and enforces word/character count gates.

import 'package:flutter/material.dart';

class LikertExtremeRatingModule extends StatefulWidget {
  const LikertExtremeRatingModule({
    super.key,
    required this.onRatingChanged,
    required this.onEvidenceSubmitted,
    this.minWordCount = 10,
  });

  final ValueChanged<int> onRatingChanged;
  final ValueChanged<String> onEvidenceSubmitted;
  final int minWordCount;

  @override
  State<LikertExtremeRatingModule> createState() => _LikertExtremeRatingModuleState();
}

class _LikertExtremeRatingModuleState extends State<LikertExtremeRatingModule> {
  int _currentRating = 3;
  final TextEditingController _evidenceController = TextEditingController();
  bool _isEvidenceValid = false;

  bool get _isExtremeScore => _currentRating == 1 || _currentRating == 5;

  @override
  void dispose() {
    _evidenceController.dispose();
    super.dispose();
  }

  void _onRatingSelected(int score) {
    setState(() {
      _currentRating = score;
      if (!_isExtremeScore) {
        _evidenceController.clear();
        _isEvidenceValid = false;
      }
    });
    widget.onRatingChanged(score);
  }

  void _validateEvidence(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    setState(() {
      _isEvidenceValid = words >= widget.minWordCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Performance Evaluation Rating',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Likert 1 to 5 Rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final score = index + 1;
                final isSelected = _currentRating == score;
                return ChoiceChip(
                  label: Text('$score'),
                  selected: isSelected,
                  onSelected: (_) => _onRatingSelected(score),
                  selectedColor: (score == 1 || score == 5) ? cs.errorContainer : cs.primaryContainer,
                );
              }),
            ),
            
            // Smooth conditional height expansion for extreme score justification
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isExtremeScore
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: cs.onErrorContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Evidence Required: Outlier ratings (1 or 5) require a minimum justification of ${widget.minWordCount} words.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onErrorContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _evidenceController,
                          maxLines: 3,
                          onChanged: _validateEvidence,
                          decoration: InputDecoration(
                            hintText: 'Provide specific justification evidence...',
                            border: const OutlineInputBorder(),
                            helperText: '${_evidenceController.text.trim().split(RegExp(r"\s+")).where((w) => w.isNotEmpty).length}/${widget.minWordCount} words minimum',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _isEvidenceValid
                              ? () => widget.onEvidenceSubmitted(_evidenceController.text)
                              : null,
                          child: const Text('Submit Justified Rating'),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
