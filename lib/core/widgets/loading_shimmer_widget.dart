import 'package:flutter/material.dart';

/// Animated shimmer-style loading placeholder for news list screens.
class LoadingShimmerWidget extends StatefulWidget {
  const LoadingShimmerWidget({
    super.key,
    this.itemCount = 6,
    this.hasImage = false,
  });

  final int itemCount;
  final bool hasImage;

  @override
  State<LoadingShimmerWidget> createState() => _LoadingShimmerWidgetState();
}

class _LoadingShimmerWidgetState extends State<LoadingShimmerWidget>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _ShimmerCard(
          opacity: _animation.value,
          hasImage: widget.hasImage,
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.opacity, required this.hasImage});

  final double opacity;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            if (hasImage) ...[
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBar(double.infinity, 14),
                  const SizedBox(height: 8),
                  _shimmerBar(double.infinity, 14),
                  const SizedBox(height: 8),
                  _shimmerBar(160, 14),
                  const SizedBox(height: 12),
                  _shimmerBar(100, 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
