import 'package:flutter/material.dart';
import 'package:sporra_mobile/authentication/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/screens/menu.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      backgroundColor: const Color(0xFF111827), // Gray-900
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // --- HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937), // Gray-800
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logotxt.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
                // const SizedBox(height: 5),
                const Text(
                  "Your ultimate sports companion",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- MENU ITEMS ---


          // 2. News List
          ListTile(
            leading: const Icon(Icons.newspaper, color: Colors.white),
            title: const Text(
              'News List',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainMenu(),
                ),
              );
            },
          ),

          // 3. Events (Placeholder)
          ListTile(
            leading: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            title: const Text(
              'Events',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Events segera hadir!")),
                //TODO: add redirect ke event
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.confirmation_number_outlined,
              color: Colors.white,
            ),
            title: const Text(
              'Tickets',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Tiket segera hadir!")),
              );
              //TODO: add redirect ke ticket
            },
          ),

          const Divider(color: Colors.grey),

          // 5. LOGIKA LOGIN / LOGOUT
          if (request.loggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                final response = await request.logout(
                  "https://afero-aqil-sporra.pbp.cs.ui.ac.id/auth/logout/",
                );

                String message = response["message"];
                if (context.mounted) {
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$message See you again, $uname."),
                      ),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              },
            )
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
