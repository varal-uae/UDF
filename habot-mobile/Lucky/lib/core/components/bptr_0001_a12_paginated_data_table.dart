// BPTR-0001-A12 — Paginated Data Table Component with rows-per-page dropdown change handler.
// Reusable Material 3 paginated data table for mobile touch targets and pagination controls.
import 'package:flutter/material.dart';

/// A reusable paginated data table that attaches a change event handler
/// to the rows-per-page dropdown selector, supporting mobile-first layouts.
class Bptr0001A12PaginatedDataTable extends StatefulWidget {
  const Bptr0001A12PaginatedDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.initialRowsPerPage = 10,
    this.rowsPerPageOptions = const [10, 20, 50],
    this.onRowsPerPageChanged,
    this.onPageChanged,
    this.title,
    this.showCheckboxColumn = false,
  });

  final List<DataColumn> columns;
  final DataTableSource source;
  final int initialRowsPerPage;
  final List<int> rowsPerPageOptions;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final ValueChanged<int>? onPageChanged;
  final String? title;
  final bool showCheckboxColumn;

  @override
  State<Bptr0001A12PaginatedDataTable> createState() =>
      _Bptr0001A12PaginatedDataTableState();
}

class _Bptr0001A12PaginatedDataTableState
    extends State<Bptr0001A12PaginatedDataTable> {
  late int _rowsPerPage;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.initialRowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      columns: widget.columns,
      source: widget.source,
      rowsPerPage: _rowsPerPage,
      availableRowsPerPage: widget.rowsPerPageOptions,
      onRowsPerPageChanged: _handleRowsPerPageChanged,
      onPageChanged: widget.onPageChanged,
      header: widget.title == null ? null : Text(widget.title!),
      showFirstLastButtons: true,
      showCheckboxColumn: widget.showCheckboxColumn,
      horizontalMargin: 12,
      columnSpacing: 24,
      dataRowHeight: 48,
      headingRowHeight: 56,
    );
  }

  void _handleRowsPerPageChanged(int? value) {
    setState(() {
      _rowsPerPage = value ?? widget.initialRowsPerPage;
    });
    widget.onRowsPerPageChanged?.call(value);
  }
}