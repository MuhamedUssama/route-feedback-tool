import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:mentor_assistant/core/errors/auth_error_type.dart';
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

  GmailRemoteDataSourceImpl(this._googleAuthClient);

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

      final String htmlBody = _getEmailBody(student.name, assignmentName);

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
      '',
      encodedBody,
    ];

    final emailString = emailLines.join('\r\n');
    return base64Url.encode(utf8.encode(emailString));
  }

  String _getEmailBody(String studentName, String assignmentName) {
    return '''
      <div style="font-family: Arial, sans-serif; color: #333; line-height: 1.6; max-width: 600px;">
        <p>Dear <strong>$studentName</strong>,</p>
        <p>I hope this email finds you well.</p>
        <p>We noticed that we haven't received your submission for 
           <span style="background-color: #ffebee; color: #c62828; padding: 3px 6px; border-radius: 4px; font-weight: bold;">
             $assignmentName
           </span> yet.
        </p>
        <div style="background-color: #fff3cd; border-left: 5px solid #ffc107; padding: 15px; margin: 20px 0;">
          <strong>Important:</strong> Staying on track is crucial. Please submit ASAP.
        </div>
        <p>Best Regards,</p>
        <p><strong>Mentor Assistant</strong></p>
      </div>
    ''';
  }
}
