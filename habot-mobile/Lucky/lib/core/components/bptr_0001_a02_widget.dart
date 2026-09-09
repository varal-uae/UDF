// BPTR-0001-A02 — Paginated Data Table Design: Reusable, touch-friendly paginated data table with sticky headers, right-aligned numeric columns, page controls, and visual state tracking.
// Supports responsive card view on narrow screens, rows-per-page selector, and swipe gestures to navigate pages.

import 'package:flutter/material.dart';

/// A data column definition for [Bptr0001A02PaginatedDataTable].
class Bptr0001A02DataColumn {
  final String label;
  final bool isNumeric;
  final int flex;
  const Bptr0001A02DataColumn({required this.label, this.isNumeric = false, this.flex = 1});
}

/// Reusable paginated data table component.
class Bptr0001A02PaginatedDataTable extends StatefulWidget {
  final List<Bptr0001A02DataColumn> columns;
  final List<List<Object?>> rows;
  final int initialRowsPerPage;
  final List<int> allowedRowsPerPage;
  final ValueChanged<int>? onRowTap;

  const Bptr0001A02PaginatedDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.initialRowsPerPage = 10,
    this.allowedRowsPerPage = const [5, 10, 20, 50],
    this.onRowTap,
  }) : assert(initialRowsPerPage > 0),
       assert(allowedRowsPerPage.contains(initialRowsPerPage));

  @override
  State<Bptr0001A02PaginatedDataTable> createState() => _Bptr0001A02PaginatedDataTableState();
}

class _Bptr0001A02PaginatedDataTableState extends State<Bptr0001A02PaginatedDataTable> {
  late int _currentPage;
  late int _rowsPerPage;
  int? _selectedRowIndex;

  int get _totalPages => (widget.rows.length / _rowsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.initialRowsPerPage;
    _currentPage = 0;
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(0, _totalPages - 1);
    });
  }

  void _onRowsPerPageChanged(int? value) {
    if (value == null) return;
    setState(() {
      _rowsPerPage = value;
      _currentPage = 0;
    });
  }

  List<List<Object?>> get _visibleRows {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  List<int> _getPageNumbers() {
    final total = _totalPages;
    if (total <= 7) return List.generate(total, (i) => i);
    final pages = <int>{0, total - 1, _currentPage};
    if (_currentPage > 0) pages.add(_currentPage - 1);
    if (_currentPage < total - 1) pages.add(_currentPage + 1);
    final sorted = pages.toList()..sort();
    return sorted;
  }

  Widget _buildPaginationControls() {
    final total = _totalPages;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text('Rows per page:'),
          SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            items: widget.allowedRowsPerPage
                .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                .toList(),
            onChanged: _onRowsPerPageChanged,
          ),
          Spacer(),
          IconButton(
            tooltip: 'First page',
            icon: Icon(Icons.first_page),
            onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
          ),
          IconButton(
            tooltip: 'Previous page',
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
          ),
          ..._buildPageNumberButtons(_getPageNumbers(), total),
          IconButton(
            tooltip: 'Next page',
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage < total - 1 ? () => _goToPage(_currentPage + 1) : null,
          ),
          IconButton(
            tooltip: 'Last page',
            icon: Icon(Icons.last_page),
            onPressed: _currentPage < total - 1 ? () => _goToPage(total - 1) : null,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumberButtons(List<int> pages, int total) {
    final widgets = <Widget>[];
    for (int i = 0; i < pages.length; i++) {
      if (i > 0 && pages[i] - pages[i - 1] > 1) {
        widgets.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('…'),
        ));
      }
      final page = pages[i];
      widgets.add(
        TextButton(
          onPressed: page == _currentPage ? null : () => _goToPage(page),
          style: TextButton.styleFrom(
            minimumSize: Size(32, 32),
            padding: EdgeInsets.zero,
            backgroundColor: page == _currentPage ? Theme.of(context).colorScheme.primaryContainer : null,
          ),
          child: Text('${page + 1}'),
        ),
      );
    }
    return widgets;
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: widget.columns.map((col) {
          return Expanded(
            flex: col.flex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                col.label,
                textAlign: col.isNumeric ? TextAlign.end : TextAlign.start,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRow(List<Object?> row, int globalIndex) {
    final isSelected = _selectedRowIndex == globalIndex;
    return InkWell(
      onTap: widget.onRowTap == null ? null : () {
        setState(() {
          _selectedRowIndex = globalIndex;
        });
        widget.onRowTap!(globalIndex);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
        ),
        child: Row(
          children: List.generate(widget.columns.length, (colIndex) {
            final col = widget.columns[colIndex];
            final value = row[colIndex].toString();
            return Expanded(
              flex: col.flex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  value,
                  textAlign: col.isNumeric ? TextAlign.end : TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileCard(List<Object?> row, int globalIndex) {
    final isSelected = _selectedRowIndex == globalIndex;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: widget.onRowTap == null ? null : () {
          setState(() {
            _selectedRowIndex = globalIndex;
          });
          widget.onRowTap!(globalIndex);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.columns.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.columns[i].label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          row[i].toString(),
                          textAlign: widget.columns[i].isNumeric ? TextAlign.end : TextAlign.start,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRows = _visibleRows;
    return Column(
      children: [
        _buildHeaderRow(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < 0 && _currentPage < _totalPages - 1) {
                    _goToPage(_currentPage + 1);
                  } else if (details.primaryVelocity! > 0 && _currentPage > 0) {
                    _goToPage(_currentPage - 1);
                  }
                },
                child: isMobile
                    ? ListView.builder(
                        itemCount: visibleRows.length,
                        itemBuilder: (context, index) {
                          final globalIndex = _currentPage * _rowsPerPage + index;
                          return _buildMobileCard(visibleRows[index], globalIndex);
                        },
                      )
                    : ListView.builder(
                        itemCount: visibleRows.length,
                        itemBuilder: (context, index) {
                          final globalIndex = _currentPage * _rowsPerPage + index;
                          return _buildDataRow(visibleRows[index], globalIndex);
                        },
                      ),
              );
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }
}