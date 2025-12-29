import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sheet_column_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/follow_up_config_entity.dart';
import '../../domain/repositories/follow_up_repository.dart';
import '../../domain/entities/assignment_analysis_result.dart';
import '../../data/models/student_status_update_model.dart';
import '../datasources/follow_up_local_data_source.dart';
import '../datasources/gmail_remote_data_source.dart';
import '../datasources/sheets_remote_data_source.dart';
import '../models/follow_up_config_model.dart';
import 'package:html_unescape/html_unescape.dart';

@LazySingleton(as: FollowUpRepository)
class FollowUpRepositoryImpl implements FollowUpRepository {
  final SheetsRemoteDataSource _remoteDataSource;
  final GmailRemoteDataSource _transportGmail;
  final FollowUpLocalDataSource _localDataSource;

  FollowUpRepositoryImpl(
    this._remoteDataSource,
    this._transportGmail,
    this._localDataSource,
  );

  @override
  Future<Either<Failure, String>> getCurrentUserEmail() async {
    try {
      final email = await _transportGmail.getCurrentUserEmail();
      return Right(email);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetColumnEntity>>> getSheetHeaders(
    String spreadsheetId,
    int? sheetId,
    int headerRowIndex, {
    bool detectMergedHeaders = false,
  }) async {
    try {
      final columns = await _remoteDataSource.getSheetHeaders(
        spreadsheetId,
        sheetId,
        headerRowIndex,
        detectMergedHeaders: detectMergedHeaders,
      );
      return Right(columns);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentAnalysisResult>> analyzeAssignmentStatus({
    required String masterSheetId,
    required int? masterSheetIdGid,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
    required int? currentSheetIdGid,
  }) async {
    try {
      final result = await _remoteDataSource.analyzeAssignmentStatus(
        masterSheetId: masterSheetId,
        masterSheetIdGid: masterSheetIdGid,
        masterHeaderRowIndex: masterHeaderRowIndex,
        localHeaderRowIndex: localHeaderRowIndex,
        gradeColumnIndex: gradeColumnIndex,
        currentSheetId: currentSheetId,
        currentSheetIdGid: currentSheetIdGid,
      );
      return Right(result);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendFollowUpEmail({
    required StudentEntity student,
    required String assignmentName,
  }) async {
    try {
      final threadId = await _transportGmail.sendFollowUpEmail(
        student: student,
        assignmentName: assignmentName,
      );
      return Right(threadId);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentStatus({
    required String spreadsheetId,
    required int rowIndex,
    required int statusColumnIndex,
    required FollowUpAction action,
    int? sheetId,
    String? formula,
    String? note,
  }) async {
    try {
      await _remoteDataSource.updateStudentStatus(
        spreadsheetId: spreadsheetId,
        rowIndex: rowIndex,
        statusColumnIndex: statusColumnIndex,
        action: action,
        sheetId: sheetId,
        formula: formula,
        note: note,
      );
      return const Right(null);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> batchUpdateStudentStatus({
    required String spreadsheetId,
    required List<StudentStatusUpdateModel> updates,
  }) async {
    try {
      await _remoteDataSource.batchUpdateStatus(
        spreadsheetId: spreadsheetId,
        updates: updates,
      );
      return const Right(null);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> checkStudentReplies({
    required String spreadsheetId,
    required int? sheetId,
    required int statusColumnIndex,
    required int followUpHeaderRowIndex,
  }) async {
    try {
      // 1. Fetch formulas from the Sheet
      // We assume data starts after the header row.
      // Actually, we should start checking from followUpHeaderRowIndex + 1
      final int actualStartRow = followUpHeaderRowIndex + 1;

      // We'll fetch a reasonable amount of rows, e.g., until row 1000 or implement chunking later.
      // For now let's fetch until 500 rows to be safe or just fetch column data.
      // RemoteDataSource handles empty checking.
      const int endRow = 500;

      final formulas = await _remoteDataSource.getColumnFormulas(
        spreadsheetId: spreadsheetId,
        sheetId: sheetId,
        columnIndex: statusColumnIndex,
        startRow: actualStartRow,
        endRow: endRow,
      );

      final updates = <StudentStatusUpdateModel>[];
      final threadIdRegex = RegExp(r'#inbox/([a-z0-9]+)', caseSensitive: false);

      for (int i = 0; i < formulas.length; i++) {
        final formula = formulas[i];
        // Check if cell is "Email Sent" via Hyperlink
        if (formula.contains('=HYPERLINK') && formula.contains('Email Sent')) {
          final match = threadIdRegex.firstMatch(formula);
          if (match != null) {
            final threadId = match.group(1);
            if (threadId != null) {
              // 2. Fetch Thread from Gmail
              try {
                final thread = await _transportGmail.getThread(threadId);
                final messages = thread.messages;

                if (messages != null && messages.isNotEmpty) {
                  final lastMessage = messages.last;

                  // CHECK SENDER LOGIC: Rely on LABEL IDS
                  // If 'SENT' is present, I sent the last message -> NO ANSWER.
                  // If 'SENT' is NOT present, Student sent the last message -> REPLY FOUND.

                  bool isLastMessageSentByMe = false;
                  if (lastMessage.labelIds != null &&
                      lastMessage.labelIds!.contains('SENT')) {
                    isLastMessageSentByMe = true;
                  }

                  if (!isLastMessageSentByMe) {
                    // --- REPLY FOUND ---
                    var snippet = lastMessage.snippet ?? "Reply Received";

                    // Decode HTML entities (e.g., &#39; -> ')
                    final unescape = HtmlUnescape();
                    snippet = unescape.convert(snippet);

                    // New Formula: =HYPERLINK("link", "📩 Reply Received")
                    // We preserve the link but update the label to fixed text.
                    // The snippet goes into the NOTE.
                    final newFormula = formula.replaceFirst(
                      '"Email Sent"',
                      '"📩 Reply Received"',
                    );
                    // Also guard against if it was already "Reply: ..."
                    // But assume we are transitioning from "Email Sent".

                    // Execute INDIVIDUAL update for Reply (Formula + Note)
                    await _remoteDataSource.updateStudentStatus(
                      spreadsheetId: spreadsheetId,
                      rowIndex: actualStartRow + i,
                      statusColumnIndex: statusColumnIndex,
                      action: FollowUpAction
                          .sent, // Light Red as requested for replies
                      sheetId: sheetId,
                      formula: newFormula,
                      note: snippet, // Full decoded snippet in Note
                    );
                  } else {
                    // --- NO ANSWER ---
                    // Batch this update!
                    updates.add(
                      StudentStatusUpdateModel(
                        rowIndex: actualStartRow + i,
                        statusColumnIndex: statusColumnIndex,
                        action: FollowUpAction.noAnswer, // Dark Red
                        sheetId: sheetId,
                      ),
                    );
                  }
                }
              } catch (e) {
                // Log error but continue to next student
                // print('Error processing thread $threadId: $e');
              }
            }
          }
        }
      }

      // 3. Execute BATCH Update for "No Answer"
      if (updates.isNotEmpty) {
        await _remoteDataSource.batchUpdateStatus(
          spreadsheetId: spreadsheetId,
          updates: updates,
        );
      }

      return const Right(null);
    } on GoogleAuthException catch (e) {
      return Left(AuthFailure(e.message, e.type));
    } on SheetException catch (e) {
      return Left(Failure.sheet(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FollowUpConfigEntity?>> getFollowUpConfig() async {
    try {
      final config = await _localDataSource.getFollowUpConfig();
      return Right(config);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFollowUpConfig(
    FollowUpConfigEntity config,
  ) async {
    try {
      final model = FollowUpConfigModel(
        assignmentsSheetUrl: config.assignmentsSheetUrl,
        followUpSheetUrl: config.followUpSheetUrl,
      );
      await _localDataSource.saveFollowUpConfig(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }
}
