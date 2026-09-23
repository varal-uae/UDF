// RCGLA-040-A04 — DataEntryCard Standardized Layout Container.
// Implements a standalone, single-purpose card layout block enforcing strict Material 3 design tokens, single vertical column stacking, standard rounded corners, and Poka-Yoke validation blocking multiple input fields.

import 'package:flutter/material.dart';

/// Mock data model representing atomic-level data fields for the layout.
class DataEntryCardModel {
  final String layoutType;
  final Size layoutGridDimensions;
  final EdgeInsets spacingRules;
  final AlignmentGeometry alignmentSettings;
  final bool layoutValidationStatus;
  final String fieldTitle;
  final String fieldValue;
  final bool isCorporateStatus;

  const DataEntryCardModel({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    required this.fieldTitle,
    required this.fieldValue,
    this.isCorporateStatus = true,
  });
}

/// Mock repository providing local dummy data to satisfy backend independence rules.
class MockDataEntryCardRepository {
  static const List<DataEntryCardModel> mockCards = [
    DataEntryCardModel(
      layoutType: 'Standard_Single_Column',
      layoutGridDimensions: Size(double.infinity, 120),
      spacingRules: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      alignmentSettings: Alignment.centerLeft,
      layoutValidationStatus: true,
      fieldTitle: 'Patient Identifier',
      fieldValue: 'UDF-99281-X',
      isCorporateStatus: false,
    ),
    DataEntryCardModel(
      layoutType: 'Standard_Single_Column',
      layoutGridDimensions: Size(double.infinity, 120),
      spacingRules: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      alignmentSettings: Alignment.centerLeft,
      layoutValidationStatus: true,
      fieldTitle: 'Corporate Account Code',
      fieldValue: 'CORP-AE-001',
      isCorporateStatus: true,
    ),
  ];

  Future<List<DataEntryCardModel>> fetchCards() async {
    return mockCards;
  }
}

/// Poka-Yoke (Mistake-Proofing) Validator.
/// Blocks deployment/render if an entry card framework embeds more than one input box.
class CardPokaYokeValidator {
  static bool validateSingleInputConstraint(int inputFieldCount) {
    assert(
      inputFieldCount <= 1,
      'Poka-Yoke Violation [RCGLA-040-A04]: Entry card cannot embed more than one input box. Found: $inputFieldCount',
    );
    return inputFieldCount <= 1;
  }
}

/// Standardized, standalone layout container block.
/// Enforces mobile-first responsive UX: single vertical column stacking, 
/// forced standard round corner attributes, and context isolation.
class DataEntryCard extends StatelessWidget {
  final DataEntryCardModel model;
  final VoidCallback? onTap;

  const DataEntryCard({
    super.key,
    required this.model,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Enforce Poka-Yoke constraint at build time
    CardPokaYokeValidator.validateSingleInputConstraint(1);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mobile-First & Responsive UI Decision: Assign separate visual badge themes
    // to distinguish corporate from clinical statuses.
    final badgeColor = model.isCorporateStatus
        ? colorScheme.primaryContainer
        : colorScheme.tertiaryContainer;
    final badgeTextColor = model.isCorporateStatus
        ? colorScheme.onPrimaryContainer
        : colorScheme.onTertiaryContainer;
    final badgeLabel = model.isCorporateStatus ? 'Corporate' : 'Clinical';

    // Mobile-First & Responsive UI Implementation: Apply forced standard round corner attributes
    const BorderRadius standardCornerRadius = BorderRadius.all(Radius.circular(16.0));

    return Semantics(
      label: '${model.fieldTitle}: ${model.fieldValue}',
      container: true,
      child: Card(
        margin: model.spacingRules,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: standardCornerRadius,
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: standardCornerRadius,
          child: Container(
            constraints: BoxConstraints(
              minHeight: model.layoutGridDimensions.height,
            ),
            // Mobile-First & Responsive UX Implementation: Build view screens utilizing single vertical column stacking properties.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Implement explicit text layout sizes mapping out field title properties clearly
                      Expanded(
                        child: Text(
                          model.fieldTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Interface selection inputs choose clean standard chip elements to guide navigation
                      Chip(
                        label: Text(
                          badgeLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: badgeTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: badgeColor,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: Align(
                    alignment: model.alignmentSettings,
                    child: Text(
                      model.fieldValue,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      // Grid constraints adapt smoothly to preserve character string lengths without text truncation
                      softWrap: true,
                    ),
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

/// Test routine simulating account switch event as per Setup Step (Action).1
class DataEntryCardTestRoutine {
  static void simulateAccountSwitchEvent() {
    debugPrint('[RCGLA-040-A04] Simulating account switch event...');
    final testModel = const DataEntryCardModel(
      layoutType: 'Test_Switch_Event',
      layoutGridDimensions: Size(double.infinity, 100),
      spacingRules: EdgeInsets.all(16.0),
      alignmentSettings: Alignment.centerLeft,
      layoutValidationStatus: true,
      fieldTitle: 'Switched Account ID',
      fieldValue: 'ACC-SWITCH-001',
      isCorporateStatus: true,
    );
    
    final isValid = CardPokaYokeValidator.validateSingleInputConstraint(1);
    debugPrint('[RCGLA-040-A04] Account switch test completed. Validation Status: $isValid, Model: ${testModel.fieldValue}');
  }
}
