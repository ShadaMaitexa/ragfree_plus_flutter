import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit feedback
  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      await _firestore.collection('feedback').add(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to submit feedback: ${e.toString()}');
    }
  }

  // Get all feedback (for admin)
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get feedback by role
  Stream<List<FeedbackModel>> getFeedbackByRole(String role) {
    return _firestore
        .collection('feedback')
        .where('userRole', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }
}
