import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/event/models/event_entry.dart';
import 'package:sporra_mobile/event/widgets/event_card.dart';
import 'package:sporra_mobile/event/screens/event_form.dart';
import 'package:sporra_mobile/event/screens/event_detail.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';

class FadeInStaggered extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeInStaggered({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

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
    {'label': 'Basket', 'value': 'basket'},
    {'label': 'Tennis', 'value': 'tennis'},
    {'label': 'Bulu Tangkis', 'value': 'bulu tangkis'},
    {'label': 'Volley', 'value': 'volley'},
    {'label': 'Futsal', 'value': 'futsal'},
    {'label': 'Sepak Bola', 'value': 'sepak bola'},
    {'label': 'Renang', 'value': 'renang'},
    {'label': 'Lainnya', 'value': 'lainnya'},
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
        currentUserId = response['current_user_id'];
        applyFilter();
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    setState(() {
      if (currentCategory.isEmpty) {
        upcomingEvents = List.from(allUpcomingEvents);
        pastEvents = List.from(allPastEvents);
      } else {
        upcomingEvents = allUpcomingEvents
            .where(
              (e) => e.kategori.toLowerCase() == currentCategory.toLowerCase(),
            )
            .toList();
        pastEvents = allPastEvents
            .where(
              (e) => e.kategori.toLowerCase() == currentCategory.toLowerCase(),
            )
            .toList();
      }
    });
  }

  void changeCategory(String category) {
    currentCategory = category;
    currentPage = 1;
    applyFilter();
  }

  void changePage(int page) {
    setState(() => currentPage = page);
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
      final response = await request.post(
        'https://afero-aqil-sporra.pbp.cs.ui.ac.id/event/event/$eventId/delete/',
        {},
      );
      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          loadEvents();
        }
      }
    } catch (e) {}
  }

  Widget buildEventToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: showPastEvents
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildToggleButtonChild(
                'Upcoming',
                !showPastEvents,
                () => toggleEventView(false),
              ),
              _buildToggleButtonChild(
                'Past Events',
                showPastEvents,
                () => toggleEventView(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtonChild(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryFilters() {
    return Container(
      color: bgDark,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChip(
                'All',
                currentCategory.isEmpty,
                () => changeCategory(''),
              ),
            ),
            ...categories.map((category) {
              final isSelected = currentCategory == category['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildChip(
                  category['label']!,
                  isSelected,
                  () => changeCategory(category['value']!),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: cardDark,
      selectedColor: accentBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? accentBlue : Colors.grey[800]!),
      ),
      showCheckmark: false,
    );
  }

  Widget buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                icon: Icons.first_page,
                onPressed: currentPage > 1 ? () => changePage(1) : null,
              ),
              const SizedBox(width: 8),
              ...List.generate(totalPages, (index) {
                int page = index + 1;
                if (page == 1 ||
                    page == totalPages ||
                    (page >= currentPage - 1 && page <= currentPage + 1)) {
                  return _buildPageButton(page, isActive: currentPage == page);
                }
                if (page == currentPage - 2 || page == currentPage + 2) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text("...", style: TextStyle(color: Colors.white)),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.last_page,
                onPressed: currentPage < totalPages
                    ? () => changePage(totalPages)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: cardDark,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPageButton(int page, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => changePage(page),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? accentBlue : cardDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? accentBlue : Colors.grey[800]!,
            ),
          ),
          child: Text("$page", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void showDeleteDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete Event?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Event will be permanently deleted.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteEvent(event.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsToDisplay = showPastEvents ? pastEvents : upcomingEvents;
    final startIdx = (currentPage - 1) * eventsPerPage;
    final endIdx = startIdx + eventsPerPage;
    final int safeStart = startIdx >= eventsToDisplay.length ? 0 : startIdx;
    final int safeEnd = endIdx > eventsToDisplay.length
        ? eventsToDisplay.length
        : endIdx;

    final paginatedEvents = eventsToDisplay.isEmpty
        ? <Event>[]
        : eventsToDisplay.sublist(safeStart, safeEnd);
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey('${showPastEvents}_$currentCategory'),
                    children: [
                      if (paginatedEvents.isNotEmpty)
                        ...paginatedEvents.asMap().entries.map(
                          (entry) => FadeInStaggered(
                            index: entry.key,
                            key: ValueKey(entry.value.id),
                            child: EventCard(
                              event: entry.value,
                              isPast: showPastEvents,
                              currentUserId: currentUserId,
                              onTapDetail: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventDetailPage(
                                      event: entry.value,
                                      hasEnded: showPastEvents,
                                      isOwnerOrAdmin:
                                          currentUserId == entry.value.userId,
                                    ),
                                  ),
                                );
                                if (mounted) loadEvents();
                              },
                              onDelete: () => showDeleteDialog(entry.value),
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            "No Event",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                buildPaginationControls(totalPages),
              ],
            ),
          );

    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bgDark,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text('Event Home'),
              backgroundColor: cardDark,
              foregroundColor: Colors.white,
            ),
      drawer: widget.isEmbedded ? null : const LeftDrawer(),
      body: bodyContent,
    );
  }
}
