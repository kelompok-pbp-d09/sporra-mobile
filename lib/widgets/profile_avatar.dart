import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/authentication/login.dart';
import 'package:sporra_mobile/authentication/user_provider.dart';
import 'package:sporra_mobile/profile_user/screens/profile_page.dart';

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  final Color _accentBlue = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();

    // Cek status login
    if (request.loggedIn) {
      // --- JIKA SUDAH LOGIN ---

      String username = userProvider.username;
      String pfpUrl = userProvider.profilePicture; // Ambil foto dari provider

      if (username.isEmpty) {
        username = "User";
      }

      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: GestureDetector(
          onTap: () {
            // --- JAUH LEBIH SEDERHANA ---
            // Cukup push ke ProfilePage, biarkan halaman itu loading sendiri
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(isOwnProfile: true),
              ),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _accentBlue,
            // Jika ada URL foto valid, gunakan NetworkImage
            backgroundImage: (pfpUrl.isNotEmpty) ? NetworkImage(pfpUrl) : null,
            // Jika tidak ada foto, tampilkan inisial
            child: (pfpUrl.isEmpty)
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: const Text(
            "Log In",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
