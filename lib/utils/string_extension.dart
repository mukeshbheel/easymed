extension StringCasingExtension on String {

  /// Capitalize first letter only
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalize first letter of every word
  String capitalizeWords() {
    return split(' ')
        .map((word) =>
    word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
