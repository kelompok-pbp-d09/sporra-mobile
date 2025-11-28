import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/authentication/login.dart';

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  // Warna sesuai tema Sporra
  final Color _accentBlue = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (request.loggedIn) {
      // --- JIKA SUDAH LOGIN ---

      String username = "User";
      String? pfpUrl;

      // Parsing data dari response Login
      try {
        if (request.jsonData != null && request.jsonData is Map) {
          // 1. Ambil Username
          if (request.jsonData.containsKey('username')) {
            username = request.jsonData['username'].toString();
          }

          // 2. Ambil URL Foto Profil (Cek berbagai kemungkinan key dari Django)
          // Sesuaikan 'profile_picture' dengan key yang dikirim oleh view login Django kamu
          if (request.jsonData.containsKey('profile_picture')) {
            pfpUrl = request.jsonData['profile_picture'];
          } else if (request.jsonData.containsKey('pfp')) {
            pfpUrl = request.jsonData['pfp'];
          }
        }
      } catch (e) {
        username = "User";
      }

      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Logged in as $username"),
                duration: const Duration(seconds: 1),
                backgroundColor: _accentBlue,
              ),
            );
            // TODO: Navigasi ke halaman Profil User disini
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _accentBlue,

            // LOGIKA GAMBAR:
            // Jika pfpUrl ada isinya, pakai NetworkImage. Jika tidak, null (agar child Text muncul)
            backgroundImage: (pfpUrl != null && pfpUrl.isNotEmpty)
                ? NetworkImage(pfpUrl)
                : null,

            // LOGIKA TEKS (Fallback):
            // Hanya tampilkan inisial jika tidak ada gambar
            child: (pfpUrl == null || pfpUrl.isEmpty)
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
      // --- JIKA BELUM LOGIN ---
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
            backgroundColor: _accentBlue, // Pakai warna tema
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
