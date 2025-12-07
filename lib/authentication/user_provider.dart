import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserProvider extends ChangeNotifier {
  String _username = "";
  String _profilePicture = "";
  bool _isAdmin = false;

  // Getter
  String get username => _username;
  String get profilePicture => _profilePicture;
  bool get isAdmin => _isAdmin;

  // Setter
  void setUser(
    String username, {
    bool isAdmin = false,
    String profilePicture = "",
  }) {
    _username = username;
    _profilePicture = profilePicture;
    _isAdmin = isAdmin;
    notifyListeners();
  }

  // --- FUNGSI BARU: MENGAMBIL DATA USER DARI SERVER ---
  Future<bool> fetchUserData(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/json/',
      );

      if (response['status'] == true) {
        setUser(
          response['username'],
          // Mapping 'is_superuser' dari Django ke 'isAdmin' di Flutter
          isAdmin: response['is_superuser'] ?? false,
          // Mapping 'profile_picture'
          profilePicture: response['profile_picture'] ?? "",
        );
        return true; // Berhasil ambil data
      } else {
        return false; // Gagal (misal belum login di sisi server)
      }
    } catch (e) {
      print("Gagal fetch user data: $e");
      return false;
    }
  }

  void logout() {
    _username = "";
    _profilePicture = "";
    _isAdmin = false;
    notifyListeners();
  }
}
