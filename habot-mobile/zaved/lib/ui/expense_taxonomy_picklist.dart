import 'package:flutter/material.dart';

/// 1. Sample Enum with 12 mock expense taxonomy categories
enum ExpenseCategory {
  travel('Travel & Transportation'),
  mealsAndEntertainment('Meals & Entertainment'),
  officeSupplies('Office Supplies'),
  softwareSubscriptions('Software & SaaS Subscriptions'),
  hardwareAndEquipment('Hardware & Equipment'),
  professionalServices('Professional Services & Legal'),
  marketingAndAdvertising('Marketing & Advertising'),
  utilities('Utilities & Energy'),
  rentAndFacilities('Rent & Facilities'),
  trainingAndEducation('Training & Education'),
  telecommunications('Telecommunications & Mobile'),
  miscellaneous('Miscellaneous Expenses');

  const ExpenseCategory(this.displayName);
  final String displayName;
}

/// Expense Taxonomy Picklist enforcing strict Enum selection, read-only trigger, and submit freeze Poka-Yoke.
class ExpenseTaxonomyPicklist extends StatefulWidget {
  const ExpenseTaxonomyPicklist({
    super.key,
    this.onCategorySubmitted,
  });

  final ValueChanged<ExpenseCategory>? onCategorySubmitted;

  @override
  State<ExpenseTaxonomyPicklist> createState() =>
      _ExpenseTaxonomyPicklistState();
}

class _ExpenseTaxonomyPicklistState extends State<ExpenseTaxonomyPicklist> {
  ExpenseCategory? _selectedCategory;
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// 2. Opens bottom sheet on read-only field tap
  void _openCategoryPicker(BuildContext context) {
    showModalBottomSheet<ExpenseCategory>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext sheetContext) {
        return _CategoryPickerBottomSheet(
          selectedCategory: _selectedCategory,
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _selectedCategory = selected;
          _inputController.text = selected.displayName;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 2. Read-Only Trigger TextField with 48.0 minHeight
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: TextField(
            controller: _inputController,
            readOnly: true, // Discards manual keyboard typing
            onTap: () => _openCategoryPicker(context),
            decoration: const InputDecoration(
              labelText: 'Expense Category Taxonomy',
              hintText: 'Tap to select expense category...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
              suffixIcon: Icon(Icons.arrow_drop_down),
              helperText: 'Must be selected from authorized Enum picklist',
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // 4. Poka-Yoke (Submit Freeze): onPressed is set to null (disabled) if _selectedCategory is null
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: _selectedCategory != null
                ? () {
                    if (widget.onCategorySubmitted != null) {
                      widget.onCategorySubmitted!(_selectedCategory!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Expense Category Submitted: ${_selectedCategory!.displayName}',
                        ),
                      ),
                    );
                  }
                : null, // Dynamically freeze submit action when selection is null
            icon: const Icon(Icons.send),
            label: Text(
              _selectedCategory != null
                  ? 'Submit Expense (${_selectedCategory!.name})'
                  : 'Submit Expense (Select Category First)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

/// 3. Smart Bottom Sheet with filter search bar and large touch target ListTiles
class _CategoryPickerBottomSheet extends StatefulWidget {
  const _CategoryPickerBottomSheet({
    required this.selectedCategory,
  });

  final ExpenseCategory? selectedCategory;

  @override
  State<_CategoryPickerBottomSheet> createState() =>
      __CategoryPickerBottomSheetState();
}

class __CategoryPickerBottomSheetState
    extends State<_CategoryPickerBottomSheet> {
  String _searchQuery = '';

  List<ExpenseCategory> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) {
      return ExpenseCategory.values;
    }
    return ExpenseCategory.values.where((category) {
      return category.displayName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.0,
            height: 4.0,
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Text(
            'Select Expense Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),

          // 3. Filter TextField at top of bottom sheet
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ),
          const SizedBox(height: 12.0),

          // 3. Filtered ListView of ListTile options
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      'No matching categories found.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = widget.selectedCategory == category;

                      return ListTile(
                        title: Text(
                          category.displayName,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        // 3. Trailing check icon ONLY on currently selected item
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop(category);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
