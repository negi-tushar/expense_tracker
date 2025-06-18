import 'package:intl/intl.dart'; // Import this for NumberFormat

extension NumberFormattingExtension on String {
  /// Formats a string representing a number into the Indian numbering system (e.g., 3,00,000).
  ///
  /// Returns the formatted string, or the original string if it cannot be parsed as a number.
  String toIndianNumberFormat() {
    try {
      final double number = double.parse(this);
      // Use NumberFormat with a custom pattern for Indian locale.
      // '##,##,##0' specifies the grouping.
      // 'en_IN' is the locale for India.
      final NumberFormat formatter = NumberFormat('##,##,##0.##', 'en_IN');
      return formatter.format(number);
    } catch (e) {
      // If the string cannot be parsed as a number, return the original string.
      // You might want to log the error or handle it differently based on your needs.
      print('Error formatting "$this": $e');
      return this;
    }
  }
}
