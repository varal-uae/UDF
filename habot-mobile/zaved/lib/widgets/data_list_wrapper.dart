import 'package:flutter/material.dart';
import 'empty_state_boilerplate.dart';

/// Generic conditional wrapper ensuring empty data lists render EmptyStateBoilerplate instead of blank screen.
class DataListWrapper<T> extends StatelessWidget {
  const DataListWrapper({
    super.key,
    required this.data,
    required this.child,
    required this.emptyState,
  });

  /// Input dataset
  final List<T> data;

  /// Content to display when dataset is non-empty
  final Widget child;

  /// Empty state boilerplate to render when dataset is empty
  final EmptyStateBoilerplate emptyState;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return emptyState;
    }
    return child;
  }
}
