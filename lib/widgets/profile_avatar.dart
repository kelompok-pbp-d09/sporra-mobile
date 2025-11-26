import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/screens/login.dart';

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (request.loggedIn) {
      // JIKA SUDAH LOGIN: Tampilkan Avatar
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: GestureDetector(
          onTap: () {
            // Nanti bisa arahkan ke halaman Profile
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Membuka Profil User...")),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue[700],
            // Jika ada URL foto profil di Django, pakai NetworkImage
            // child: NetworkImage('url_foto'),
            child: Text(
              request.jsonData['username'] != null 
                  ? request.jsonData['username'][0].toUpperCase() 
                  : "U",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      // JIKA BELUM LOGIN: Tampilkan Tombol Login/Register
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
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: const Text("Log In"),
        ),
      );
    }
  }
}