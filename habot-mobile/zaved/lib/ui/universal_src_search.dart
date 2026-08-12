import 'package:flutter/material.dart';

class UniversalSRCSearch extends StatelessWidget {
  const UniversalSRCSearch({super.key});

  static const List<String> _srcSuggestions = [
    'Primary Button',
    'Status Badge',
    'Error Toast',
    'Payment Status Banner',
    'Input Field',
    'Navigation Bar',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800.0,
          minHeight: 48.0,
        ),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: const Icon(Icons.search),
              hintText: 'Search Universal SRC Registry...',
            );
          },
          suggestionsBuilder: (
            BuildContext context,
            SearchController controller,
          ) {
            final keyword = controller.text.toLowerCase();
            final filteredItems = _srcSuggestions.where(
              (item) => item.toLowerCase().contains(keyword),
            );

            return filteredItems.map((String item) {
              // STRICT ACCESSIBILITY RULE: Enforce exactly 48dp height touch target for items
              return SizedBox(
                height: 48.0,
                child: ListTile(
                  title: Text(item),
                  onTap: () {
                    controller.closeView(item);
                  },
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
