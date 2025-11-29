import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/complaint_model.dart';
import 'cloudinary_service.dart';
import 'emailjs_service.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final EmailJSService _emailJSService = EmailJSService();

  // Submit a complaint
  Future<ComplaintModel> submitComplaint({
    required ComplaintModel complaint,
    List<File>? mediaFiles,
  }) async {
    try {
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
      final complaintWithMedia = complaint.copyWith(mediaUrls: mediaUrls);

      // Save to Firestore - always use Firestore's auto-generated ID for consistency
      final docRef = _firestore.collection('complaints').doc();
      
      // Remove id from map before saving (Firestore manages the document ID)
      final complaintMap = complaintWithMedia.toMap();
      complaintMap.remove('id');
      
      await docRef.set(complaintMap);

      final complaintId = docRef.id;
      final finalComplaint = complaintWithMedia.copyWith(id: complaintId);

      // Send email notification to student (if not anonymous)
      if (complaint.studentId != null) {
        try {
          final userEmail = await _emailJSService.getUserEmail(complaint.studentId!);
          if (userEmail != null) {
            await _emailJSService.sendComplaintSubmittedEmail(
              userEmail: userEmail,
              userName: complaint.studentName ?? 'Student',
              complaintTitle: complaint.title,
              complaintId: complaintId,
            );
          }
        } catch (e) {
          // Email sending failed, but complaint was submitted - continue silently
          print('Complaint submission email failed: $e');
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
    // Note: This requires a composite index in Firestore: studentId (ASC) + createdAt (DESC)
    return _firestore
        .collection('complaints')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get all complaints (for admin/counselor)
  Stream<List<ComplaintModel>> getAllComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get complaints by status
  Stream<List<ComplaintModel>> getComplaintsByStatus(String status) {
    return _firestore
        .collection('complaints')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get complaints assigned to a counselor
  Stream<List<ComplaintModel>> getAssignedComplaints(String counselorId) {
    // Note: This requires a composite index in Firestore: assignedTo (ASC) + createdAt (DESC)
    return _firestore
        .collection('complaints')
        .where('assignedTo', isEqualTo: counselorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get complaints for a parent's linked students
  Stream<List<ComplaintModel>> getParentChildComplaints(
      List<String> studentIds) {
    if (studentIds.isEmpty) {
      return Stream.value([]);
    }
    // Note: whereIn with orderBy requires a composite index in Firestore
    // Limit to 10 IDs as Firestore whereIn supports max 10 items
    final limitedIds = studentIds.length > 10 ? studentIds.sublist(0, 10) : studentIds;
    return _firestore
        .collection('complaints')
        .where('studentId', whereIn: limitedIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
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
          final userEmail = await _emailJSService.getUserEmail(complaint.studentId!);
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
          print('Complaint status update email failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update complaint: ${e.toString()}');
    }
  }

  // Assign complaint to counselor
  Future<void> assignComplaint(
    String complaintId,
    String counselorId,
    String counselorName,
  ) async {
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
          final userEmail = await _emailJSService.getUserEmail(complaint.studentId!);
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
          print('Complaint assignment email failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to assign complaint: ${e.toString()}');
    }
  }

  // Get complaint by ID
  Future<ComplaintModel?> getComplaintById(String complaintId) async {
    try {
      final doc = await _firestore.collection('complaints').doc(complaintId).get();
      if (!doc.exists) return null;
      return ComplaintModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get complaint: ${e.toString()}');
    }
  }
}

