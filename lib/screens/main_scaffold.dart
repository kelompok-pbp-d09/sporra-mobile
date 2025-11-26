import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';
import 'package:sporra_mobile/widgets/profile_avatar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Daftar Halaman yang akan ditampilkan di Body
  final List<Widget> _pages = [
    const NewsEntryListPage(isEmbedded: true), // Halaman 0: News (Feed)
    const Center(child: Text("Event Page (Coming Soon)", style: TextStyle(color: Colors.white))), //TODO: Halaman 1
    const Center(child: Text("Tickets Page (Coming Soon)", style: TextStyle(color: Colors.white))), //TODO: Halaman 2
  ];

  // Judul AppBar berubah sesuai halaman
  final List<String> _titles = [
    "News Feed",
    "Events",
    "Tickets",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Background Gelap (Dark Mode)
      
      // --- APP BAR (REDDIT STYLE) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937), // Dark Gray
        foregroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Tombol Profile di Kanan Atas
        actions: const [
          ProfileAvatarButton(),
        ],
      ),

      // --- DRAWER (KIRI) ---
      drawer: const LeftDrawer(),

      // --- BODY (KONTEN TENGAH) ---
      // IndexedStack menjaga state halaman agar tidak reload saat ganti tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // --- BOTTOM NAVIGATION BAR (BAWAH) ---
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1F2937), // Dark Gray
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'News',
            ),
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
          selectedItemColor: Colors.blue[600], // Warna Biru saat aktif
          unselectedItemColor: Colors.grey, // Warna Abu saat tidak aktif
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Agar icon tidak goyang
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}