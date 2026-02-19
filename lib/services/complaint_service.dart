import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/complaint_model.dart';
import 'cloudinary_service.dart';
import 'emailjs_service.dart';
import 'activity_service.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final EmailJSService _emailJSService = EmailJSService();
  final ActivityService _activityService = ActivityService();

  // Submit a complaint
  Future<ComplaintModel> submitComplaint({
    required ComplaintModel complaint,
    List<File>? mediaFiles,
  }) async {
    try {
      // Fetch current user details to populate reporter info and institution
      final user = FirebaseAuth.instance.currentUser;
      ComplaintModel complaintToSubmit = complaint;

      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            complaintToSubmit = complaintToSubmit.copyWith(
              institution:
                  complaintToSubmit.institution ?? userData['institution'],
              institutionNormalized:
                  complaintToSubmit.institutionNormalized ??
                  userData['institutionNormalized'],
              studentDepartment:
                  complaintToSubmit.studentDepartment ?? userData['department'],
              reporterId: complaintToSubmit.reporterId ?? user.uid,
              reporterName: complaintToSubmit.reporterName ?? userData['name'],
              reporterRole: complaintToSubmit.reporterRole ?? userData['role'],
            );
          }
        }
      }

      // Upload media files to Cloudinary if any
      List<String> mediaUrls = [];
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (var file in mediaFiles) {
          final extension = file.path.split('.').last.toLowerCase();
          String? url;

          // Determine media type and upload accordingly
          if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
            url = await _cloudinaryService.uploadVideo(file);
          } else if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension)) {
            url = await _cloudinaryService.uploadAudio(file);
          } else {
            url = await _cloudinaryService.uploadImage(file);
          }

          if (url != null) mediaUrls.add(url);
        }
      }

      // Update complaint with media URLs
      final complaintWithMedia = complaintToSubmit.copyWith(
        mediaUrls: mediaUrls,
      );

      // Save to Firestore - always use Firestore's auto-generated ID for consistency
      final docRef = _firestore.collection('complaints').doc();
      final complaintId = docRef.id;

      // Update complaint with ID and media URLs
      final finalComplaint = complaintWithMedia.copyWith(id: complaintId);

      await docRef.set(finalComplaint.toMap());

      // Record activity
      if (complaintToSubmit.studentId != null) {
        try {
          await _activityService.createActivityFromComplaint(
            userId: complaintToSubmit.studentId!,
            complaint: finalComplaint,
            activityType: 'created',
          );
        } catch (e) {
          debugPrint('Failed to record activity: $e');
        }
      }

      // Send email notification to student (if not anonymous)
      if (complaintToSubmit.studentId != null) {
        try {
          final userEmail = await _emailJSService.getUserEmail(
            complaintToSubmit.studentId!,
          );
          if (userEmail != null) {
            await _emailJSService.sendComplaintSubmittedEmail(
              userEmail: userEmail,
              userName: complaintToSubmit.studentName ?? 'Student',
              complaintTitle: complaintToSubmit.title,
              complaintId: complaintId,
            );
          }
        } catch (e) {
          // Email sending failed, but complaint was submitted - continue silently
          debugPrint('Complaint submission email failed: $e');
        }
      }

      // Return complaint with the actual Firestore document ID
      return finalComplaint;
    } catch (e) {
      throw Exception('Failed to submit complaint: ${e.toString()}');
    }
  }

  // Get complaints for a student
  Stream<List<ComplaintModel>> getStudentComplaints(String studentId) {
    return _firestore
        .collection('complaints')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get all complaints (for admin/counselor)
  Stream<List<ComplaintModel>> getAllComplaints() {
    return _firestore
        .collection('complaints')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get complaints by status
  Stream<List<ComplaintModel>> getComplaintsByStatus(String status) {
    return _firestore
        .collection('complaints')
        .where('status', isEqualTo: status)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get complaints assigned to a counselor
  Stream<List<ComplaintModel>> getAssignedComplaints(String counselorId) {
    return _firestore
        .collection('complaints')
        .where(
          Filter.or(
            Filter('assignedTo', isEqualTo: counselorId),
            Filter('metadata.forwardedTo', isEqualTo: 'counsellor'),
          ),
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get complaints for Warden (Hostel incidents)
  Stream<List<ComplaintModel>> getHostelComplaints() {
    // Get hostel complaints
    final hostelStream = _firestore
        .collection('complaints')
        .where('incidentType', isEqualTo: 'Hostel')
        .snapshots();

    // Get complaints forwarded to warden

    // Combine both streams
    return hostelStream.asyncMap((hostelSnapshot) async {
      final forwardedSnapshot = await _firestore
          .collection('complaints')
          .where('metadata.forwardedTo', isEqualTo: 'warden')
          .get();

      final hostelComplaints = hostelSnapshot.docs
          .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      final forwardedComplaints = forwardedSnapshot.docs
          .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Merge and deduplicate by ID
      final allComplaints = <String, ComplaintModel>{};
      for (var c in hostelComplaints) {
        allComplaints[c.id] = c;
      }
      for (var c in forwardedComplaints) {
        allComplaints[c.id] = c;
      }

      return allComplaints.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // Get complaints for Teacher (College incidents) - DEPRECATED/LEGACY
  Stream<List<ComplaintModel>> getCollegeComplaints() {
    return _firestore
        .collection('complaints')
        .where('incidentType', isEqualTo: 'College')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get complaints by Institution (for Teachers/Admin)
  Stream<List<ComplaintModel>> getComplaintsByInstitution(
    String institutionNormalized,
  ) {
    if (institutionNormalized.isEmpty) return Stream.value([]);
    return _firestore
        .collection('complaints')
        .where('institutionNormalized', isEqualTo: institutionNormalized)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get complaints by Department (for Teachers)
  Stream<List<ComplaintModel>> getComplaintsByDepartment(
    String institutionNormalized,
    String department,
  ) {
    if (institutionNormalized.isEmpty || department.isEmpty)
      return Stream.value([]);
    return _firestore
        .collection('complaints')
        .where('institutionNormalized', isEqualTo: institutionNormalized)
        .where('studentDepartment', isEqualTo: department)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get complaints for a parent's linked students
  Stream<List<ComplaintModel>> getParentChildComplaints(
    List<String> studentIds,
  ) {
    if (studentIds.isEmpty) {
      return Stream.value([]);
    }
    // Limit to 10 IDs as Firestore whereIn supports max 10 items
    final limitedIds = studentIds.length > 10
        ? studentIds.sublist(0, 10)
        : studentIds;
    return _firestore
        .collection('complaints')
        .where('studentId', whereIn: limitedIds)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String complaintId, String status) async {
    try {
      // Get complaint data before updating
      final complaint = await getComplaintById(complaintId);
      if (complaint == null) {
        throw Exception('Complaint not found');
      }

      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });

      // Send email notification to student (if not anonymous)
      if (complaint.studentId != null) {
        try {
          final userEmail = await _emailJSService.getUserEmail(
            complaint.studentId!,
          );
          if (userEmail != null) {
            await _emailJSService.sendComplaintStatusUpdateEmail(
              userEmail: userEmail,
              userName: complaint.studentName ?? 'Student',
              complaintTitle: complaint.title,
              complaintId: complaintId,
              status: status,
            );
          }
        } catch (e) {
          // Email sending failed, but status was updated - continue silently
          debugPrint('Complaint status update email failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update complaint: ${e.toString()}');
    }
  }

  // Assign complaint to counselor
  Future<void> assignComplaint({
    required String complaintId,
    required String counselorId,
    required String counselorName,
  }) async {
    try {
      // Get complaint data before updating
      final complaint = await getComplaintById(complaintId);
      if (complaint == null) {
        throw Exception('Complaint not found');
      }

      await _firestore.collection('complaints').doc(complaintId).update({
        'assignedTo': counselorId,
        'assignedToName': counselorName,
        'status': 'In Progress',
        'updatedAt': Timestamp.now(),
      });

      // Send email notification to student (if not anonymous)
      if (complaint.studentId != null) {
        try {
          final userEmail = await _emailJSService.getUserEmail(
            complaint.studentId!,
          );
          if (userEmail != null) {
            await _emailJSService.sendComplaintStatusUpdateEmail(
              userEmail: userEmail,
              userName: complaint.studentName ?? 'Student',
              complaintTitle: complaint.title,
              complaintId: complaintId,
              status: 'In Progress',
              assignedTo: counselorName,
            );
          }
        } catch (e) {
          // Email sending failed, but complaint was assigned - continue silently
          debugPrint('Complaint assignment email failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to assign complaint: ${e.toString()}');
    }
  }

  // Get complaint by ID
  Future<ComplaintModel?> getComplaintById(String complaintId) async {
    try {
      final doc = await _firestore
          .collection('complaints')
          .doc(complaintId)
          .get();
      if (!doc.exists) return null;
      return ComplaintModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get complaint: ${e.toString()}');
    }
  }

  // Update complaint (for student editing)
  Future<void> updateComplaint(ComplaintModel complaint) async {
    try {
      await _firestore.collection('complaints').doc(complaint.id).update({
        ...complaint.toMap(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update complaint: ${e.toString()}');
    }
  }

  // Update complaint with new media files
  Future<void> updateComplaintWithMedia({
    required ComplaintModel complaint,
    List<File>? newMediaFiles,
  }) async {
    try {
      List<String> newMediaUrls = [];

      // Upload new files if provided
      if (newMediaFiles != null && newMediaFiles.isNotEmpty) {
        for (var file in newMediaFiles) {
          final extension = file.path.split('.').last.toLowerCase();
          String? url;

          if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
            url = await _cloudinaryService.uploadVideo(file);
          } else if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension)) {
            url = await _cloudinaryService.uploadAudio(file);
          } else {
            url = await _cloudinaryService.uploadImage(file);
          }

          if (url != null) newMediaUrls.add(url);
        }
      }

      // Combine existing and new URLs
      final updatedMediaUrls = [...complaint.mediaUrls, ...newMediaUrls];
      final finalComplaint = complaint.copyWith(mediaUrls: updatedMediaUrls);

      // calls existing update method
      await updateComplaint(finalComplaint);
    } catch (e) {
      throw Exception('Failed to update complaint with media: ${e.toString()}');
    }
  }

  // Delete complaint
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: ${e.toString()}');
    }
  }

  // Verify complaint (for Police/Teacher/Warden)
  Future<void> verifyComplaint({
    required String complaintId,
    required String verifierId,
    required String verifierName,
    required String verifierRole,
    String? notes,
  }) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'Verified',
        'metadata.verifiedBy': verifierId,
        'metadata.verifiedByName': verifierName,
        'metadata.verifiedByRole': verifierRole,
        'metadata.verifiedAt': Timestamp.now(),
        'metadata.verifiedNotes': notes,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to verify complaint: ${e.toString()}');
    }
  }

  // Reject action (for Police/Teacher/Warden)
  Future<void> rejectAction({
    required String complaintId,
    required String rejectorId,
    required String rejectorName,
    required String rejectorRole,
    String? reason,
  }) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'Pending',
        'metadata.rejectedBy': rejectorId,
        'metadata.rejectedByName': rejectorName,
        'metadata.rejectedByRole': rejectorRole,
        'metadata.rejectedAt': Timestamp.now(),
        'metadata.rejectionReason': reason,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to reject action: ${e.toString()}');
    }
  }

  // Accept complaint (for Teacher/Counsellor)
  Future<void> acceptComplaint({
    required String complaintId,
    required String acceptorId,
    required String acceptorName,
    required String acceptorRole,
  }) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'Accepted',
        'metadata.acceptedBy': acceptorId,
        'metadata.acceptedByName': acceptorName,
        'metadata.acceptedByRole': acceptorRole,
        'metadata.acceptedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to accept complaint: ${e.toString()}');
    }
  }

  // Forward complaint to another role (e.g., Teacher to Police)
  Future<void> forwardToRole({
    required String complaintId,
    required String forwardToRole,
    required String forwarderId,
    required String forwarderName,
    String? description,
  }) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'metadata.forwardedTo': forwardToRole,
        'metadata.forwardedBy': forwarderId,
        'metadata.forwardedByName': forwarderName,
        'metadata.forwardedAt': Timestamp.now(),
        'metadata.forwardDescription': description,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to forward complaint: ${e.toString()}');
    }
  }
}
