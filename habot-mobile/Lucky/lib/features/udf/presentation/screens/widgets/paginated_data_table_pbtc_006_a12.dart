// PBTC-006-A12 — Paginated Mobile Data Table Design.
// Implements a server-side paginated data table with frozen first column, sticky headers, haptic feedback, and thumb-friendly interaction padding for mobile UX.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock data model representing a row in the paginated data table.
class DataTableRecord {
  final String id;
  final String companyExpenseLine;
  final String taxWithholding;
  final double amount;
  final DateTime timestamp;
  final String status;

  const DataTableRecord({
    required this.id,
    required this.companyExpenseLine,
    required this.taxWithholding,
    required this.amount,
    required this.timestamp,
    required this.status,
  });
}

/// Mock repository simulating server-side chunked data fetching (e.g., BigQuery).
class MockPaginatedRepository {
  static const int _pageSize = 20;

  /// Generates realistic local mock data directly to avoid backend dependency.
  Future<List<DataTableRecord>> fetchChunk(int page) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 400));

    final List<DataTableRecord> chunk = [];
    final int startIndex = page * _pageSize;

    for (int i = 0; i < _pageSize; i++) {
      final int index = startIndex + i;
      chunk.add(DataTableRecord(
        id: 'REC-${index.toString().padLeft(5, '0')}',
        companyExpenseLine: 'Expense Category ${(index % 5) + 1}',
        taxWithholding: 'Tax Code ${(index % 3) + 1}',
        amount: 100.0 + (index * 12.5),
        timestamp: DateTime.now().subtract(Duration(hours: index)),
        status: index % 4 == 0 ? 'Pending' : 'Posted',
      ));
    }
    return chunk;
  }

  int get pageSize => _pageSize;
}

/// A reusable, mobile-first paginated data table component.
/// Features:
/// - Frozen first column and sticky headers via z-index layering.
/// - Horizontal and vertical scrolling with lightweight DOM/render tree.
/// - Haptic motor triggers on successful pagination fetches.
/// - Distinct, bold typographical traits splitting expense lines from tax withholdings.
/// - Explicit interaction button padding protecting user thumb reach.
/// - Flexbox-equivalent layouts maintaining numerical cell scannability.
/// - Self-chasing "1 of X Pages" pagination text flash at bottom boundary.
class PaginatedMobileDataTable extends StatefulWidget {
  const PaginatedMobileDataTable({super.key});

  @override
  State<PaginatedMobileDataTable> createState() => _PaginatedMobileDataTableState();
}

class _PaginatedMobileDataTableState extends State<PaginatedMobileDataTable>
    with SingleTickerProviderStateMixin {
  final MockPaginatedRepository _repository = MockPaginatedRepository();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  List<DataTableRecord> _records = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _showPageFlash = false;

  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );

    _verticalScrollController.addListener(_onVerticalScroll);
    _fetchNextChunk();
  }

  void _onVerticalScroll() {
    if (_verticalScrollController.position.pixels >=
        _verticalScrollController.position.maxScrollExtent - 50) {
      if (!_isLoading && _hasMore) {
        _triggerSelfChasingFlash();
        _fetchNextChunk();
      }
    }
  }

  Future<void> _triggerSelfChasingFlash() async {
    setState(() => _showPageFlash = true);
    await _flashController.forward();
    await _flashController.reverse();
    setState(() => _showPageFlash = false);
  }

  Future<void> _fetchNextChunk() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final chunk = await _repository.fetchChunk(_currentPage);

      // Utilize clear haptic motor triggers inside mobile apps to alert users
      // immediately when postings successfully execute.
      await HapticFeedback.mediumImpact();

      if (!mounted) return;

      setState(() {
        _records.addAll(chunk);
        _currentPage++;
        _isLoading = false;
        // Stop after 5 pages for demonstration purposes
        if (_currentPage >= 5) _hasMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _verticalScrollController.removeListener(_onVerticalScroll);
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated Data Table'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sticky Header Row (position: sticky; z-index: 10 equivalent)
          Material(
            elevation: 2.0,
            color: colorScheme.surfaceContainerHighest,
            child: SizedBox(
              height: 56.0,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildHeaderCell('ID', width: 100, isFrozen: true, theme: theme),
                    _buildHeaderCell('Expense Line', width: 180, theme: theme),
                    _buildHeaderCell('Tax Withholding', width: 160, theme: theme),
                    _buildHeaderCell('Amount', width: 120, theme: theme),
                    _buildHeaderCell('Timestamp', width: 160, theme: theme),
                    _buildHeaderCell('Status', width: 120, theme: theme),
                  ],
                ),
              ),
            ),
          ),

          // Data Body with horizontal scrolling and frozen first column
          Expanded(
            child: Stack(
              children: [
                // Horizontally scrollable data cells
                ListView.builder(
                  controller: _verticalScrollController,
                  itemCount: _records.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _records.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final record = _records[index];
                    return _buildDataRow(record, theme, colorScheme);
                  },
                ),

                // Frozen First Column Overlay (z-index: 10)
                IgnorePointer(
                  ignoring: true,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Container(
                        width: 100,
                        height: 56.0,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border(
                            bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                          ),
                        ),
                        child: Text(
                          record.id,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Self-Chasing Pagination Indicator & Interaction Button
          AnimatedBuilder(
            animation: _flashAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _showPageFlash ? _flashAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showPageFlash)
                    Text(
                      'Page $_currentPage of ${_currentPage + (_hasMore ? 1 : 0)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 12.0),
                  // Enforce explicit interaction button padding settings on phone menus
                  // to protect user thumb reach.
                  SizedBox(
                    width: double.infinity,
                    height: 56.0, // Thumb-friendly minimum touch target
                    child: FilledButton.icon(
                      onPressed: _hasMore && !_isLoading ? _fetchNextChunk : null,
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: Text(_hasMore ? 'Load Next Chunk' : 'All Data Loaded'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(DataTableRecord record, ThemeData theme, ColorScheme colorScheme) {
    // Leverage clean flexbox layouts to maintain numerical cell scannability on compact scales.
    return SizedBox(
      height: 56.0,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Spacer for frozen column
            const SizedBox(width: 100),
            _buildDataCell(
              record.companyExpenseLine,
              width: 180,
              theme: theme,
              // Choose distinct, bold typographical traits to split company expense lines
              isBold: true,
            ),
            _buildDataCell(
              record.taxWithholding,
              width: 160,
              theme: theme,
              textColor: colorScheme.secondary,
            ),
            _buildDataCell(
              '\$${record.amount.toStringAsFixed(2)}',
              width: 120,
              theme: theme,
              isNumeric: true,
            ),
            _buildDataCell(
              _formatTimestamp(record.timestamp),
              width: 160,
              theme: theme,
            ),
            _buildDataCell(
              record.status,
              width: 120,
              theme: theme,
              textColor: record.status == 'Posted' ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required double width, bool isFrozen = false, required ThemeData theme}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    required ThemeData theme,
    bool isBold = false,
    bool isNumeric = false,
    Color? textColor,
  }) {
    return Container(
      width: width,
      alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: textColor ?? theme.colorScheme.onSurface,
          fontFeatures: isNumeric ? const [FontFeature.tabularFigures()] : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
