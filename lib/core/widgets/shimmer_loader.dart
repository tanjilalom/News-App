import 'package:flutter/material.dart';
import 'package:web_scraping_with_flutter/core/config/constants.dart';

/// Loading shimmer widget with configurable count.
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({super.key, this.count = 6, this.showImage = false});

  final int count;
  final bool showImage;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Opacity(
          opacity: _animation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showImage) ...[
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(double.infinity, 14, shimmerColor),
                      const SizedBox(height: 8),
                      _bar(double.infinity, 14, shimmerColor),
                      const SizedBox(height: 8),
                      _bar(160, 14, shimmerColor),
                      const SizedBox(height: 12),
                      _bar(100, 10, shimmerColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bar(double w, double h, Color c) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}

/// Updated-at chip showing freshness.
class UpdatedChip extends StatelessWidget {
  const UpdatedChip({super.key, required this.timestamp, required this.count});

  final DateTime timestamp;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.update_rounded, size: 14, color: secondary),
          const SizedBox(width: 6),
          Text('Updated ${_formatTimestamp(timestamp)}',
              style: textTheme.bodySmall?.copyWith(color: secondary)),
          const Spacer(),
          Text('$count articles',
              style: textTheme.bodySmall?.copyWith(color: secondary)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[value.month - 1];
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final meridiem = value.hour >= 12 ? 'PM' : 'AM';
    return '$month ${value.day}, $hour:$minute $meridiem';
  }
}

/// Debounce utility for search and refresh.
class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  VoidCallback? _action;
  Duration get delay => Duration(milliseconds: milliseconds);

  void run(VoidCallback action) {
    _action = action;
  }

  void cancel() {
    _action = null;
  }

  VoidCallback? takeAction() {
    final a = _action;
    _action = null;
    return a;
  }
}

/// Cooldown tracker to prevent spam refresh.
class RefreshCooldown {
  DateTime? _lastRefresh;

  bool get canRefresh {
    if (_lastRefresh == null) return true;
    return DateTime.now().difference(_lastRefresh!) >= AppConstants.refreshCooldown;
  }

  void markRefreshed() {
    _lastRefresh = DateTime.now();
  }
}
