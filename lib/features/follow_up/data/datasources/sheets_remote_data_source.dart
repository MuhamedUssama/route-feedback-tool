import 'dart:ui' as color;
import 'package:injectable/injectable.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:mentor_assistant/core/errors/auth_error_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/google_auth_client.dart';
import '../models/sheet_column_model.dart';
import '../models/student_model.dart';
import '../../domain/entities/follow_up_config_entity.dart';

abstract interface class SheetsRemoteDataSource {
  Future<List<SheetColumnModel>> getSheetHeaders(
    String spreadsheetId,
    int sheetIndex,
    int headerRowIndex,
  );

  Future<List<StudentModel>> checkMissingAssignments({
    required String masterSheetId,
    required int masterSheetIndex,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
  });

  Future<void> updateStudentStatus({
    required String spreadsheetId,
    required int rowIndex,
    required int statusColumnIndex,
    required FollowUpAction action,
  });
}

@LazySingleton(as: SheetsRemoteDataSource)
class SheetsRemoteDataSourceImpl implements SheetsRemoteDataSource {
  final GoogleAuthClient _googleAuthClient;

  // Cache for sheet names to prevent redundant API calls
  final Map<String, String> _sheetNameCache = {};

  SheetsRemoteDataSourceImpl(this._googleAuthClient);

  Future<SheetsApi> _getSheetsApi() async {
    final client = await _googleAuthClient.getAuthenticatedClient();
    if (client == null) {
      throw GoogleAuthException(
        'User not authenticated',
        AuthErrorType.userNotAuthenticated,
      );
    }
    return SheetsApi(client);
  }

  // 👇 Helper to handle AA, AB, column logic
  String _getColumnLetter(int index) {
    String letter = "";
    int temp = index + 1;
    while (temp > 0) {
      int remainder = (temp - 1) % 26;
      letter = String.fromCharCode(65 + remainder) + letter;
      temp = (temp - 1) ~/ 26;
    }
    return letter;
  }

  @override
  Future<List<SheetColumnModel>> getSheetHeaders(
    String spreadsheetId,
    int sheetIndex,
    int headerRowIndex,
  ) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final sheetName = await _getSheetName(
        sheetsApi,
        spreadsheetId,
        sheetIndex,
      );

      // Fetch ONLY the header row (using logic 1-based index)
      // If headerRowIndex is 0 (code logic), in API it is row 1.
      final apiRow = headerRowIndex + 1;

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        '$sheetName!$apiRow:$apiRow', // Fetches single row e.g., "Sheet1!9:9"
      );

      final values = response.values;
      if (values == null || values.isEmpty) return [];

      final headerRow = values.first;
      final columns = <SheetColumnModel>[];

      for (int i = 0; i < headerRow.length; i++) {
        columns.add(
          SheetColumnModel.fromIndexedValue(i, headerRow[i].toString()),
        );
      }
      return columns;
    } catch (e) {
      throw SheetException('Failed to fetch headers: $e');
    }
  }

  @override
  Future<List<StudentModel>> checkMissingAssignments({
    required String masterSheetId,
    required int masterSheetIndex,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
  }) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final masterSheetName = await _getSheetName(
        sheetsApi,
        masterSheetId,
        masterSheetIndex,
      );

      // 1. Fetch Master Data starting from Header Row
      final apiStartRow = masterHeaderRowIndex + 1;
      final masterResponse = await sheetsApi.spreadsheets.values.get(
        masterSheetId,
        '$masterSheetName!$apiStartRow:1000', // Fetch from header downwards
      );

      final masterRows = masterResponse.values;
      if (masterRows == null || masterRows.isEmpty) return [];

      // 2. Map Master Headers
      final headerRow = masterRows[0]
          .map((e) => e.toString().toLowerCase())
          .toList();
      final headersMap = <String, int>{};
      for (int i = 0; i < headerRow.length; i++) {
        headersMap[headerRow[i]] = i;
      }

      if (!headersMap.containsKey('email') &&
          !headersMap.containsKey('email address') &&
          !headersMap.containsKey('gmail')) {
        throw const SheetException(
          'Could not find "Email" or "Gmail" column in Master Sheet',
        );
      }

      final assignmentName = masterRows[0].length > gradeColumnIndex
          ? masterRows[0][gradeColumnIndex].toString()
          : 'Unknown Assignment';

      // 3. Fetch Local Sheet Emails (Dynamic)
      final localSheetName = await _getSheetName(
        sheetsApi,
        currentSheetId,
        0, // Assuming first sheet for local spreadsheet
      );

      // 3.1 Fetch Local Headers
      final localApiRow = localHeaderRowIndex + 1;
      final localHeaderResponse = await sheetsApi.spreadsheets.values.get(
        currentSheetId,
        '$localSheetName!$localApiRow:$localApiRow',
      );

      final localHeaderValues = localHeaderResponse.values;
      if (localHeaderValues == null || localHeaderValues.isEmpty) {
        throw const SheetException('Local sheet is empty or headers missing');
      }

      final localHeaders = localHeaderValues.first
          .map((e) => e.toString().toLowerCase())
          .toList();
      int localEmailIndex = -1;

      for (int i = 0; i < localHeaders.length; i++) {
        if (localHeaders[i] == 'email' ||
            localHeaders[i] == 'email address' ||
            localHeaders[i] == 'gmail') {
          localEmailIndex = i;
          break;
        }
      }

      if (localEmailIndex == -1) {
        throw const SheetException(
          'Could not find "Email" or "Gmail" column in Local Sheet',
        );
      }

      // 3.2 Fetch Local Emails Column
      final localEmailColLetter = _getColumnLetter(localEmailIndex);
      // Fetch column from header downwards
      final localEmailsResponse = await sheetsApi.spreadsheets.values.get(
        currentSheetId,
        '$localSheetName!$localEmailColLetter:$localEmailColLetter',
      );

      final localEmails =
          localEmailsResponse.values
              ?.expand((e) => e)
              .map((e) => e.toString().trim().toLowerCase())
              .where((e) => e.isNotEmpty) // Stop empty email matching
              .toSet() ??
          {};

      final missingStudents = <StudentModel>[];

      // 4. Iterate Rows (Start from index 1 to skip header)
      for (int i = 1; i < masterRows.length; i++) {
        final row = masterRows[i];

        // Use the Factory! Clean and readable.
        final student = StudentModel.fromRow(
          row: row,
          rowIndex: apiStartRow + i, // Actual Row Number in Sheet
          headersMap: headersMap,
          gradeColumnIndex: gradeColumnIndex,
          assignmentName: assignmentName,
        );

        // Skip invalid rows with empty emails
        if (student.email.isEmpty) continue;

        // Logic: Must be in Local Sheet AND Grade is Missing
        if (localEmails.contains(student.email) &&
            student.status == 'Missing') {
          missingStudents.add(student);
        }
      }

      return missingStudents;
    } catch (e) {
      if (e is SheetException) rethrow;
      throw SheetException('Failed to check assignments: $e');
    }
  }

  @override
  Future<void> updateStudentStatus({
    required String spreadsheetId,
    required int rowIndex,
    required int statusColumnIndex,
    required FollowUpAction action,
  }) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final sheetName = await _getSheetName(
        sheetsApi,
        spreadsheetId,
        0,
      ); // Assuming first sheet

      // Determine Status Text & Color
      String statusText;
      color.Color statusColor;

      switch (action) {
        case FollowUpAction.sent:
          statusText = 'Email Sent';
          statusColor = color.Color(0xFFFFCDD2); // Red 100
          break;
        case FollowUpAction.markedAsDone:
          statusText = 'Done';
          statusColor = color.Color(0xFFC8E6C9); // Green 100
          break;
      }

      final colLetter = _getColumnLetter(statusColumnIndex);
      final range = '$sheetName!$colLetter$rowIndex';

      // 1. Update Text
      await sheetsApi.spreadsheets.values.update(
        ValueRange(
          values: [
            [statusText],
          ],
        ),
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      // 2. Update Color
      final sheetId = (await sheetsApi.spreadsheets.get(
        spreadsheetId,
      )).sheets![0].properties!.sheetId;

      final request = Request(
        repeatCell: RepeatCellRequest(
          range: GridRange(
            sheetId: sheetId,
            startRowIndex: rowIndex - 1,
            endRowIndex: rowIndex,
            startColumnIndex: statusColumnIndex,
            endColumnIndex: statusColumnIndex + 1,
          ),
          cell: CellData(
            userEnteredFormat: CellFormat(
              backgroundColor: googleColorFrom(statusColor),
            ),
          ),
          fields: 'userEnteredFormat.backgroundColor',
        ),
      );

      await sheetsApi.spreadsheets.batchUpdate(
        BatchUpdateSpreadsheetRequest(requests: [request]),
        spreadsheetId,
      );
    } catch (e) {
      throw SheetException('Failed to update student status: $e');
    }
  }

  Color googleColorFrom(color.Color c) {
    return Color(
      red: (c.r * 255.0).round().clamp(0, 255) / 255.0,
      green: (c.g * 255.0).round().clamp(0, 255) / 255.0,
      blue: (c.b * 255.0).round().clamp(0, 255) / 255.0,
    );
  }

  Future<String> _getSheetName(
    SheetsApi api,
    String spreadsheetId,
    int sheetIndex,
  ) async {
    // 1. Check Cache
    final key = '${spreadsheetId}_$sheetIndex';
    if (_sheetNameCache.containsKey(key)) {
      return _sheetNameCache[key]!;
    }

    // 2. Fetch from API
    final meta = await api.spreadsheets.get(spreadsheetId);
    if (meta.sheets == null || meta.sheets!.length <= sheetIndex) {
      throw const SheetException('Sheet index out of bounds');
    }
    final sheetName = meta.sheets![sheetIndex].properties?.title ?? 'Sheet1';

    // 3. Save to Cache
    _sheetNameCache[key] = sheetName;

    return sheetName;
  }
}
