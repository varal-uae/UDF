// GEN-01137 — Dynamic Result Count CTA Button.
// Implements dynamic result-count calculation logic that updates the apply CTA button text (e.g., "Show 24 Results") upon filter adjustments using Material 3 ElevatedButton and Bottom Sheet patterns.

import 'package:flutter/material.dart';

/// Mock data representing available items before filtering.
class _MockItem {
  final String id;
  final String category;
  final double price;

  const _MockItem({
    required this.id,
    required this.category,
    required this.price,
  });
}

const List<_MockItem> _kMockItems = [
  _MockItem(id: '1', category: 'Electronics', price: 150.0),
  _MockItem(id: '2', category: 'Electronics', price: 300.0),
  _MockItem(id: '3', category: 'Clothing', price: 50.0),
  _MockItem(id: '4', category: 'Clothing', price: 80.0),
  _MockItem(id: '5', category: 'Home', price: 200.0),
  _MockItem(id: '6', category: 'Home', price: 450.0),
  _MockItem(id: '7', category: 'Electronics', price: 99.0),
  _MockItem(id: '8', category: 'Clothing', price: 120.0),
  _MockItem(id: '9', category: 'Home', price: 75.0),
  _MockItem(id: '10', category: 'Electronics', price: 500.0),
  _MockItem(id: '11', category: 'Clothing', price: 30.0),
  _MockItem(id: '12', category: 'Home', price: 110.0),
  _MockItem(id: '13', category: 'Electronics', price: 220.0),
  _MockItem(id: '14', category: 'Clothing', price: 65.0),
  _MockItem(id: '15', category: 'Home', price: 310.0),
  _MockItem(id: '16', category: 'Electronics', price: 140.0),
  _MockItem(id: '17', category: 'Clothing', price: 90.0),
  _MockItem(id: '18', category: 'Home', price: 180.0),
  _MockItem(id: '19', category: 'Electronics', price: 275.0),
  _MockItem(id: '20', category: 'Clothing', price: 45.0),
  _MockItem(id: '21', category: 'Home', price: 520.0),
  _MockItem(id: '22', category: 'Electronics', price: 85.0),
  _MockItem(id: '23', category: 'Clothing', price: 115.0),
  _MockItem(id: '24', category: 'Home', price: 95.0),
];

/// Controller managing filter state and result count calculation.
class FilterResultController extends ChangeNotifier {
  Set<String> _selectedCategories = {};
  RangeValues _priceRange = const RangeValues(0, 1000);
  int _resultCount = _kMockItems.length;

  int get resultCount => _resultCount;
  Set<String> get selectedCategories => _selectedCategories;
  RangeValues get priceRange => _priceRange;

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _recalculate();
  }

  void updatePriceRange(RangeValues range) {
    _priceRange = range;
    _recalculate();
  }

  void resetFilters() {
    _selectedCategories.clear();
    _priceRange = const RangeValues(0, 1000);
    _recalculate();
  }

  void _recalculate() {
    _resultCount = _kMockItems.where((item) {
      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.contains(item.category);
      final matchesPrice =
          item.price >= _priceRange.start && item.price <= _priceRange.end;
      return matchesCategory && matchesPrice;
    }).length;
    notifyListeners();
  }
}

/// M3 Bottom Sheet widget for configuring filters with dynamic result count.
class DynamicFilterBottomSheet extends StatefulWidget {
  final FilterResultController controller;

  const DynamicFilterBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  State<DynamicFilterBottomSheet> createState() =>
      _DynamicFilterBottomSheetState();
}

class _DynamicFilterBottomSheetState extends State<DynamicFilterBottomSheet> {
  static const List<String> _categories = ['Electronics', 'Clothing', 'Home'];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.titleLarge),
              TextButton(
                onPressed: () => widget.controller.resetFilters(),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((category) {
              final isSelected =
                  widget.controller.selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => widget.controller.toggleCategory(category),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Price Range', style: theme.textTheme.titleMedium),
          RangeSlider(
            values: widget.controller.priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '\$${widget.controller.priceRange.start.round()}',
              '\$${widget.controller.priceRange.end.round()}',
            ),
            onChanged: (values) {
              widget.controller.updatePriceRange(values);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48, // M3 48x48dp touch target minimum
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Show ${widget.controller.resultCount} Results',
                  key: ValueKey<int>(widget.controller.resultCount),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary CTA button that displays the dynamic result count.
class DynamicResultCountCta extends StatelessWidget {
  final FilterResultController controller;

  const DynamicResultCountCta({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SizedBox(
          height: 48, // M3 48x48dp touch target
          child: FilledButton.icon(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (context) => DynamicFilterBottomSheet(
                  controller: controller,
                ),
              );
            },
            icon: const Icon(Icons.tune),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: Text(
                'Show ${controller.resultCount} Results',
                key: ValueKey<int>(controller.resultCount),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        );
      },
    );
  }
}
