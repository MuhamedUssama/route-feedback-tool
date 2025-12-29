import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
      final int actualStartRow = followUpHeaderRowIndex + 1;

      const int endRow = 500;

      final formulas = await _remoteDataSource.getColumnFormulas(
        spreadsheetId: spreadsheetId,
        sheetId: sheetId,
        columnIndex: statusColumnIndex,
        startRow: actualStartRow,
        endRow: endRow,
      );

      final threadIdRegex = RegExp(r'#inbox/([a-z0-9]+)', caseSensitive: false);
      final urlRegex = RegExp(r'=HYPERLINK\("([^"]+)"', caseSensitive: false);

      for (int i = 0; i < formulas.length; i++) {
        final formula = formulas[i];

        if (formula.contains('=HYPERLINK')) {
          final threadIdMatch = threadIdRegex.firstMatch(formula);
          final urlMatch = urlRegex.firstMatch(formula);

          if (threadIdMatch != null && urlMatch != null) {
            final threadId = threadIdMatch.group(1);
            final currentUrl = urlMatch.group(1);

            if (threadId != null && currentUrl != null) {
              try {
                final thread = await _transportGmail.getThread(threadId);
                final messages = thread.messages;

                if (messages != null && messages.isNotEmpty) {
                  final studentMessages = <String>[];

                  // Regex to remove "On ... wrote:" and similar quotaion headers
                  // We'll use a basic version that catches common Gmail headers
                  final quoteRegex = RegExp(
                    r'On\s+.*wrote:.*',
                    caseSensitive: false,
                    dotAll: true,
                  );

                  for (var message in messages) {
                    bool isSentByMe = false;
                    if (message.labelIds != null &&
                        message.labelIds!.contains('SENT')) {
                      isSentByMe = true;
                    }

                    if (!isSentByMe) {
                      var snippet = message.snippet ?? "";
                      if (snippet.isNotEmpty) {
                        // Decode HTML entities
                        final unescape = HtmlUnescape();
                        snippet = unescape.convert(snippet);

                        // Clean quotes (if snippet contains them, though snippet usually short)
                        snippet = snippet.replaceAll(quoteRegex, '').trim();

                        if (snippet.isNotEmpty) {
                          studentMessages.add(snippet);
                        }
                      }
                    }
                  }

                  if (studentMessages.isNotEmpty) {
                    // --- REPLY FOUND (At least one) ---

                    // Form Accumulated Note
                    final noteBuffer = StringBuffer();
                    for (var msg in studentMessages) {
                      noteBuffer.writeln('- $msg');
                    }
                    final accumulatedNote = noteBuffer.toString().trim();

                    // Reconstruct Formula: =HYPERLINK("$currentUrl", "📩 Reply Received")
                    final newFormula =
                        '=HYPERLINK("$currentUrl", "📩 Reply Received")';

                    // Execute INDIVIDUAL update for Reply (Formula + Note)
                    await _remoteDataSource.updateStudentStatus(
                      spreadsheetId: spreadsheetId,
                      rowIndex: actualStartRow + i,
                      statusColumnIndex: statusColumnIndex,
                      action: FollowUpAction
                          .sent, // Light Red (0xFFFFCDD2) as requested
                      sheetId: sheetId,
                      formula: newFormula,
                      note: accumulatedNote,
                    );
                  } else {
                    // --- NO ANSWER ---
                    // Reconstruct Formula: =HYPERLINK("currentUrl", "No Answer")
                    final newFormula = '=HYPERLINK("$currentUrl", "No Answer")';

                    await _remoteDataSource.updateStudentStatus(
                      spreadsheetId: spreadsheetId,
                      rowIndex: actualStartRow + i,
                      statusColumnIndex: statusColumnIndex,
                      action: FollowUpAction.noAnswer, // Bright Red
                      sheetId: sheetId,
                      formula: newFormula,
                      note: '', // Clear any previous notes
                    );
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  log('Error processing thread $threadId: $e');
                }
              }
            }
          }
        }
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
