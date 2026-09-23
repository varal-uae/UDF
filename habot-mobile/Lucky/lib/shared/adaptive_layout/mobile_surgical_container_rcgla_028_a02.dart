// RCGLA-028-A02 — Mobile Surgical Container & Responsive 4-Column Grid Layout.
// Implements a mobile-first responsive layout that forces vertical stacking on compact viewports (<=360px baseline),
// collapsing multi-column transactional data into single-axis scroll hierarchies per Material Design 3 Window Size Classes.

import 'package:flutter/material.dart';

/// Global view configuration constant for the baseline breakpoint marker.
const double kCompactBaselineBreakpoint = 360.0;

/// Material Design 3 canonical window-size class boundaries.
const double kMd3CompactMax = 599.0;
const double kMd3MediumMax = 839.0;

/// Configuration data model for atomic-level fields.
class GridConfigurationData {
  final String configurationKey;
  final String configurationValue;
  final String configurationType;
  final bool validationStatus;
  final DateTime configurationTimestamp;

  const GridConfigurationData({
    required this.configurationKey,
    required this.configurationValue,
    required this.configurationType,
    required this.validationStatus,
    required this.configurationTimestamp,
  });
}

/// Realistic local mock data repository simulating backend fetches.
class MockGridConfigurationRepository {
  static List<GridConfigurationData> fetchConfigurations() {
    return const [
      GridConfigurationData(
        configurationKey: 'txn_limit_daily',
        configurationValue: '50000 AED',
        configurationType: 'Financial',
        validationStatus: true,
        configurationTimestamp: DateTime(2026, 9, 23, 10, 0),
      ),
      GridConfigurationData(
        configurationKey: 'auto_refresh_interval',
        configurationValue: '30s',
        configurationType: 'System',
        validationStatus: true,
        configurationTimestamp: DateTime(2026, 9, 23, 10, 5),
      ),
      GridConfigurationData(
        configurationKey: 'theme_mode',
        configurationValue: 'dark',
        configurationType: 'UI/UX',
        validationStatus: false,
        configurationTimestamp: DateTime(2026, 9, 23, 11, 0),
      ),
      GridConfigurationData(
        configurationKey: 'currency_code',
        configurationValue: 'AED',
        configurationType: 'Locale',
        validationStatus: true,
        configurationTimestamp: DateTime(2026, 9, 23, 11, 15),
      ),
    ];
  }
}

/// Enum representing MD3 Window Size Classes.
enum Md3WindowSizeClass { compact, medium, expanded }

/// Utility to determine current window size class based on width.
Md3WindowSizeClass getWindowSizeClass(double width) {
  if (width <= kMd3CompactMax) return Md3WindowSizeClass.compact;
  if (width <= kMd3MediumMax) return Md3WindowSizeClass.medium;
  return Md3WindowSizeClass.expanded;
}

/// The primary mobile surgical container wrapper governing all compact view states.
/// Forces flex-direction: column under mobile media breakpoints and applies
/// overflow clipping (overflow-x: hidden equivalent) to block bleeding items.
class MobileSurgicalContainer extends StatelessWidget {
  final List<GridConfigurationData> data;
  final ValueChanged<GridConfigurationData>? onRowTapped;

  const MobileSurgicalContainer({
    super.key,
    required this.data,
    this.onRowTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final Md3WindowSizeClass sizeClass = getWindowSizeClass(maxWidth);

        // Apply dynamic stretch fields (flex-direction: column) under mobile media breakpoints.
        if (sizeClass == Md3WindowSizeClass.compact) {
          return _buildVerticalCardFeed(context, maxWidth);
        }

        // Code a 4-column compact layout grid template for medium/expanded viewports.
        return _buildMultiColumnGrid(context, maxWidth, sizeClass);
      },
    );
  }

  /// Wide multi-column transactional data tables collapse instantly into vertical card feeds on compact displays.
  Widget _buildVerticalCardFeed(BuildContext context, double width) {
    return ClipRect(
      // Forced canvas clipping properties to physically block bleeding items.
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: data.map((item) => _buildDataRowCard(context, item, isMobile: true)).toList(),
        ),
      ),
    );
  }

  /// 4-column compact layout grid template for larger viewports.
  Widget _buildMultiColumnGrid(BuildContext context, double width, Md3WindowSizeClass sizeClass) {
    final int crossAxisCount = sizeClass == Md3WindowSizeClass.medium ? 2 : 4;
    
    return ClipRect(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildDataRowCard(context, data[index], isMobile: false);
        },
      ),
    );
  }

  /// Tapping any data cell highlights the entire row container to lock structural context.
  /// Apply subtle Material row backgrounds to assist reading tracking.
  Widget _buildDataRowCard(BuildContext context, GridConfigurationData item, {required bool isMobile}) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRowTapped?.call(item),
        borderRadius: BorderRadius.circular(12.0),
        splashColor: colorScheme.primary.withOpacity(0.12),
        highlightColor: colorScheme.primary.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // Subtle Material row backgrounds to assist reading tracking
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          child: isMobile
              ? _buildMobileCardContent(context, item, colorScheme)
              : _buildDesktopCardContent(context, item, colorScheme),
        ),
      ),
    );
  }

  Widget _buildMobileCardContent(BuildContext context, GridConfigurationData item, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Utilize explicit text weight choices to prioritize active balance numbers
        Text(
          item.configurationKey.toUpperCase().replaceAll('_', ' '),
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          item.configurationValue,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildValidationChip(item.validationStatus, colorScheme),
            Text(
              item.configurationType,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopCardContent(BuildContext context, GridConfigurationData item, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            item.configurationKey.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          Text(
            item.configurationValue,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          _buildValidationChip(item.validationStatus, colorScheme),
        ],
      ),
    );
  }

  Widget _buildValidationChip(bool isValid, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.primaryContainer.withOpacity(0.5)
            : colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        isValid ? 'Pass' : 'Fail',
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w600,
          color: isValid ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}

/// Example usage widget demonstrating root container state separation.
class MobileResponsiveLayoutScreen extends StatefulWidget {
  const MobileResponsiveLayoutScreen({super.key});

  @override
  State<MobileResponsiveLayoutScreen> createState() => _MobileResponsiveLayoutScreenState();
}

class _MobileResponsiveLayoutScreenState extends State<MobileResponsiveLayoutScreen> {
  late final List<GridConfigurationData> _configurations;

  @override
  void initState() {
    super.initState();
    // Execute configuration data fetches inside root container objects to separate states cleanly.
    _configurations = MockGridConfigurationRepository.fetchConfigurations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Surgical Container'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MobileSurgicalContainer(
            data: _configurations,
            onRowTapped: (item) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${item.configurationKey}')),
              );
            },
          ),
        ),
      ),
    );
  }
}
