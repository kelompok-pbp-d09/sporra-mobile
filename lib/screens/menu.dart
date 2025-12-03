import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';
import 'package:sporra_mobile/news/screens/news_form.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';
import 'package:sporra_mobile/widgets/profile_avatar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NewsEntryListPage(isEmbedded: true),
    const Center(
      child: Text(
        "Event Page (Coming Soon)",
        style: TextStyle(color: Colors.white),
      ),
    ),
    const Center(
      child: Text(
        "Tickets Page (Coming Soon)",
        style: TextStyle(color: Colors.white),
      ),
    ),
  ];

  final List<String> _titles = ["News Feed", "Events", "Tickets"];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const ProfileAvatarButton(), // Pindahkan const ke sini (opsional) atau hapus saja
        ],
      ),

      drawer: const LeftDrawer(),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      floatingActionButton: (_selectedIndex == 0 && request.loggedIn)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsFormPage()),
                );
              },
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              tooltip: 'Add News',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.add, size: 28),
            )
          : null, // Jika tidak memenuhi syarat, tombol hilang (null)

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1F2937),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number),
              label: 'Tickets',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[600],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}