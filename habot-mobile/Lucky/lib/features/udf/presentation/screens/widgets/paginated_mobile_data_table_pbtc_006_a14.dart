// PBTC-006-A14 — Paginated Mobile Data Table with Sticky Headers and Frozen Columns.
// Implements server-side paginated data table UI with sticky headers, frozen first column, haptic feedback, and bold typography for expense lines.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock execution record representing a row in the data table.
class _MockExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double companyExpense;
  final double taxWithholding;

  const _MockExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.companyExpense,
    required this.taxWithholding,
  });
}

/// Generates mock data simulating server-side BigQuery chunks.
List<_MockExecutionRecord> _generateMockData(int page, int pageSize) {
  return List.generate(pageSize, (index) {
    final globalIndex = (page * pageSize) + index + 1;
    return _MockExecutionRecord(
      stepExecutionId: 'EXEC-$globalIndex',
      executionStatus: globalIndex % 5 == 0 ? 'Failed' : 'Passed',
      executionTimestamp: DateTime.now().subtract(Duration(hours: globalIndex)),
      stepOutcome: globalIndex % 5 == 0 ? 'Error Code 500' : 'Success',
      userId: 'USR-${(globalIndex % 20) + 1}',
      companyExpense: (globalIndex * 125.50),
      taxWithholding: (globalIndex * 18.75),
    );
  });
}

/// A reusable mobile-first paginated data table widget.
/// Features:
/// - Sticky headers via SliverAppBar/slivers or fixed header row.
/// - Frozen first column using nested Row/ListView structure.
/// - Haptic motor triggers on pagination success.
/// - Bold typographical traits to split company expenses from tax withholdings.
/// - Explicit interaction button padding for thumb reach.
class PaginatedMobileDataTable extends StatefulWidget {
  const PaginatedMobileDataTable({super.key});

  @override
  State<PaginatedMobileDataTable> createState() => _PaginatedMobileDataTableState();
}

class _PaginatedMobileDataTableState extends State<PaginatedMobileDataTable> {
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _isLoading = false;
  List<_MockExecutionRecord> _records = [];
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    setState(() => _isLoading = true);
    // Simulate network latency for server-side pagination
    await Future.delayed(const Duration(milliseconds: 600));
    
    final newData = _generateMockData(page, _pageSize);
    
    setState(() {
      _records = newData;
      _currentPage = page;
      _isLoading = false;
    });

    // Enforce explicit haptic motor triggers inside mobile apps to alert users immediately when postings successfully execute
    if (mounted && newData.isNotEmpty) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execution Records'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // STICKY HEADER ROW
          Container(
            color: colorScheme.surfaceContainerHighest,
            // z-index equivalent in Flutter is managed by rendering order / Material elevation
            child: _buildTableRow(
              context: context,
              isHeader: true,
              record: null,
            ),
          ),
          // DATA BODY
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const Center(child: Text('No data available.'))
                    : ListView.builder(
                        controller: _verticalScrollController,
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          return _buildTableRow(
                            context: context,
                            isHeader: false,
                            record: _records[index],
                          );
                        },
                      ),
          ),
          // PAGINATION CONTROLS WITH THUMB REACH PADDING
          SafeArea(
            top: false,
            child: Padding(
              // Enforce explicit interaction button padding settings on phone menus to protect user thumb reach
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: _currentPage > 0 && !_isLoading
                        ? () => _loadPage(_currentPage - 1)
                        : null,
                    child: const Text('Previous'),
                  ),
                  // Self-Chasing: "1 of X Pages" pagination text flashes briefly
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Page ${_currentPage + 1}',
                      key: ValueKey<int>(_currentPage),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: !_isLoading ? () => _loadPage(_currentPage + 1) : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single row with a frozen first column and horizontally scrollable remaining cells.
  Widget _buildTableRow({
    required BuildContext context,
    required bool isHeader,
    required _MockExecutionRecord? record,
  }) {
    final theme = Theme.of(context);
    final textStyle = isHeader
        ? theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;

    // Choose distinct, bold typographical traits to split company expense lines from tax withholdings legibly
    final expenseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.primary,
    );
    final taxStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.error,
    );

    const double frozenColWidth = 110.0;
    const double cellWidth = 130.0;
    const double rowHeight = 56.0;

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // FROZEN FIRST COLUMN
          Container(
            width: frozenColWidth,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: isHeader ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
              border: Border(
                right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
                bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
              ),
            ),
            child: Text(
              isHeader ? 'Exec ID' : (record?.stepExecutionId ?? ''),
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // HORIZONTALLY SCROLLABLE DATA CELLS
          // Leverage clean flexbox layouts to maintain numerical cell scannability on compact scales
          Expanded(
            child: ListView(
              controller: isHeader ? null : _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              children: [
                _buildCell('Status', record?.executionStatus ?? '', textStyle, cellWidth, isHeader, theme),
                _buildCell('Timestamp', isHeader ? 'Timestamp' : _formatDate(record!.executionTimestamp), textStyle, cellWidth + 30, isHeader, theme),
                _buildCell('Outcome', record?.stepOutcome ?? '', textStyle, cellWidth, isHeader, theme),
                _buildCell('User ID', record?.userId ?? '', textStyle, cellWidth, isHeader, theme),
                _buildCell(
                  'Company Expense',
                  isHeader ? 'Company Exp.' : '\$${record!.companyExpense.toStringAsFixed(2)}',
                  isHeader ? textStyle : expenseStyle,
                  cellWidth,
                  isHeader,
                  theme,
                ),
                _buildCell(
                  'Tax Withheld',
                  isHeader ? 'Tax Withheld' : '\$${record!.taxWithholding.toStringAsFixed(2)}',
                  isHeader ? textStyle : taxStyle,
                  cellWidth,
                  isHeader,
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String headerText, String value, TextStyle? style, double width, bool isHeader, ThemeData theme) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: isHeader ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Text(
        isHeader ? headerText : value,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
