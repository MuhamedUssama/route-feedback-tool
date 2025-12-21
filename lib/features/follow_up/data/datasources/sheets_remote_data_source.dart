import 'dart:async';
import 'dart:developer';
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
    int? sheetId, // Changed from sheetIndex
    int headerRowIndex,
  );

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
    int headerRowIndex,
  ) async {
    try {
      final sheetsApi = await _getSheetsApi();
      final sheetName = await _getSheetTitle(sheetsApi, spreadsheetId, sheetId);

      // Fetch ONLY the header row (using logic 1-based index)
      // Input Logic: User writes "1" -> code passes "1". API expects "1".
      // So no offset needed if user input is treated as 1-based natural number.
      final apiRow = headerRowIndex;

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        '$sheetName!$apiRow:$apiRow', // Fetches single row e.g., "Sheet1!1:1"
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

      print('--- Header Detection ---');
      for (int i = 0; i < headerRow.length; i++) {
        final header = headerRow[i];
        headersMap[header] = i;
        print('Header [$i]: "$header"');

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
      if (nameIndex == null) {
        print('WARNING: "Name" column not found. Defaulting to Index 1.');
        nameIndex = 1;
      }
      if (emailIndex == null) {
        print('WARNING: "Email" column not found. Defaulting to Index 0.');
        emailIndex = 0;
      }

      print('Selected NAME Index: $nameIndex');
      print('Selected EMAIL Index: $emailIndex');

      // Re-map using found indices to ensure the factory works if it relies on maps
      // Or better, just pass indices if the model supports it.
      // Current Model expects a map. Let's fix the map to be standard.
      // But wait, the key is the string. The factory uses keys like 'Name' or 'Email'.
      // Update map to force canonical keys for the specific internal factory logic if needed.
      // Actually, relying on index is safer. Let's look at FromRow logic?
      // No, we are creating the entity manually here based on the user request to be robust.

      if (!headersMap.containsKey('email') &&
          !headersMap.containsKey('email address') &&
          !headersMap.containsKey('gmail') &&
          emailIndex == 0) {
        // Just a warning in log, proceed with fallback
      }

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

      log('--------------------------------------------------');
      log('🔍 DEBUG LOCAL SHEET HEADERS:');
      log('All Headers Found: $localHeaders');
      if (localEmailIndex != -1) {
        log('✅ SUCCESS: Selected Email Column Index: $localEmailIndex');
        log('✅ Selected Column Name: "${localHeaders[localEmailIndex]}"');
      } else {
        log('❌ ERROR: Could not find any email column in keywords!');
      }
      log('--------------------------------------------------');

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

      log('--------------------------------------------------');
      log('🔍 DEBUG LOCAL EMAILS CONTENT:');
      log('Count of emails found: ${localEmails.length}');
      log(
        'List of emails (First 20): ${localEmails.take(20).toList()}',
      ); // بنعرض اول 20 بس عشان الزحمة
      log(
        'Is "test@email.com" in list? ${localEmails.contains("test@email.com")}',
      ); // جرب ايميل انت عارف انه موجود
      log('--------------------------------------------------');

      final missingStudents = <StudentModel>[];

      // 4. Iterate Rows (Start from index 1 to skip header)
      print('--- Row Iteration ---');
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

        // Debug Log
        // ignore: avoid_print
        print(
          'Checking Row ${apiStartRow + i}, Cell Value: "$cellValue" (Missing: $isMissing)',
        );

        if (isMissing) {
          try {
            print(
              'Found Missing at Row ${apiStartRow + i}. Trying to parse student...',
            );

            // Robust Extraction
            String nameRaw = row.length > nameIndex
                ? row[nameIndex].toString()
                : '';
            String emailRaw = row.length > emailIndex
                ? row[emailIndex].toString()
                : '';

            print(' - Reading Name from Col $nameIndex: "$nameRaw"');
            print(' - Reading Email from Col $emailIndex: "$emailRaw"');

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
                print(' + Student Added Successfully');
              } else {
                print(' x Student Skipped: Email not found in Local Sheet');
              }
            } else {
              print(' x Student Skipped: Name/Email missing or invalid');
            }
          } catch (e) {
            print('Checking Error Exception: $e');
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

      // Determine Status Text & Color
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

  // Renamed from _getSheetName to _getSheetTitle for clarity
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
