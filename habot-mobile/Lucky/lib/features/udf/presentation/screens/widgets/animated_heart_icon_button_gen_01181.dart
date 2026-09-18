// GEN-01181 — Animated M3 Heart Icon Button for service cards and detail headers.
// Provides a reusable, animated heart icon button following Material 3 standards with 48x48dp touch targets and dynamic color support.

import 'package:flutter/material.dart';

/// Reusable animated M3 heart icon button widget.
/// Attach to all service cards and detail headers as per GEN-01181.
class AnimatedHeartIconButton extends StatefulWidget {
  final bool isInitiallyFavorited;
  final ValueChanged<bool>? onFavoriteChanged;
  final double size;

  const AnimatedHeartIconButton({
    super.key,
    this.isInitiallyFavorited = false,
    this.onFavoriteChanged,
    this.size = 24.0,
  });

  @override
  State<AnimatedHeartIconButton> createState() => _AnimatedHeartIconButtonState();
}

class _AnimatedHeartIconButtonState extends State<AnimatedHeartIconButton>
    with SingleTickerProviderStateMixin {
  late bool _isFavorited;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isInitiallyFavorited;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });

    if (_isFavorited) {
      _controller.forward().then((_) => _controller.reverse());
    } else {
      _controller.reverse();
    }

    widget.onFavoriteChanged?.call(_isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // M3 requires 48x48dp touch targets for accessibility
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: IconButton(
        onPressed: _toggleFavorite,
        icon: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border,
            size: widget.size,
            color: _isFavorited ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
        ),
        tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

/// Example usage demonstrating attachment to a service card and detail header.
class HeartButtonDemoScreen extends StatelessWidget {
  const HeartButtonDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Detail'),
        actions: [
          // Attached to detail header
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AnimatedHeartIconButton(
              isInitiallyFavorited: false,
              onFavoriteChanged: (bool isFav) {
                // Handle favorite state change
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text('Service Card ${index + 1}'),
              subtitle: const Text('M3 responsive layout'),
              trailing: AnimatedHeartIconButton(
                isInitiallyFavorited: index == 1,
                onFavoriteChanged: (bool isFav) {
                  // Handle favorite state change
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
