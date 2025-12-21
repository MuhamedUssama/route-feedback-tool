import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:mentor_assistant/core/errors/auth_error_type.dart';
import 'package:mentor_assistant/core/services/shared_prefs_service.dart';
import 'package:mentor_assistant/features/auth/data/models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/google_auth_client.dart';
import '../../domain/entities/student_entity.dart';

abstract interface class GmailRemoteDataSource {
  Future<void> sendFollowUpEmail({
    required StudentEntity student,
    required String assignmentName,
  });
}

@LazySingleton(as: GmailRemoteDataSource)
class GmailRemoteDataSourceImpl implements GmailRemoteDataSource {
  final GoogleAuthClient _googleAuthClient;
  final SharedPrefsService _sharedPrefsService;
  GmailRemoteDataSourceImpl(this._googleAuthClient, this._sharedPrefsService);

  @override
  Future<void> sendFollowUpEmail({
    required StudentEntity student,
    required String assignmentName,
  }) async {
    try {
      final client = await _googleAuthClient.getAuthenticatedClient();
      if (client == null) {
        throw const GoogleAuthException(
          'User not authenticated',
          AuthErrorType.userNotAuthenticated,
        );
      }

      if (student.email.trim().isEmpty) {
        throw const ServerException('Student email is empty');
      }

      final GmailApi gmailApi = GmailApi(client);
      final UserModel? user = await _sharedPrefsService.getUser();
      final String mentorName = user?.displayName ?? 'Mentor';
      final String htmlBody = _getEmailBody(
        student.name,
        assignmentName,
        mentorName,
      );

      final Message message = Message()
        ..raw = _createEmail(
          to: student.email,
          subject: 'Action Required: Missing Submission for $assignmentName',
          body: htmlBody,
        );

      await gmailApi.users.messages.send(message, 'me');
    } catch (e) {
      throw ServerException('Failed to send email: $e');
    }
  }

  String _createEmail({
    required String to,
    required String subject,
    required String body,
  }) {
    final utf8Subject = '=?utf-8?B?${base64.encode(utf8.encode(subject))}?=';

    final encodedBody = base64.encode(utf8.encode(body));

    final emailLines = [
      'To: $to',
      'Subject: $utf8Subject',
      'MIME-Version: 1.0',
      'Content-Type: text/html; charset=utf-8',
      'Content-Transfer-Encoding: base64',
      'Importance: High',
      'X-Priority: 1',
      'X-MSMail-Priority: High',
      '',
      encodedBody,
    ];

    final emailString = emailLines.join('\r\n');
    return base64Url.encode(utf8.encode(emailString));
  }

  String _getEmailBody(
    String studentName,
    String assignmentName,
    String mentorName,
  ) {
    return '''
      <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #2c3e50; line-height: 1.6; max-width: 600px; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
        
        <div style="background-color: #0d47a1; padding: 20px; text-align: center;">
          <h2 style="color: white; margin: 0; font-size: 20px;">Action Required: Missing Submission</h2>
        </div>

        <div style="padding: 30px;">
          <p style="font-size: 16px;">Hi <strong>$studentName</strong>,</p>
          
          <p>I hope you are doing well.</p>
          
          <p>This is a gentle reminder that we have not yet received your submission for:</p>
          
          <div style="text-align: center; margin: 25px 0;">
            <span style="background-color: #fce4ec; color: #c2185b; padding: 10px 20px; border-radius: 16px; font-weight: bold; font-size: 16px; border: 1px solid #f8bbd0;">
              $assignmentName
            </span>
          </div>

          <p>If you are facing any technical issues or need clarification on the task, please let me know.</p>

          <div style="background-color: #e3f2fd; border-left: 4px solid #1976d2; padding: 15px; margin: 20px 0; font-size: 14px; color: #0d47a1;">
            <strong>Note:</strong> Consistent practice is key to mastering Flutter. Please submit your work as soon as possible to keep up with the schedule.
          </div>

          <p style="margin-top: 30px;">Best Regards,</p>
          <p style="font-size: 16px; font-weight: bold; color: #0d47a1;">Eng. $mentorName</p>
        </div>
        
        <div style="background-color: #f5f5f5; padding: 10px; text-align: center; font-size: 12px; color: #7f8c8d;">
          Please reply to this email if you have any questions or need further assistance.
        </div>

      </div>
    ''';
  }
}
