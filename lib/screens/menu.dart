import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna background gelap (gray-900 versi Flutter)
      backgroundColor: const Color(0xFF111827), 
      appBar: AppBar(
        title: const Text(
          'SPORRA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F2937), // gray-800
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HERO SECTION ---
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome to SPORRA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your ultimate source for sports news, discussion forums, and event tickets.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // --- MENU GRID ---
              // Grid menu untuk akses cepat ke fitur utama
              GridView.count(
                primary: false,
                padding: const EdgeInsets.all(0),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                crossAxisCount: 2, // 2 Kolom
                shrinkWrap: true,
                children: <Widget>[
                  
                  // 1. CARD NEWS
                  _buildMenuCard(
                    context,
                    title: "Browse News",
                    icon: Icons.newspaper,
                    color: Colors.blue[700]!, // Blue-700
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewsEntryListPage()),
                      );
                    },
                  ),

                  // 2. CARD TICKETS
                  _buildMenuCard(
                    context,
                    title: "Buy Tickets",
                    icon: Icons.confirmation_number,
                    color: const Color(0xFF374151), // gray-700
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur Tiket segera hadir!")),
                      );
                    },
                  ),

                  // 3. CARD FORUMS
                  _buildMenuCard(
                    context,
                    title: "Forums",
                    icon: Icons.forum,
                    color: const Color(0xFF374151), // gray-700
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur Forum segera hadir!")),
                      );
                    },
                  ),

                  // 4. CARD PROFILE / LOGOUT
                  _buildMenuCard(
                    context,
                    title: "My Profile",
                    icon: Icons.person,
                    color: const Color(0xFF374151), // gray-700
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fitur Profil segera hadir!")),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // --- SECTION: TRENDING PREVIEW ---
              const Text(
                "Trending Right Now 🔥",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              
              // Kartu Promo Statis (Hanya hiasan agar tidak sepi)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937), // gray-800
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text(
                      "Don't miss the latest match updates!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Check out the news section to see what's happening in the world of sports today.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewsEntryListPage()),
                        );
                      },
                      child: const Text("Read News"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Card Menu agar kodenya rapi
  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}