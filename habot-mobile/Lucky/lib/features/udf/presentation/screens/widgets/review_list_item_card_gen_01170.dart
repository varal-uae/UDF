// GEN-01170 — Review List Item Card using M3 Elevated Card layout.
// Builds review list item containers with M3 Elevated Cards (Level 2, 3dp), status chips, and responsive single/multi-column layout support.

import 'package:flutter/material.dart';

/// Mock data model representing a review item for local development.
class ReviewItemModel {
  final String id;
  final String reviewerName;
  final String content;
  final double rating;
  final DateTime timestamp;
  final ReviewVerificationStatus verificationStatus;

  const ReviewItemModel({
    required this.id,
    required this.reviewerName,
    required this.content,
    required this.rating,
    required this.timestamp,
    required this.verificationStatus,
  });
}

enum ReviewVerificationStatus { good, average, poor }

/// Provides realistic mock data for the review list items.
class ReviewMockData {
  static const List<ReviewItemModel> reviews = [
    ReviewItemModel(
      id: 'REV-001',
      reviewerName: 'Ahmed Al Maktoum',
      content: 'Excellent service and fast delivery. Highly recommended.',
      rating: 5.0,
      timestamp: null,
      verificationStatus: ReviewVerificationStatus.good,
    ),
    ReviewItemModel(
      id: 'REV-002',
      reviewerName: 'Sarah Jenkins',
      content: 'Product was okay, but shipping took longer than expected.',
      rating: 3.0,
      timestamp: null,
      verificationStatus: ReviewVerificationStatus.average,
    ),
    ReviewItemModel(
      id: 'REV-003',
      reviewerName: 'Wei Chen',
      content: 'Did not match the description at all. Requesting refund.',
      rating: 1.0,
      timestamp: null,
      verificationStatus: ReviewVerificationStatus.poor,
    ),
  ];
}

/// M3 Elevated Card widget for displaying a single review list item.
/// Implements 48x48dp touch targets, Material You dynamic color, and status chips.
class ReviewListItemCard extends StatelessWidget {
  final ReviewItemModel review;
  final VoidCallback? onTap;

  const ReviewListItemCard({
    super.key,
    required this.review,
    this.onTap,
  });

  Color _getStatusColor(ReviewVerificationStatus status, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ReviewVerificationStatus.good:
        return colorScheme.primary;
      case ReviewVerificationStatus.average:
        return colorScheme.tertiary;
      case ReviewVerificationStatus.poor:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(ReviewVerificationStatus status) {
    switch (status) {
      case ReviewVerificationStatus.good:
        return 'Good';
      case ReviewVerificationStatus.average:
        return 'Average';
      case ReviewVerificationStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Review by ${review.reviewerName}, rated ${review.rating} stars, status ${_getStatusLabel(review.verificationStatus)}',
      child: Card(
        elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: onTap,
          // Ensuring minimum 48x48dp touch target via padding
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Chip(
                      label: Text(
                        _getStatusLabel(review.verificationStatus),
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _getStatusColor(review.verificationStatus, context),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating.floor()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 20.0,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  review.content,
                  style: textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive container that renders the review list.
/// Single-column on mobile (<600dp), multi-column on desktop (>=840dp).
class ReviewListContainer extends StatelessWidget {
  final List<ReviewItemModel> reviews;

  const ReviewListContainer({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (≥840dp)
    if (screenWidth >= 840) {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return ReviewListItemCard(
            review: reviews[index],
            onTap: () {},
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return ReviewListItemCard(
          review: reviews[index],
          onTap: () {},
        );
      },
    );
  }
}
