import 'dart:async';
import 'dart:ui' as color;

import 'package:flutter/foundation.dart';
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
    int? sheetId, // Changed from sheetIndex
    int headerRowIndex, {
    bool detectMergedHeaders = false,
  });

  Future<List<StudentModel>> checkMissingAssignments({
    required String masterSheetId,
    required int? masterSheetIdGid, // Changed from masterSheetIndex
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
    required int? currentSheetIdGid, // optional GID for follow-up sheet
  });

  Future<void> updateStudentStatus({
    required String spreadsheetId,
    required int rowIndex,
    required int statusColumnIndex,
    required FollowUpAction action,
    int? sheetId, // Added optional GID
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
    int? sheetId,
    int headerRowIndex, {
    bool detectMergedHeaders = false,
  }) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final sheetName = await _getSheetTitle(sheetsApi, spreadsheetId, sheetId);

      // Determine range based on detection flag
      final startRow = detectMergedHeaders
          ? (headerRowIndex > 1 ? headerRowIndex - 1 : 1)
          : headerRowIndex;
      final endRow = headerRowIndex;

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        '$sheetName!$startRow:$endRow',
      );

      final values = response.values;
      if (values == null || values.isEmpty) return [];

      List<dynamic> targetRow;
      List<dynamic>? rowAbove;

      // Values will contain 1 or 2 rows
      if (detectMergedHeaders && headerRowIndex > 1 && values.length == 2) {
        rowAbove = values[0];
        targetRow = values[1];
      } else {
        // Fallback or standard behavior
        targetRow = values.last;
      }

      final columns = <SheetColumnModel>[];

      for (int i = 0; i < targetRow.length; i++) {
        String mainVal = targetRow[i].toString().trim();

        if (detectMergedHeaders && rowAbove != null) {
          String aboveVal = '';
          if (rowAbove.length > i) {
            aboveVal = rowAbove[i].toString().trim();
          }

          // Smart Fallback Logic:
          // If main cell is empty BUT cell above is not empty -> Use cell above
          if (mainVal.isEmpty && aboveVal.isNotEmpty) {
            mainVal = aboveVal;
          }
        }

        if (mainVal.isNotEmpty) {
          columns.add(SheetColumnModel.fromIndexedValue(i, mainVal));
        }
      }

      return columns;
    } catch (e) {
      throw SheetException('Failed to fetch headers: $e');
    }
  }

  @override
  Future<List<StudentModel>> checkMissingAssignments({
    required String masterSheetId,
    required int? masterSheetIdGid,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
    required int? currentSheetIdGid,
  }) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final masterSheetName = await _getSheetTitle(
        sheetsApi,
        masterSheetId,
        masterSheetIdGid,
      );

      // 1. Fetch Master Data starting from Header Row
      // Input Logic: User writes "1". API expects "1".
      final apiStartRow = masterHeaderRowIndex;
      final masterResponse = await sheetsApi.spreadsheets.values.get(
        masterSheetId,
        '$masterSheetName!$apiStartRow:1000', // Fetch from header downwards
      );

      final masterRows = masterResponse.values;
      if (masterRows == null || masterRows.isEmpty) return [];

      // 2. Map Master Headers (Dynamic Column Finding)
      final headerRow = masterRows[0]
          .map((e) => e.toString().toLowerCase())
          .toList();
      final headersMap = <String, int>{};

      int? nameIndex;
      int? emailIndex;

      for (int i = 0; i < headerRow.length; i++) {
        final header = headerRow[i];
        headersMap[header] = i;

        if (nameIndex == null &&
            (header == 'name' || header.contains('name'))) {
          nameIndex = i;
        }

        if (emailIndex == null &&
            (header == 'email' ||
                header == 'gmail' ||
                header == 'email address' ||
                header.contains('email'))) {
          emailIndex = i;
        }
      }

      // Fallback Logic
      nameIndex ??= 1;
      emailIndex ??= 0;

      if (!headersMap.containsKey('email') &&
          !headersMap.containsKey('email address') &&
          !headersMap.containsKey('gmail') &&
          emailIndex == 0) {}

      final assignmentName = masterRows[0].length > gradeColumnIndex
          ? masterRows[0][gradeColumnIndex].toString()
          : 'Unknown Assignment';

      // 3. Fetch Local Sheet Emails (Dynamic)
      final localSheetName = await _getSheetTitle(
        sheetsApi,
        currentSheetId,
        currentSheetIdGid,
      );

      // 3.1 Fetch Local Headers
      final localApiRow = localHeaderRowIndex;
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

        // --- Robust Empty Check Logic ---
        String cellValue = '';
        if (row.length > gradeColumnIndex) {
          final rawValue = row[gradeColumnIndex]; // Can be anything
          if (rawValue != null) {
            cellValue = rawValue.toString().trim();
          }
        }

        bool isMissing = cellValue.isEmpty;

        if (isMissing) {
          try {
            // Robust Extraction
            String nameRaw = row.length > nameIndex
                ? row[nameIndex].toString()
                : '';
            String emailRaw = row.length > emailIndex
                ? row[emailIndex].toString()
                : '';

            // Safety Checks: Trim and Validate
            final name = nameRaw.trim();
            final email = emailRaw.trim();

            bool isValidStudent = name.isNotEmpty && email.isNotEmpty;

            if (isValidStudent) {
              // Only check alignment if email is in local emails
              // Logic check: The requirement is Missing AND in Local Sheet
              if (localEmails.contains(email.toLowerCase())) {
                final student = StudentModel(
                  name: name,
                  email: email,
                  status: 'Missing',
                  missingAssignmentName: assignmentName,
                  rowNumber: apiStartRow + i,
                  isSelected: true,
                );
                missingStudents.add(student);
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('Checking Error Exception: $e');
            }
          }
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
    int? sheetId, // Added optional GID
  }) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final sheetName = await _getSheetTitle(
        sheetsApi,
        spreadsheetId,
        sheetId,
      ); // Assuming first sheet

      String statusText;
      color.Color statusColor;

      switch (action) {
        case FollowUpAction.sent:
          statusText = 'Email Sent';
          statusColor = const color.Color(0xFFFFCDD2); // Red 100
          break;
        case FollowUpAction.markedAsDone:
          statusText = 'Done';
          statusColor = const color.Color(0xFFC8E6C9); // Green 100
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
      // We need the SheetId (GID) for batchUpdate.
      // If we already have it (passed as param), use it.
      // If not, we have to look it up (which _getSheetTitle did essentially).
      // Since _getSheetTitle returns the NAME, we might need to change it or fetch metadata again.
      // BUT, checking the existing logic: it fetches metadata to get sheetId.
      // Let's optimize: If we have sheetId param, use it!
      int targetGid;
      if (sheetId != null) {
        targetGid = sheetId;
      } else {
        // Fallback: fetch metadata if no GID provided
        final meta = await sheetsApi.spreadsheets.get(spreadsheetId);
        targetGid = meta.sheets![0].properties!.sheetId!;
      }

      final request = Request(
        repeatCell: RepeatCellRequest(
          range: GridRange(
            sheetId: targetGid,
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

  Future<String> _getSheetTitle(
    SheetsApi api,
    String spreadsheetId,
    int? sheetId, // NULL means FIRST sheet (default)
  ) async {
    // 1. Check Cache
    final key = '${spreadsheetId}_${sheetId ?? 'first'}';
    if (_sheetNameCache.containsKey(key)) {
      return _sheetNameCache[key]!;
    }

    // 2. Fetch from API
    final meta = await api.spreadsheets.get(spreadsheetId);
    if (meta.sheets == null || meta.sheets!.isEmpty) {
      throw const SheetException('No sheets found in spreadsheet');
    }

    String title;
    if (sheetId != null) {
      // Find specific sheet by GID
      try {
        final sheet = meta.sheets!.firstWhere(
          (s) => s.properties?.sheetId == sheetId,
        );
        title = sheet.properties!.title ?? 'Sheet1';
      } catch (e) {
        throw SheetException('Sheet with GID $sheetId not found');
      }
    } else {
      // Default to first sheet
      title = meta.sheets!.first.properties!.title ?? 'Sheet1';
    }

    // 3. Save to Cache
    _sheetNameCache[key] = title;

    return title;
  }
}
