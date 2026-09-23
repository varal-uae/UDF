// PBTC-006-A02 — Paginated Mobile Data Table with Sticky Headers and Frozen First Column.
// Implements server-side paginated data table UI with sticky headers, frozen first column, haptic feedback, bold typography for financial data, thumb-friendly padding, and self-chasing pagination indicator.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data representing BigQuery chunked results for execution steps.
class _MockStepRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double companyExpense;
  final double taxWithholding;

  const _MockStepRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.companyExpense,
    required this.taxWithholding,
  });
}

/// Generates realistic local mock data to simulate server-side pagination chunks.
List<_MockStepRecord> _generateMockData(int page, int pageSize) {
  return List.generate(pageSize, (index) {
    final globalIndex = (page * pageSize) + index + 1;
    return _MockStepRecord(
      stepExecutionId: 'EXEC-$globalIndex',
      executionStatus: globalIndex % 5 == 0 ? 'Failed' : 'Success',
      executionTimestamp: DateTime.now().subtract(Duration(hours: globalIndex)),
      stepOutcome: globalIndex % 5 == 0 ? 'Timeout Error' : 'Completed Normally',
      userId: 'USR-${(globalIndex % 10) + 1}',
      companyExpense: 1500.00 + (globalIndex * 12.5),
      taxWithholding: 225.00 + (globalIndex * 1.87),
    );
  });
}

class PaginatedMobileDataTablePbtc006A02 extends StatefulWidget {
  const PaginatedMobileDataTablePbtc006A02({super.key});

  @override
  State<PaginatedMobileDataTablePbtc006A02> createState() => _PaginatedMobileDataTablePbtc006A02State();
}

class _PaginatedMobileDataTablePbtc006A02State extends State<PaginatedMobileDataTablePbtc006A02> {
  static const int _pageSize = 20;
  static const int _totalPages = 5; // Simulating total pages from backend
  
  int _currentPage = 0;
  bool _isLoading = false;
  bool _showChasingIndicator = false;
  List<_MockStepRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading || page >= _totalPages) return;

    setState(() {
      _isLoading = true;
      _showChasingIndicator = false;
    });

    // Simulate network latency for server-side pagination chunking
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _records = _generateMockData(page, _pageSize);
      _currentPage = page;
      _isLoading = false;
    });

    // Haptic motor trigger on successful data load/posting
    HapticFeedback.mediumImpact();
  }

  void _onScrollEnd() {
    // Self-Chasing: Flash "1 of X Pages" briefly when reaching bottom
    if (!_isLoading && _currentPage < _totalPages - 1) {
      setState(() => _showChasingIndicator = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showChasingIndicator = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execution Steps'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sticky Header Row (Frozen)
          Material(
            elevation: 4.0,
            zIndex: 10, // Enforcing z-index requirement conceptually via elevation
            child: Container(
              color: theme.colorScheme.surface,
              height: 56.0,
              child: Row(
                children: [
                  // Frozen First Column Header
                  Container(
                    width: 120.0,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: theme.dividerColor)),
                    ),
                    child: Text(
                      'Exec ID',
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Horizontally Scrollable Headers
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildHeaderCell('Status', textTheme),
                          _buildHeaderCell('Timestamp', textTheme),
                          _buildHeaderCell('Outcome', textTheme),
                          _buildHeaderCell('User ID', textTheme),
                          _buildHeaderCell('Company Expense', textTheme),
                          _buildHeaderCell('Tax Withholding', textTheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Data Body
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification) {
                  _onScrollEnd();
                }
                return false;
              },
              child: _isLoading && _records.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _records.length + 1, // +1 for bottom pagination button
                      itemBuilder: (context, index) {
                        if (index == _records.length) {
                          return _buildPaginationFooter(theme);
                        }
                        return _buildDataRow(_records[index], theme, textTheme);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, TextTheme textTheme) {
    return Container(
      width: 140.0,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDataRow(_MockStepRecord record, ThemeData theme, TextTheme textTheme) {
    return SizedBox(
      height: 64.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Frozen First Column Data
          Container(
            width: 120.0,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor.withAlpha(50))),
              color: theme.colorScheme.surface,
            ),
            child: Text(
              record.stepExecutionId,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // Horizontally Scrollable Data Cells (Flexbox layout equivalent)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDataCell(record.executionStatus, textTheme, isStatus: true),
                  _buildDataCell(record.executionTimestamp.toString().substring(0, 19), textTheme),
                  _buildDataCell(record.stepOutcome, textTheme),
                  _buildDataCell(record.userId, textTheme),
                  // Distinct, bold typographical traits to split company expense lines from tax withholdings
                  _buildDataCell('\$${record.companyExpense.toStringAsFixed(2)}', textTheme, isFinancial: true),
                  _buildDataCell('\$${record.taxWithholding.toStringAsFixed(2)}', textTheme, isFinancial: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String value, TextTheme textTheme, {bool isFinancial = false, bool isStatus = false}) {
    TextStyle? style = textTheme.bodyMedium;
    
    if (isFinancial) {
      style = style?.copyWith(
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
    } else if (isStatus) {
      style = style?.copyWith(
        color: value == 'Failed' ? Colors.redAccent : Colors.green,
        fontWeight: FontWeight.w600,
      );
    }

    return Container(
      width: 140.0,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(value, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildPaginationFooter(ThemeData theme) {
    return Padding(
      // Explicit interaction button padding settings to protect user thumb reach
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          // Self-Chasing Indicator
          AnimatedOpacity(
            opacity: _showChasingIndicator ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '${_currentPage + 1} of $_totalPages Pages',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          if (_currentPage < _totalPages - 1)
            SizedBox(
              width: double.infinity,
              height: 56.0, // Thumb-friendly height
              child: FilledButton.icon(
                onPressed: _isLoading ? null : () => _loadPage(_currentPage + 1),
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.arrow_downward),
                label: Text(_isLoading ? 'Loading Chunk...' : 'Load Next Page'),
              ),
            )
          else
            Text('All data loaded.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
