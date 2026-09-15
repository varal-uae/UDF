import 'package:flutter/material.dart';
import '../models/step_item.dart';
import '../theme/app_theme_wrapper.dart';
import '../tokens/spacing_tokens.dart';
import 'step_detail_page.dart';

class MasterMenuPage extends StatefulWidget {
  final List<StepItem> steps;
  final WidgetBuilder? fullStreamBuilder;

  const MasterMenuPage({
    super.key,
    required this.steps,
    this.fullStreamBuilder,
  });

  @override
  State<MasterMenuPage> createState() => _MasterMenuPageState();
}

class _MasterMenuPageState extends State<MasterMenuPage> {
  String _searchQuery = '';
  StepCategory _selectedCategory = StepCategory.all;

  List<StepItem> get _filteredSteps {
    return widget.steps.where((step) {
      final matchesCategory = _selectedCategory == StepCategory.all || step.category == _selectedCategory;
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return matchesCategory;

      final matchesQuery = step.stepCode.toLowerCase().contains(query) ||
          step.title.toLowerCase().contains(query) ||
          step.description.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeController = AppThemeController.of(context);
    final filtered = _filteredSteps;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habot Enterprise Step Directory'),
        actions: [
          if (widget.fullStreamBuilder != null)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('All Steps Continuous Stream')),
                      body: widget.fullStreamBuilder!(context),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.view_headline),
              label: const Text('Full View'),
            ),
          PopupMenuButton<AppThemeMode>(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Theme Mode',
            initialValue: themeController.themeMode,
            onSelected: themeController.onThemeModeChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(value: AppThemeMode.system, child: Text('System Theme')),
              PopupMenuItem(value: AppThemeMode.light, child: Text('Light Theme')),
              PopupMenuItem(value: AppThemeMode.dark, child: Text('Dark Theme')),
            ],
          ),
          AppSpacingTokens.hGapSm,
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: CustomScrollView(
            slivers: [
              // Search & Category Filters Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacingTokens.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Banner with Responsive Layout
                      Container(
                        width: double.infinity,
                        padding: AppSpacingTokens.paddingLg,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 700;
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Component Step Library',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      AppSpacingTokens.vGapXs,
                                      Text(
                                        'Select any of the ${widget.steps.length} modular step components below to view its responsive UI & data flow.',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onPrimaryContainer.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isWide) ...[
                                  AppSpacingTokens.hGapLg,
                                  Chip(
                                    avatar: const Icon(Icons.web, size: 18),
                                    label: Text('${screenWidth.toInt()}px Web/Tab Viewport'),
                                    backgroundColor: colorScheme.surface,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      AppSpacingTokens.vGapLg,

                      // Search Input
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search steps by name, Global Ref ID, or Atomic Step ID...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withAlpha(120),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      AppSpacingTokens.vGapMd,

                      // Category Horizontal Scroll Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: StepCategory.values.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                avatar: Icon(
                                  cat.icon,
                                  size: 16,
                                  color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                                ),
                                label: Text(cat.label),
                                selected: isSelected,
                                onSelected: (sel) => setState(() => _selectedCategory = cat),
                                showCheckmark: false,
                                selectedColor: colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      AppSpacingTokens.vGapSm,
                      Text(
                        'Showing ${filtered.length} of ${widget.steps.length} Steps',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              // Steps Grid Layout with Dynamic Responsiveness
              filtered.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_outlined, size: 64, color: colorScheme.outline),
                            AppSpacingTokens.vGapSm,
                            Text('No steps found matching "$_searchQuery"', style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: AppSpacingTokens.paddingMd,
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisExtent: 230,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final step = filtered[index];
                            return Card(
                              elevation: 1,
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StepDetailPage(stepItem: step),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: AppSpacingTokens.paddingMd,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              step.effectiveAtomicCode,
                                              style: theme.textTheme.labelMedium?.copyWith(
                                                color: colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (step.atomicStepCode != null && step.stepCode != step.atomicStepCode) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: colorScheme.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                step.stepCode,
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const Spacer(),
                                          Icon(step.icon, color: colorScheme.primary),
                                        ],
                                      ),
                                      AppSpacingTokens.vGapSm,
                                      Text(
                                        step.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      AppSpacingTokens.vGapXs,
                                      Expanded(
                                        child: Text(
                                          step.description,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      AppSpacingTokens.vGapSm,
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: FilledButton.tonalIcon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => StepDetailPage(stepItem: step),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.arrow_forward, size: 16),
                                          label: const Text('Open Step'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
