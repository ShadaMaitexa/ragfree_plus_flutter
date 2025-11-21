import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register user with role
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? department,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return null;

      // Determine if approval is needed
      bool needsApproval = role == 'police' || role == 'counsellor' || role == 'warden';

      // Create user document in Firestore
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        isApproved: !needsApproval, // Students and parents are auto-approved
        phone: phone,
        department: department,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<UserModel?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return null;

      // Get user data from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('User data not found');
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Admin hardcoded login
  Future<UserModel?> adminLogin({
    required String email,
    required String password,
  }) async {
    // Hardcoded admin credentials
    const String adminEmail = 'admin@ragfree.com';
    const String adminPassword = 'Admin@123';

    if (email != adminEmail || password != adminPassword) {
      throw Exception('Invalid admin credentials');
    }

    try {
      // Try to sign in with admin credentials
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      if (userCredential.user == null) return null;

      // Check if admin user exists in Firestore, if not create it
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      UserModel adminModel;
      if (!doc.exists) {
        // Create admin user in Firestore
        adminModel = UserModel(
          uid: userCredential.user!.uid,
          email: adminEmail,
          name: 'Administrator',
          role: 'admin',
          isApproved: true,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(adminModel.toMap());
      } else {
        adminModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return adminModel;
    } catch (e) {
      // If admin doesn't exist or credentials are invalid, create the account first
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user-not-found') || 
          errorString.contains('invalid-credential') ||
          errorString.contains('wrong-password')) {
        try {
          // First, try to create the admin account
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

          if (userCredential.user == null) {
            throw Exception('Failed to create admin account');
          }

          // Create admin user in Firestore
          UserModel adminModel = UserModel(
            uid: userCredential.user!.uid,
            email: adminEmail,
            name: 'Administrator',
            role: 'admin',
            isApproved: true,
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(adminModel.toMap());

          return adminModel;
        } catch (createError) {
          // If account already exists, try to sign in again
          if (createError.toString().toLowerCase().contains('already-in-use')) {
            try {
              UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                email: adminEmail,
                password: adminPassword,
              );

              if (userCredential.user == null) return null;

              // Get or create admin user in Firestore
              DocumentSnapshot doc = await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .get();

              UserModel adminModel;
              if (!doc.exists) {
                adminModel = UserModel(
                  uid: userCredential.user!.uid,
                  email: adminEmail,
                  name: 'Administrator',
                  role: 'admin',
                  isApproved: true,
                  createdAt: DateTime.now(),
                );
                await _firestore
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set(adminModel.toMap());
              } else {
                adminModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
              }

              return adminModel;
            } catch (signInError) {
              throw Exception('Admin login failed: ${signInError.toString()}');
            }
          }
          throw Exception('Failed to create admin account: ${createError.toString()}');
        }
      }
      throw Exception('Admin login failed: ${e.toString()}');
    }
  }

  // Get available counselors for assignment
  Future<List<Map<String, dynamic>>> getAvailableCounselors() async {
    try {
      final counselors = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'counsellor')
          .where('isApproved', isEqualTo: true)
          .get();

      return counselors.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Counselor',
          'department': data['department'],
          'email': data['email'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get counselors: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Check if user is approved (for police and teachers)
  Future<bool> isUserApproved(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      return user.isApproved;
    } catch (e) {
      return false;
    }
  }

  // Admin approve user (police or teacher)
  Future<void> approveUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isApproved': true,
      });
    } catch (e) {
      throw Exception('Failed to approve user: ${e.toString()}');
    }
  }

  // Admin reject user
  Future<void> rejectUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      // Also delete from auth if it's the current user
      User? user = _auth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to reject user: ${e.toString()}');
    }
  }

  // Get pending approvals (police and teachers)
  Stream<List<UserModel>> getPendingApprovals() {
    return _firestore
        .collection('users')
        .where('isApproved', isEqualTo: false)
        .where('role', whereIn: ['police', 'counsellor', 'warden'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

