import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit feedback
  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      final docRef = _firestore.collection('feedback').doc();
      final updatedFeedback = feedback.copyWith(id: docRef.id);
      await docRef.set(updatedFeedback.toMap());
    } catch (e) {
      throw Exception('Failed to submit feedback: ${e.toString()}');
    }
  }

  // Get all feedback (for admin)
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection('feedback')
        
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FeedbackModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get feedback by role
  Stream<List<FeedbackModel>> getFeedbackByRole(String role) {
    return _firestore
        .collection('feedback')
        .where('userRole', isEqualTo: role)
        
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FeedbackModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get user's own feedback
  Stream<List<FeedbackModel>> getUserFeedback(String userId) {
    return _firestore
        .collection('feedback')
        .where('userId', isEqualTo: userId)
       
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FeedbackModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Delete feedback (for admin)
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: ${e.toString()}');
    }
  }
}
