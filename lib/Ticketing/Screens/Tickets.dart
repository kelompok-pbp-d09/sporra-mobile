import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';
import 'package:sporra_mobile/Ticketing/Screens/MyBookings.dart';
import 'package:sporra_mobile/authentication/login.dart';

// Imports Model & widgets
import '../Models/TicketModel.dart'; 
import '../other/EventOption.dart';
import '../widgets/TicketCard.dart';
import '../widgets/TicketFormDialog.dart';
import '../widgets/BookingDialog.dart';

class AllTicketsPage extends StatefulWidget {
  final bool isEmbedded;

  const AllTicketsPage({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  State<AllTicketsPage> createState() => AllTicketsPageState();
}

class AllTicketsPageState extends State<AllTicketsPage> {
  final String baseUrl = "https://afero-aqil-sporra.pbp.cs.ui.ac.id";

  List<Ticket> _allTickets = [];
  List<Ticket> _filteredTickets = [];
  List<EventOption> _userEvents = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchAllData());
    _searchController.addListener(_filterTickets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //  DATA FETCHING 
  // Fungsi ini otomatis membuat layar jadi LOADING (Full Reload)
  Future<void> fetchAllData() async {
    setState(() => _isLoading = true); // <--- INI KUNCINYA (Layar jadi blank loading)
    await Future.wait([fetchTickets(), fetchUserEvents()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> fetchTickets() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/ticketing/tickets/data/');
      final ticketEntry = TicketEntry.fromJson(response);
      if (mounted) {
        setState(() {
          _allTickets = ticketEntry.tickets;
          _filteredTickets = ticketEntry.tickets;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Tickets: $e");
    }
  }

  Future<void> fetchUserEvents() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/ticketing/get-user-events/');
      List<EventOption> list = [];
      if (response['events'] != null) {
        for (var d in response['events']) {
          list.add(EventOption.fromJson(d));
        }
      }
      if (mounted) setState(() => _userEvents = list);
    } catch (e) {
      debugPrint("Error Fetch Events: $e");
    }
  }

  //  HELPERS & ACTIONS 
  void _filterTickets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTickets = _allTickets.where((ticket) {
        return ticket.eventTitle.toLowerCase().contains(query) ||
            ticket.ticketType.toLowerCase().contains(query);
      }).toList();
    });
  }

  bool requireLogin() {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan login terlebih dahulu untuk melanjutkan."),
          backgroundColor: Colors.red,
        ),
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginPage()));
      });
      return false;
    }
    return true;
  }

  Future<void> deleteTicket(int ticketId) async {
    final request = context.read<CookieRequest>();
    final url = '$baseUrl/ticketing/delete_ticket_ajax/$ticketId/';
    try {
      final response = await request.post(url, {});
      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text("Tiket berhasil dihapus!")),
        );
        fetchAllData();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menghapus tiket.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void showDeleteConfirmation(int ticketId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text("Hapus Tiket", style: TextStyle(color: Colors.white)),
          content: const Text("Yakin ingin menghapus tiket ini?",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: () {
                Navigator.pop(context);
                deleteTicket(ticketId);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

void showTicketFormDialog({Ticket? ticket}) {
    if (ticket == null && _userEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange, 
          content: Text("Buat Event dulu!")
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => TicketFormDialog(
        ticket: ticket,
        userEvents: _userEvents,
        existingTickets: _allTickets, 
        onSuccess: fetchAllData,
      ),
    );
  }

  void openBookingDialog(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        ticket: ticket,
        onSuccess: fetchAllData,
      ),
    );
  }

  //  UI BUILDER 
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Struktur Body (Disesuaikan agar mirip MyBookings)
    Widget bodyContent = Column(
      children: [
        // Search Bar (Tetap di atas)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari Ticket...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF1F2937),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ),
        
        // Content Area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator()) // INI YANG MUNCUL SAAT REFRESH
              : RefreshIndicator(
                  onRefresh: fetchAllData, // PANGGIL fetchAllData AGAR LOADING MUNCUL
                  color: Colors.white,
                  backgroundColor: Colors.blue[700],
                  child: _filteredTickets.isEmpty
                      ? _buildEmptyState() 
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(), // Wajib ada
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.55,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredTickets.length,
                          itemBuilder: (context, index) {
                            final ticket = _filteredTickets[index];
                            return _StaggeredItem(
                              index: index,
                              child: TicketCard(
                                ticket: ticket,
                                request: request,
                                onBook: () => openBookingDialog(ticket),
                                onEdit: () => showTicketFormDialog(ticket: ticket),
                                onDelete: () => showDeleteConfirmation(ticket.id),
                                requireLogin: requireLogin,
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xFF111827), 
        body: bodyContent
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text("Tickets"),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchAllData),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: "My Bookings",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsPage())),
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          if (!requireLogin()) return;
          showTicketFormDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: bodyContent,
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Tidak ada tiket tersedia 😔", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//  WIDGET ANIMASI 
class _StaggeredItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredItem({required this.index, required this.child});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), 
      end: Offset.zero,
    ).animate(_animation);

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}