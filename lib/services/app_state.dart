import 'package:flutter/material.dart';
import '../models/user_model.dart';

enum UserRole { student, parent, admin, counsellor, warden, police, teacher, none }

class AppState extends ChangeNotifier {
  UserRole _role = UserRole.none;
  int _navIndex = 0;
  UserModel? _currentUser;

  UserRole get role => _role;
  int get navIndex => _navIndex;
  UserModel? get currentUser => _currentUser;

  void setRole(UserRole role) {
    if (_role == role) return;
    _role = role;
    _navIndex = 0;
    notifyListeners();
  }

  void setNavIndex(int index) {
    if (_navIndex == index) return;
    _navIndex = index;
    notifyListeners();
  }

  void setUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      switch (user.role) {
        case 'student':
          _role = UserRole.student;
          break;
        case 'parent':
          _role = UserRole.parent;
          break;
        case 'admin':
          _role = UserRole.admin;
          break;
        case 'counsellor':
          _role = UserRole.counsellor;
          break;
        case 'warden':
          _role = UserRole.warden;
          break;
        case 'police':
          _role = UserRole.police;
          break;
        case 'teacher':
          _role = UserRole.teacher;
          break;
        default:
          _role = UserRole.none;
      }
    } else {
      _role = UserRole.none;
    }
    _navIndex = 0;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _role = UserRole.none;
    _navIndex = 0;
    notifyListeners();
  }
}
