import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/event/models/event_entry.dart';
import 'package:sporra_mobile/event/widgets/event_card.dart';
import 'package:sporra_mobile/event/screens/event_form.dart';
import 'package:sporra_mobile/event/screens/event_detail.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';

class EventHomePage extends StatefulWidget {
  final bool isEmbedded;
  const EventHomePage({super.key, this.isEmbedded = false});

  @override
  State<EventHomePage> createState() => EventHomePageState();
}

class EventHomePageState extends State<EventHomePage> {
  final Color accentBlue = const Color(0xFF2563EB);
  final Color bgDark = const Color(0xFF111827);
  final Color cardDark = const Color(0xFF1F2937);

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
      String url = 'https://afero-aqil-sporra.pbp.cs.ui.ac.id/event/json/';
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
      }
    }
  }

  void applyFilter() {
    setState(() {
      if (currentCategory.isEmpty) {
        upcomingEvents = List.from(allUpcomingEvents);
        pastEvents = List.from(allPastEvents);
      } else {
        upcomingEvents = allUpcomingEvents.where((event) {
          return event.kategori.toLowerCase() == currentCategory.toLowerCase();
        }).toList();

        pastEvents = allPastEvents.where((event) {
          return event.kategori.toLowerCase() == currentCategory.toLowerCase();
        }).toList();
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

  void toggleEventView(bool isPast) {
    if (showPastEvents != isPast) {
      setState(() {
        showPastEvents = isPast;
        currentPage = 1;
      });
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final request = context.read<CookieRequest>();
    try {
      await request.post(
        'https://afero-aqil-sporra.pbp.cs.ui.ac.id/event/event/$eventId/delete/',
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
    } catch (e) {}
  }

  void showDeleteDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text(
          'Hapus Event?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Hapus "${event.judul}"?',
          style: const TextStyle(color: Colors.grey),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildEventToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => toggleEventView(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !showPastEvents ? accentBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    color: !showPastEvents ? Colors.white : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => toggleEventView(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: showPastEvents ? accentBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Past Events',
                  style: TextStyle(
                    color: showPastEvents ? Colors.white : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
            child: ChoiceChip(
              label: const Text('All'),
              selected: currentCategory.isEmpty,
              onSelected: (_) => changeCategory(''),
              backgroundColor: cardDark,
              selectedColor: accentBlue,
              labelStyle: TextStyle(
                color: currentCategory.isEmpty
                    ? Colors.white
                    : Colors.grey[400],
                fontWeight: currentCategory.isEmpty
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: currentCategory.isEmpty
                      ? accentBlue
                      : Colors.grey[800]!,
                ),
              ),
              showCheckmark: false,
            ),
          ),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat['display']!),
                selected: currentCategory == cat['value'],
                onSelected: (_) => changeCategory(cat['value']!),
                backgroundColor: cardDark,
                selectedColor: accentBlue,
                labelStyle: TextStyle(
                  color: currentCategory == cat['value']
                      ? Colors.white
                      : Colors.grey[400],
                  fontWeight: currentCategory == cat['value']
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: currentCategory == cat['value']
                        ? accentBlue
                        : Colors.grey[800]!,
                  ),
                ),
                showCheckmark: false,
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
            if (currentPage > 2) ...[
              _buildPageButton(1),
              if (currentPage > 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey[400])),
                ),
            ],
            if (currentPage > 1) _buildPageButton(currentPage - 1),
            _buildPageButton(currentPage, isActive: true),
            if (currentPage < totalPages) _buildPageButton(currentPage + 1),
            if (currentPage < totalPages - 1) ...[
              if (currentPage < totalPages - 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: Colors.grey[400])),
                ),
              _buildPageButton(totalPages),
            ],
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

    Widget bodyContent = isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: loadEvents,
            child: ListView(
              children: [
                const SizedBox(height: 16),

                buildEventToggle(),

                const SizedBox(height: 16),

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

                if (paginatedEvents.isNotEmpty) ...[
                  ...paginatedEvents.map(
                    (event) => EventCard(
                      event: event,
                      isPast: showPastEvents,
                      currentUserId: currentUserId,
                      onTapDetail: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailPage(
                              event: event,
                              hasEnded: showPastEvents,
                              isOwnerOrAdmin:
                                  currentUserId != null &&
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
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        "Tidak ada event",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],

                buildPaginationControls(totalPages),

                const SizedBox(height: 20),
              ],
            ),
          );

    final request = context.watch<CookieRequest>();

    if (widget.isEmbedded) {
      return Container(color: bgDark, child: bodyContent);
    } else {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          title: const Text('Event Home'),
          backgroundColor: cardDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        drawer: const LeftDrawer(),

        body: bodyContent,
        floatingActionButton: request.loggedIn
            ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventFormPage(),
                    ),
                  );
                  if (mounted) loadEvents();
                },
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.add, size: 28),
              )
            : null,
      );
    }
  }
}
