import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/authentication/login.dart';
import 'package:sporra_mobile/profile_user/screens/profile_page.dart'; // Sesuaikan path

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  final Color _accentBlue = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (request.loggedIn) {
      // Ambil data PFP dari cookie login untuk tampilan avatar kecil di navbar
      String username = "U";
      String? pfpUrl;
      
      try {
        if (request.jsonData is Map) {
          username = request.jsonData['username'] ?? "U";
          pfpUrl = request.jsonData['profile_picture']; 
        }
      } catch (e) {
        // ignore error
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
            backgroundImage: (pfpUrl != null && pfpUrl.isNotEmpty)
                ? NetworkImage(pfpUrl)
                : null,
            child: (pfpUrl == null || pfpUrl.isEmpty)
                ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : "U",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          style: ElevatedButton.styleFrom(backgroundColor: _accentBlue, foregroundColor: Colors.white),
          child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
  }
}