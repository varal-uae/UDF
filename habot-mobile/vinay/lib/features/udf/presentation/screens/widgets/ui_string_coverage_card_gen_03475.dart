// GEN-03475 — UI String Localized Coverage Status Card.
// Displays i18n localization coverage metric using M3 ElevatedCard, responsive single/multi-column layout, 30s polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing target language dictionary coverage.
class _MockLocalizationData {
  final String languageCode;
  final String languageName;
  final double coverage;
  final bool isPassing;

  const _MockLocalizationData({
    required this.languageCode,
    required this.languageName,
    required this.coverage,
    required this.isPassing,
  });
}

const List<_MockLocalizationData> _kMockLanguages = [
  _MockLocalizationData(languageCode: 'en', languageName: 'English', coverage: 1.0, isPassing: true),
  _MockLocalizationData(languageCode: 'es', languageName: 'Spanish', coverage: 1.0, isPassing: true),
  _MockLocalizationData(languageCode: 'fr', languageName: 'French', coverage: 1.0, isPassing: true),
  _MockLocalizationData(languageCode: 'de', languageName: 'German', coverage: 1.0, isPassing: true),
  _MockLocalizationData(languageCode: 'ja', languageName: 'Japanese', coverage: 1.0, isPassing: true),
  _MockLocalizationData(languageCode: 'zh', languageName: 'Chinese', coverage: 1.0, isPassing: true),
];

/// Overall coverage state derived from mock backend.
class UiStringCoverageState {
  final double overallCoverage;
  final int totalLanguages;
  final int passingLanguages;
  final String status;
  final DateTime lastUpdated;

  const UiStringCoverageState({
    required this.overallCoverage,
    required this.totalLanguages,
    required this.passingLanguages,
    required this.status,
    required this.lastUpdated,
  });
}

class UiStringCoverageCardGen03475 extends StatefulWidget {
  const UiStringCoverageCardGen03475({super.key});

  @override
  State<UiStringCoverageCardGen03475> createState() => _UiStringCoverageCardGen03475State();
}

class _UiStringCoverageCardGen03475State extends State<UiStringCoverageCardGen03475> {
  late UiStringCoverageState _state;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _state = _fetchMockState();
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  UiStringCoverageState _fetchMockState() {
    final passing = _kMockLanguages.where((l) => l.isPassing).length;
    final total = _kMockLanguages.length;
    final avgCoverage = _kMockLanguages.fold<double>(0.0, (sum, l) => sum + l.coverage) / total;
    return UiStringCoverageState(
      overallCoverage: avgCoverage,
      totalLanguages: total,
      passingLanguages: passing,
      status: avgCoverage >= 1.0 ? 'Pass' : 'Fail',
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _refreshData() async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    // Simulate network latency < 100ms
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _state = _fetchMockState();
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
          final isDesktop = constraints.maxWidth >= 840;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 840;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(theme, colorScheme),
                const SizedBox(height: 16),
                if (isDesktop)
                  _buildMultiColumnLanguageGrid(theme, colorScheme, crossAxisCount: 3)
                else if (isTablet)
                  _buildMultiColumnLanguageGrid(theme, colorScheme, crossAxisCount: 2)
                else
                  _buildSingleColumnLanguageList(theme, colorScheme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ColorScheme colorScheme) {
    final isPassing = _state.status == 'Pass';
    final chipColor = isPassing ? colorScheme.primaryContainer : colorScheme.errorContainer;
    final chipTextColor = isPassing ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer;

    // M3 Elevated Cards Level 2 (3dp)
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'UI String Localized Coverage',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // M3 Status Chips for health indicators
                Chip(
                  label: Text(
                    _state.status,
                    style: theme.textTheme.labelLarge?.copyWith(color: chipTextColor),
                  ),
                  backgroundColor: chipColor,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.translate, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  '${(_state.overallCoverage * 100).toStringAsFixed(0)}% Coverage',
                  style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
                ),
                const Spacer(),
                Text(
                  '${_state.passingLanguages}/${_state.totalLanguages} Languages Passing',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _state.overallCoverage.clamp(0.0, 1.0),
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(4.0),
              backgroundColor: colorScheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPassing ? colorScheme.primary : colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Last synced: ${_formatTime(_state.lastUpdated)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (_isRefreshing) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleColumnLanguageList(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: _kMockLanguages.map((lang) => _buildLanguageTile(lang, theme, colorScheme)).toList(),
    );
  }

  Widget _buildMultiColumnLanguageGrid(ThemeData theme, ColorScheme colorScheme, {required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2.5,
      ),
      itemCount: _kMockLanguages.length,
      itemBuilder: (context, index) {
        return _buildLanguageTile(_kMockLanguages[index], theme, colorScheme);
      },
    );
  }

  Widget _buildLanguageTile(_MockLocalizationData lang, ThemeData theme, ColorScheme colorScheme) {
    final isPassing = lang.coverage >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Semantics(
        label: '${lang.languageName} localization coverage ${(lang.coverage * 100).toStringAsFixed(0)} percent, status ${isPassing ? 'passing' : 'failing'}',
        child: Card(
          elevation: 1.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          // 48x48dp touch targets constraint applied via minimum sizing
          child: InkWell(
            onTap: () => _showDetailBottomSheet(lang, theme, colorScheme),
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: isPassing ? colorScheme.primaryContainer : colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lang.languageCode.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isPassing ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang.languageName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(lang.coverage * 100).toStringAsFixed(0)}% localized',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // M3 Status Chips for health indicators
                    Chip(
                      avatar: Icon(
                        isPassing ? Icons.check_circle_outline : Icons.error_outline,
                        size: 16,
                        color: isPassing ? colorScheme.primary : colorScheme.error,
                      ),
                      label: Text(
                        isPassing ? 'Pass' : 'Fail',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isPassing ? colorScheme.primary : colorScheme.error,
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isPassing ? colorScheme.primary.withOpacity(0.3) : colorScheme.error.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs / drill-down details.
  void _showDetailBottomSheet(_MockLocalizationData lang, ThemeData theme, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${lang.languageName} (${lang.languageCode.toUpperCase()}) Details',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Coverage Target', '100%', theme, colorScheme),
              _buildDetailRow('Current Coverage', '${(lang.coverage * 100).toStringAsFixed(1)}%', theme, colorScheme),
              _buildDetailRow('Floor Boundary', '1.0', theme, colorScheme),
              _buildDetailRow('Status', lang.isPassing ? 'Pass' : 'Fail', theme, colorScheme),
              _buildDetailRow('Standard', 'i18n Localization Guidelines', theme, colorScheme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // M3 Snackbar for confirmations
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Drill-down acknowledged for ${lang.languageName}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        action: SnackBarAction(
                          label: 'DISMISS',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
