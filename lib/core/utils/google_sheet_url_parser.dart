class SheetUrlInfo {
  final String spreadsheetId;
  final int? gid;

  const SheetUrlInfo({required this.spreadsheetId, this.gid});

  @override
  String toString() => 'SheetUrlInfo(id: $spreadsheetId, gid: $gid)';
}

class GoogleSheetUrlParser {
  static final RegExp _idRegex = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
  static final RegExp _gidRegex = RegExp(r'[#&]gid=([0-9]+)');

  /// Parses a Google Sheet URL or ID.
  /// Returns [SheetUrlInfo] if successful, or null if invalid.
  static SheetUrlInfo? parse(String input) {
    if (input.isEmpty) return null;

    String? spreadsheetId;
    int? gid;

    // 1. Try to find Spreadsheet ID from URL
    final idMatch = _idRegex.firstMatch(input);
    if (idMatch != null) {
      spreadsheetId = idMatch.group(1);
    } else {
      // If no URL pattern, assume the input itself is the ID if it looks like one
      // IDs are usually long strings without slashes
      if (!input.contains('/') && !input.contains('?')) {
        spreadsheetId = input.trim();
      }
    }

    if (spreadsheetId == null) return null;

    // 2. Try to find GID (Tab ID)
    final gidMatch = _gidRegex.firstMatch(input);
    if (gidMatch != null) {
      gid = int.tryParse(gidMatch.group(1)!);
    }

    return SheetUrlInfo(spreadsheetId: spreadsheetId, gid: gid);
  }
}
