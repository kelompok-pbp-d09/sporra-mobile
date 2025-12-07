import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/event/models/event_entry.dart';
import 'package:sporra_mobile/event/widgets/event_card.dart';
import 'package:sporra_mobile/event/screens/event_form.dart';
import 'package:sporra_mobile/event/screens/event_detail.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';

class EventHomePage extends StatefulWidget {
  const EventHomePage({super.key});

  @override
  State<EventHomePage> createState() => _EventHomePageState();
}

class _EventHomePageState extends State<EventHomePage> {
  String currentCategory = '';
  int currentPage = 1;
  bool isLoading = false;
  bool showPastEvents = false;

  List<Event> upcomingEvents = [];
  List<Event> pastEvents = [];
  List<Event> allUpcomingEvents = [];
  List<Event> allPastEvents = [];
  int? currentUserId;

  final int eventsPerPage = 6;

  final List<Map<String, String>> categories = [
    {'value': 'basket', 'display': 'Basket'},
    {'value': 'tennis', 'display': 'Tennis'},
    {'value': 'bulu tangkis', 'display': 'Bulu Tangkis'},
    {'value': 'volley', 'display': 'Volley'},
    {'value': 'futsal', 'display': 'Futsal'},
    {'value': 'sepak bola', 'display': 'Sepak Bola'},
    {'value': 'renang', 'display': 'Renang'},
    {'value': 'lainnya', 'display': 'Lainnya'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadEvents());
  }

  Future<void> loadEvents() async {
    setState(() => isLoading = true);

    final request = context.read<CookieRequest>();

    try {
      String url = 'http://127.0.0.1:8000/event/json/';

      final response = await request.get(url);

      if (mounted) {
        allUpcomingEvents = (response['upcoming_events'] as List)
            .map((item) => Event.fromJson(item))
            .toList();

        allPastEvents = (response['past_events'] as List)
            .map((item) => Event.fromJson(item))
            .toList();

        if (response['current_user_id'] != null) {
          currentUserId = response['current_user_id'];
        } else {
          currentUserId = null;
        }

        applyFilter();

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void applyFilter() {
    setState(() {
      if (currentCategory.isEmpty) {
        upcomingEvents = List.from(allUpcomingEvents);
        pastEvents = List.from(allPastEvents);
      } else {
        print('Filtering by category: $currentCategory');

        upcomingEvents = allUpcomingEvents.where((event) {
          print('Event: ${event.judul}, Kategori: ${event.kategori}');
          return event.kategori.toLowerCase() == currentCategory.toLowerCase();
        }).toList();

        pastEvents = allPastEvents.where((event) {
          return event.kategori.toLowerCase() == currentCategory.toLowerCase();
        }).toList();

        print(
          'Filtered upcoming: ${upcomingEvents.length}, past: ${pastEvents.length}',
        );
      }
    });
  }

  void changeCategory(String category) {
    currentCategory = category;
    currentPage = 1;
    applyFilter();
  }

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
        );
      });
    }
  }

  void toggleEventView() {
    setState(() {
      showPastEvents = !showPastEvents;
      currentPage = 1;
    });
  }

  Future<void> deleteEvent(String eventId) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/event/event/$eventId/delete/',
        {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showDeleteDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Hapus Event?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            children: [
              const TextSpan(text: 'Event "'),
              TextSpan(
                text: event.judul,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text:
                    '" akan dihapus secara permanen dan tidak dapat dikembalikan.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteEvent(event.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text('Hapus Event'),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: currentCategory.isEmpty,
              onSelected: (_) => changeCategory(''),
              backgroundColor: Colors.grey[700],
              selectedColor: Colors.blue[600],
              labelStyle: TextStyle(
                color: currentCategory.isEmpty
                    ? Colors.white
                    : Colors.grey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat['display']!),
                selected: currentCategory == cat['value'],
                onSelected: (_) => changeCategory(cat['value']!),
                backgroundColor: Colors.grey[700],
                selectedColor: Colors.blue[600],
                labelStyle: TextStyle(
                  color: currentCategory == cat['value']
                      ? Colors.white
                      : Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // awal
            if (currentPage > 1) ...[
              IconButton(
                onPressed: () => changePage(currentPage - 1),
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],

            // halaman pertama
            if (currentPage > 2) ...[
              _buildPageButton(1),
              if (currentPage > 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey[400])),
                ),
            ],

            // sebelum current
            if (currentPage > 1) _buildPageButton(currentPage - 1),

            // Current page
            _buildPageButton(currentPage, isActive: true),

            // setelah current
            if (currentPage < totalPages) _buildPageButton(currentPage + 1),

            // terakhir
            if (currentPage < totalPages - 1) ...[
              if (currentPage < totalPages - 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey[400])),
                ),
              _buildPageButton(totalPages),
            ],

            // Next
            if (currentPage < totalPages) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => changePage(currentPage + 1),
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton(int page, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: isActive ? null : () => changePage(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[600] : Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: Colors.blue[400]!, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: isActive ? 16 : 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsToDisplay = showPastEvents ? pastEvents : upcomingEvents;
    final startIdx = (currentPage - 1) * eventsPerPage;
    final endIdx = startIdx + eventsPerPage;
    final paginatedEvents = eventsToDisplay.sublist(
      startIdx,
      endIdx > eventsToDisplay.length ? eventsToDisplay.length : endIdx,
    );

    final totalPages = (eventsToDisplay.length / eventsPerPage).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text('Event Home'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat event...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadEvents,
              child: ListView(
                children: [
                  const SizedBox(height: 16),

                  // tambah Event
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventFormPage(),
                          ),
                        );
                        if (mounted) {
                          loadEvents();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Event Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Divider(color: Colors.grey, thickness: 1),

                  const SizedBox(height: 8),

                  // Event Selesai atau Akan Datang
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: showPastEvents ? toggleEventView : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !showPastEvents
                                  ? Colors.blue[600]
                                  : Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Event Akan Datang'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: !showPastEvents ? toggleEventView : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showPastEvents
                                  ? Colors.blue[600]
                                  : Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Event Selesai'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filter ketegori
                  buildCategoryFilters(),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      showPastEvents
                          ? 'Event yang Sudah Selesai'
                          : 'Event yang Akan Datang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: showPastEvents ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),

                  // Daftar Event
                  if (paginatedEvents.isNotEmpty) ...[
                    ...paginatedEvents.map(
                      (event) => EventCard(
                        event: event,
                        isPast: showPastEvents,
                        currentUserId: currentUserId,
                        onTapDetail: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailPage(
                                event: event,
                                hasEnded: showPastEvents,
                                isOwnerOrAdmin:
                                    currentUserId != null &&
                                    event.userId != null &&
                                    currentUserId == event.userId,
                              ),
                            ),
                          );
                          if (mounted) {
                            loadEvents();
                          }
                        },
                        onDelete: () => showDeleteDialog(event),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showPastEvents
                                ? 'Tidak ada event yang sudah selesai.'
                                : 'Tidak ada event yang akan datang.',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  buildPaginationControls(totalPages),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
