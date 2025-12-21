class SheetUtils {
  /// Converts an Excel-style column letter (e.g., "A", "Z", "AA") to a 0-based index.
  /// "A" -> 0
  /// "B" -> 1
  /// "AA" -> 26
  static int columnLetterToIndex(String letter) {
    if (letter.isEmpty) return 0;

    String upper = letter.trim().toUpperCase();
    int index = 0;

    for (int i = 0; i < upper.length; i++) {
      index = index * 26 + (upper.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1);
    }

    return index - 1;
  }
}
