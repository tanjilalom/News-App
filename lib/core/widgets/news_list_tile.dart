import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:web_scraping_with_flutter/core/theme/app_theme.dart';
import 'package:web_scraping_with_flutter/core/models/news_item.dart';

/// Unified news list tile widget used across all portal screens.
class NewsListTile extends StatelessWidget {
  const NewsListTile({
    super.key,
    required this.item,
    required this.onTap,
    this.accentColor = const Color(0xFF3366FF),
    this.showImage = false,
    this.showDescription = false,
    this.bengaliFont = false,
    this.onShare,
  });

  final NewsItem item;
  final VoidCallback onTap;
  final Color accentColor;
  final bool showImage;
  final bool showDescription;
  final bool bengaliFont;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final titleStyle = bengaliFont
        ? GoogleFonts.notoSansBengali(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          )
        : GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: accentColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            if (item.category.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.category,
                  style: (bengaliFont
                          ? GoogleFonts.notoSansBengali
                          : GoogleFonts.poppins)(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Title
            Text(
              item.title,
              style: titleStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Description
            if (showDescription && item.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Image
            if (showImage && item.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: AppColors.divider,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Bottom row: time + read button
            Row(
              children: [
                if (item.time.isNotEmpty) ...[
                  Icon(Icons.access_time_rounded,
                      size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),

                // Share button
                if (onShare != null) ...[
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 16),
                    color: accentColor,
                    onPressed: onShare,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],

                // Popular badge
                if (item.isPopular) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7043).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded,
                            size: 12, color: Color(0xFFFF7043)),
                        const SizedBox(width: 3),
                        Text(
                          'Popular',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF7043),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Read button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bengaliFont ? 'পড়ুন' : 'Read',
                        style: (bengaliFont
                                ? GoogleFonts.notoSansBengali
                                : GoogleFonts.poppins)(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: accentColor),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Share the article URL.
  static void shareArticle(String url, {String? title}) {
    Share.share(
      title != null ? '$title\n\n$url' : url,
      subject: title,
    );
  }
}
