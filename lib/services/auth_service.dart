import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'emailjs_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailJSService _emailJSService = EmailJSService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Save session to SharedPreferences
  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userUid', user.uid);
    await prefs.setString('userRole', user.role);
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setBool('isApproved', user.isApproved);
    if (user.department != null) await prefs.setString('userDepartment', user.department!);
    if (user.institution != null) await prefs.setString('userInstitution', user.institution!);
  }

  // Get user from session
  Future<UserModel?> getUserFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') != true) return null;

    final uid = prefs.getString('userUid');
    final role = prefs.getString('userRole');
    final name = prefs.getString('userName');
    final email = prefs.getString('userEmail');
    final isApproved = prefs.getBool('isApproved') ?? false;
    final department = prefs.getString('userDepartment');
    final institution = prefs.getString('userInstitution');

    if (uid == null || role == null || name == null || email == null) return null;

    return UserModel(
      uid: uid,
      email: email,
      name: name,
      role: role,
      isApproved: isApproved,
      department: department,
      institution: institution,
      createdAt: DateTime.now(), // Fallback
    );
  }

  // Clear session from SharedPreferences
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if session exists (simple check)
  Future<bool> hasUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? department,
    String? institution,
    String? idProofUrl,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return null;

      // All users (except admin) need approval
      // Admin is created separately and doesn't go through this flow
      bool needsApproval = role != 'admin';

      // Normalize institution name for checking matching
      final institutionNormalized = institution?.trim().replaceAll(RegExp(r'\s+'), '').toLowerCase();

      // Create user document in Firestore
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        isApproved: !needsApproval, // Only admin is auto-approved
        phone: phone,
        department: department,
        institution: institution,
        institutionNormalized: institutionNormalized,
        idProofUrl: idProofUrl,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      // Save session
      await saveUserSession(userModel);

      // Send registration confirmation email
      try {
        if (needsApproval) {
          await _emailJSService.sendPendingApprovalEmail(
            userEmail: email,
            userName: name,
            userRole: role,
          );
        }
      } catch (e) {
        // Email sending failed, but registration succeeded - continue silently
        debugPrint('Registration email failed: $e');
      }

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

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

      final userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      
      // Save session
      await saveUserSession(userModel);
      
      return userModel;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

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

      // Save session
      await saveUserSession(adminModel);

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

          // Save session
          await saveUserSession(adminModel);

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

              // Save session
              await saveUserSession(adminModel);

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
          'role': 'counsellor',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get counselors: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

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

  Future<void> approveUser(String userId) async {
    try {
      // Get user data before updating
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      
      final userData = userDoc.data()!;
      final userEmail = userData['email'] as String?;
      final userName = userData['name'] as String?;
      final userRole = userData['role'] as String?;

      await _firestore.collection('users').doc(userId).update({
        'isApproved': true,
      });

      // Send approval email
      if (userEmail != null && userName != null && userRole != null) {
        try {
          await _emailJSService.sendApprovalEmail(
            userEmail: userEmail,
            userName: userName,
            userRole: userRole,
          );
        } catch (e) {
          // Email sending failed, but approval succeeded - continue silently
          debugPrint('Approval email failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to approve user: ${e.toString()}');
    }
  }

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

  Stream<List<UserModel>> getPendingApprovals() {
    return _firestore
        .collection('users')
        .where('isApproved', isEqualTo: false)
        .where('role', whereIn: ['student', 'parent', 'police', 'counsellor', 'warden', 'teacher'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap({...doc.data(), 'uid': doc.id}))
          .toList();
    });
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap({...doc.data(), 'uid': doc.id}))
          .toList();
    });
  }

  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap({...doc.data(), 'uid': doc.id}))
          .toList();
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await clearUserSession();
    await _auth.signOut();
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Re-authenticate user
    final email = user.email;
    if (email == null) throw Exception('User email not found');

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Delete from Firestore first
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Clear session
      await clearUserSession();
      
      // Delete from Auth
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}

