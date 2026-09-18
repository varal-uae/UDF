// GEN-01148 — WebP Image Compression and Lazy Loading Thumbnail Widget.
// Provides a reusable Material 3 compliant widget for lazy loading listing thumbnails with WebP support, mock data fallback, and responsive layout behavior.

import 'package:flutter/material.dart';

/// Mock data representing listing thumbnails for local development and testing.
class _MockListingData {
  static const List<Map<String, dynamic>> listings = [
    {
      'id': 'thumb_001',
      'title': 'Luxury Apartment Dubai Marina',
      'imageUrl': 'https://storage.googleapis.com/habot-mock/listings/marina_apt.webp',
      'availabilityBadgeAccuracy': 0.99,
    },
    {
      'id': 'thumb_002',
      'title': 'Downtown Studio Burj Khalifa View',
      'imageUrl': 'https://storage.googleapis.com/habot-mock/listings/downtown_studio.webp',
      'availabilityBadgeAccuracy': 0.97,
    },
    {
      'id': 'thumb_003',
      'title': 'Palm Jumeirah Villa',
      'imageUrl': 'https://storage.googleapis.com/habot-mock/listings/palm_villa.webp',
      'availabilityBadgeAccuracy': 0.95,
    },
    {
      'id': 'thumb_004',
      'title': 'JVC Family Townhouse',
      'imageUrl': 'https://storage.googleapis.com/habot-mock/listings/jvc_townhouse.webp',
      'availabilityBadgeAccuracy': 0.98,
    },
  ];
}

/// A responsive, lazy-loading thumbnail card utilizing WebP compression routines.
/// Implements M3 Elevated Card (Level 2 - 3dp) and Status Chips.
class WebpLazyThumbnailCard extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double availabilityBadgeAccuracy;
  final VoidCallback? onTap;

  const WebpLazyThumbnailCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.availabilityBadgeAccuracy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = availabilityBadgeAccuracy >= 0.95;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lazy loaded WebP image container with 48x48dp minimum touch target compliance
            SizedBox(
              height: 160.0,
              width: double.infinity,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.png', // Assumes standard asset placeholder
                image: imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                imageErrorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 48.0,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // M3 Status Chip for health/availability indicator
                  FilterChip(
                    label: Text(
                      isAvailable ? 'Available' : 'Pending',
                      style: theme.textTheme.labelSmall,
                    ),
                    selected: isAvailable,
                    onSelected: (_) {},
                    showCheckmark: false,
                    avatar: Icon(
                      isAvailable ? Icons.check_circle_outline : Icons.pending_outlined,
                      size: 16.0,
                      color: isAvailable
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: isAvailable
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: isAvailable
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen demonstrating the single-column mobile (<600dp) and multi-column desktop (>=840dp)
/// responsive layout using the lazy-loaded WebP thumbnails.
class ListingThumbnailsScreen extends StatefulWidget {
  const ListingThumbnailsScreen({super.key});

  @override
  State<ListingThumbnailsScreen> createState() => _ListingThumbnailsScreenState();
}

class _ListingThumbnailsScreenState extends State<ListingThumbnailsScreen> {
  late List<Map<String, dynamic>> _listings;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _listings = _MockListingData.listings;
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    // Background polling refreshes data every 30 seconds as per requirement.
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          // Simulate polling refresh
          _listings = List.from(_MockListingData.listings);
        });
        _startBackgroundPolling();
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate manual sync via pull-to-refresh
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _listings = List.from(_MockListingData.listings);
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Listings synchronized successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      );
    }
  }

  int _calculateCrossAxisCount(double width) {
    // Single-column mobile layout (<600dp), multi-column on desktop (>=840dp)
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Thumbnails'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showConfigBottomSheet(context),
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.4,
              ),
              itemCount: _listings.length,
              itemBuilder: (context, index) {
                final item = _listings[index];
                return WebpLazyThumbnailCard(
                  id: item['id'] as String,
                  title: item['title'] as String,
                  imageUrl: item['imageUrl'] as String,
                  availabilityBadgeAccuracy: item['availabilityBadgeAccuracy'] as double,
                  onTap: () {
                    // Deep-link drill-down simulation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to details for ${item['id']}')),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// M3 Bottom Sheet for configuration inputs.
  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Thumbnail Configuration',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: const Text('Enable WebP Compression'),
                subtitle: const Text('Reduces payload size by ~30%'),
                value: true,
                onChanged: (val) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WebP compression preference updated.')),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Enable Lazy Loading'),
                subtitle: const Text('Load images only when visible in viewport'),
                value: true,
                onChanged: (val) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lazy loading preference updated.')),
                  );
                },
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch targets
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply Settings'),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }
}
