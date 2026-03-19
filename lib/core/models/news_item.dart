/// Shared news article model used across all portal screens.
class NewsItem {
  const NewsItem({
    required this.title,
    required this.url,
    this.time = '',
    this.category = '',
    this.imageUrl = '',
    this.isPopular = false,
    this.description = '',
  });

  final String title;
  final String url;
  final String time;
  final String category;
  final String imageUrl;
  final bool isPopular;
  final String description;

  NewsItem copyWith({
    String? title,
    String? url,
    String? time,
    String? category,
    String? imageUrl,
    bool? isPopular,
    String? description,
  }) {
    return NewsItem(
      title: title ?? this.title,
      url: url ?? this.url,
      time: time ?? this.time,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isPopular: isPopular ?? this.isPopular,
      description: description ?? this.description,
    );
  }
}
