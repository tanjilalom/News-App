/// Shared text utilities used across all portal screens.
class TextUtils {
  TextUtils._();

  /// Collapses whitespace and trims the string.
  static String cleanText(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Formats a [DateTime] as e.g. "Mar 19, 7:30 PM".
  static String formatTimestamp(DateTime value) {
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
