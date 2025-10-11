import 'package:flutter/material.dart';

enum UserRole { student, parent, admin, counsellor, warden, police, none }

class AppState extends ChangeNotifier {
  UserRole _role = UserRole.none;
  int _navIndex = 0;

  UserRole get role => _role;
  int get navIndex => _navIndex;

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
}
