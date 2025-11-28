import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';
import 'package:sporra_mobile/authentication/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/screens/menu.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      // Mengatur warna background Drawer agar gelap (sesuai tema)
      backgroundColor: const Color(0xFF111827), // Gray-900
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(
                0xFF1F2937,
              ), // Gray-800 (sedikit lebih terang dari body)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPORRA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Your ultimate sports companion",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),

          // --- MENU ITEMS ---

          // News Feed
          ListTile(
            leading: const Icon(Icons.newspaper, color: Colors.white),
            title: const Text('News Feed', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainMenu()),
              );
            },
          ),


          // Tickets
          ListTile(
            leading: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
            ),
            title: const Text(
              'Tickets (Soon)',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Tiket segera hadir!")),
              );
            },
          ),

          // Divider pemisah
          const Divider(color: Colors.grey),

          // 4. LOGIKA LOGIN / LOGOUT
          // Jika user sedang login, tampilkan tombol Logout
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                // Logika Logout sesuai tutorial
                // Ganti URL dengan URL aplikasi Django kamu
                final response = await request.logout(
                  "https://afero-aqil-sporra.pbp.cs.ui.ac.id//auth/logout/",
                ); // Sesuaikan port/I

                String message = response["message"];
                if (context.mounted) {
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$message See you again, $uname."),
                      ),
                    );
                    // Kembali ke halaman Login setelah logout
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              },
            )
          // Jika user belum login, tampilkan tombol Login
          else
            ListTile(
              leading: const Icon(Icons.login, color: Colors.blueAccent),
              title: const Text(
                'Login',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
        ],
      ),
    );
  }
}
