import 'package:flutter/material.dart';
import 'package:sporra_mobile/Ticketing/Screens/Tickets.dart';
import 'package:sporra_mobile/news/screens/news_entry_list.dart';
import 'package:sporra_mobile/news/screens/news_form.dart';
import 'package:sporra_mobile/event/screens/event_home.dart';
import 'package:sporra_mobile/event/screens/event_form.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';
import 'package:sporra_mobile/widgets/profile_avatar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/Ticketing/Screens/MyBookings.dart';

class MainMenu extends StatefulWidget {
  final int initialIndex;

  const MainMenu({super.key, this.initialIndex = 0});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;

  final GlobalKey<EventHomePageState> _eventHomeKey =
      GlobalKey<EventHomePageState>();

  final GlobalKey<AllTicketsPageState> _ticketKey =
      GlobalKey<AllTicketsPageState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      const NewsEntryListPage(isEmbedded: true),
      EventHomePage(key: _eventHomeKey, isEmbedded: true),
      AllTicketsPage(key: _ticketKey, isEmbedded: true),
    ];
  }

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
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: "My Bookings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBookingsPage()),
              );
            },
          ),

          const ProfileAvatarButton(),
        ],
      ),

      drawer: const LeftDrawer(),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      floatingActionButton:
          (request.loggedIn &&
              (_selectedIndex == 0 ||
                  _selectedIndex == 1 ||
                  _selectedIndex == 2))
          ? FloatingActionButton(
              onPressed: () async {
                if (_selectedIndex == 0) {
                  // === Logic News ===
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsFormPage(),
                    ),
                  );
                } else if (_selectedIndex == 1) {
                  // === Logic Event ===
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventFormPage(),
                    ),
                  );
                  if (result == true) {
                    _eventHomeKey.currentState?.loadEvents();
                  }
                } else if (_selectedIndex == 2) {
                  _ticketKey.currentState?.showTicketFormDialog();
                }
              },
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              tooltip: _selectedIndex == 2
                  ? 'Add Ticket'
                  : (_selectedIndex == 0 ? 'Add News' : 'Add Event'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.add, size: 28),
            )
          : null, // Jika tidak login, tombol hilang

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
