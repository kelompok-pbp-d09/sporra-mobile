import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _username = "";
  String _profilePicture = ""; // Tambahan variabel foto profil
  bool _isAdmin = false;

  // Getter
  String get username => _username;
  String get profilePicture => _profilePicture; // Getter foto profil
  bool get isAdmin => _isAdmin;

  // Setter
  void setUser(String username, {bool isAdmin = false, String profilePicture = ""}) {
    _username = username;
    _profilePicture = profilePicture;

    // Logika Validasi Admin
    if (_username == "admin") {
      _isAdmin = true;
    } else {
      _isAdmin = isAdmin;
    }

    notifyListeners();
  }

  void logout() {
    _username = "";
    _profilePicture = ""; // Reset foto profil
    _isAdmin = false;
    notifyListeners();
  }
}