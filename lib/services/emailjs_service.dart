import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailJSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _publicKey = 'YOUR_PUBLIC_KEY'; 
  static const String _serviceId = 'YOUR_SERVICE_ID'; 
  static const String _templateId = 'YOUR_TEMPLATE_ID'; 
  static const String _emailJSApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  
  Future<void> initialize() async {
    
    if (_publicKey == 'YOUR_PUBLIC_KEY' || 
        _serviceId == 'YOUR_SERVICE_ID' || 
        _templateId == 'YOUR_TEMPLATE_ID') {
      print('EmailJS: Please configure your EmailJS credentials in emailjs_service.dart');
    }
  }

  Future<bool> sendEmail({
    required String toEmail,
    required String toName,
    required String subject,
    required String message,
    String? htmlMessage,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      // Skip if not configured
      if (_publicKey == 'YOUR_PUBLIC_KEY' || 
          _serviceId == 'YOUR_SERVICE_ID' || 
          _templateId == 'YOUR_TEMPLATE_ID') {
        print('EmailJS: Configuration not set, skipping email send');
        return false;
      }

      final templateParams = {
        'to_email': toEmail,
        'to_name': toName,
        'subject': subject,
        'message': message,
        'html_message': htmlMessage ?? message,
        ...?additionalParams,
      };

      final response = await http.post(
        Uri.parse(_emailJSApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': templateParams,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('EmailJS send failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('EmailJS send error: $e');
      return false;
    }
  }

  Future<void> sendApprovalEmail({
    required String userEmail,
    required String userName,
    required String userRole,
  }) async {
    final subject = 'Account Approved - RAG FREE+';
    final message = '''
Dear $userName,

Your account has been approved! You can now access all features of the RAG FREE+ platform.

Role: ${userRole.toUpperCase()}

If you have any questions, please contact the administration.

Best regards,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: message,
      additionalParams: {
        'user_role': userRole,
        'approval_date': DateTime.now().toString(),
      },
    );
  }

  Future<void> sendPendingApprovalEmail({
    required String userEmail,
    required String userName,
    required String userRole,
  }) async {
    final subject = 'Registration Received - RAG FREE+';
    final message = '''
Dear $userName,

Thank you for registering with RAG FREE+!

Your registration has been received and is pending admin approval. You will receive an email notification once your account has been reviewed and approved.

Role: ${userRole.toUpperCase()}

We appreciate your patience.

Best regards,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: message,
      additionalParams: {
        'user_role': userRole,
      },
    );
  }

  Future<void> sendComplaintSubmittedEmail({
    required String userEmail,
    required String userName,
    required String complaintTitle,
    required String complaintId,
  }) async {
    final subject = 'Complaint Submitted - RAG FREE+';
    final message = '''
Dear $userName,

Your complaint has been successfully submitted.

Complaint Title: $complaintTitle
Complaint ID: $complaintId

Our team will review your complaint and take appropriate action. You will be notified of any updates.

Thank you for reporting this incident.

Best regards,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: message,
      additionalParams: {
        'complaint_title': complaintTitle,
        'complaint_id': complaintId,
      },
    );
  }

  Future<void> sendComplaintStatusUpdateEmail({
    required String userEmail,
    required String userName,
    required String complaintTitle,
    required String complaintId,
    required String status,
    String? assignedTo,
  }) async {
    final subject = 'Complaint Status Update - RAG FREE+';
    final message = '''
Dear $userName,

Your complaint status has been updated.

Complaint Title: $complaintTitle
Complaint ID: $complaintId
New Status: $status
${assignedTo != null ? 'Assigned To: $assignedTo' : ''}

Please log in to view more details.

Best regards,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: message,
      additionalParams: {
        'complaint_title': complaintTitle,
        'complaint_id': complaintId,
        'status': status,
        'assigned_to': assignedTo ?? '',
      },
    );
  }

  Future<void> sendEmergencyAlertEmail({
    required String userEmail,
    required String userName,
    required String alertTitle,
    required String alertMessage,
    required String priority,
  }) async {
    final subject = '🚨 EMERGENCY ALERT - $alertTitle';
    final message = '''
Dear $userName,

EMERGENCY ALERT

Priority: ${priority.toUpperCase()}
Title: $alertTitle

$alertMessage

Please take necessary precautions and follow safety guidelines.

Stay safe,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: message,
      additionalParams: {
        'alert_title': alertTitle,
        'alert_message': alertMessage,
        'priority': priority,
      },
    );
  }

  Future<void> sendPasswordResetEmail({
    required String userEmail,
    required String userName,
    required String resetLink,
  }) async {
    final subject = 'Password Reset Request - RAG FREE+';
    final htmlMessage = '''
Dear $userName,

You have requested to reset your password. Click the link below to reset it:

<a href="$resetLink">Reset Password</a>

If you did not request this, please ignore this email.

This link will expire in 1 hour.

Best regards,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: 'Please click the link in the email to reset your password: $resetLink',
      htmlMessage: htmlMessage,
      additionalParams: {
        'reset_link': resetLink,
      },
    );
  }

  Future<void> sendNotificationEmail({
    required String userEmail,
    required String userName,
    required String notificationTitle,
    required String notificationMessage,
    String? notificationType,
  }) async {
    final subject = 'Notification - $notificationTitle';
    final message = '''
Dear $userName,

$notificationTitle

$notificationMessage

Please log in to view more details.

Best regards,
RAG FREE+ Team
    ''';

    await sendEmail(
      toEmail: userEmail,
      toName: userName,
      subject: subject,
      message: message,
      additionalParams: {
        'notification_type': notificationType ?? 'general',
      },
    );
  }

  Future<void> sendBulkEmails({
    required List<String> userIds,
    required String subject,
    required String message,
    Map<String, dynamic>? templateParams,
  }) async {
    try {
      // Get user emails from Firestore
      final users = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      for (var userDoc in users.docs) {
        final userData = userDoc.data();
        final email = userData['email'] as String?;
        final name = userData['name'] as String?;

        if (email != null && email.isNotEmpty) {
          await sendEmail(
            toEmail: email,
            toName: name ?? 'User',
            subject: subject,
            message: message,
            additionalParams: templateParams,
          );
          
          // Add delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      print('Bulk email send failed: $e');
    }
  }

  Future<String?> getUserEmail(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data()?['email'] as String?;
    } catch (e) {
      return null;
    }
  }
}

