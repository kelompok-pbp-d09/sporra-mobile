import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/news/widgets/news_entry_card.dart';
import 'package:sporra_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class NewsEntryListPage extends StatefulWidget {
  final bool isEmbedded;

  const NewsEntryListPage({super.key, this.isEmbedded = false});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  // 1. State untuk menyimpan kategori yang sedang dipilih
  String _selectedCategory = 'All';

  // 2. Daftar Kategori sesuai model Django
  // 'label': Teks yang muncul di UI, 'value': Nilai yang dicocokkan dengan data API
  final List<Map<String, String>> _categories = [
    {'label': 'All', 'value': 'All'},
    {'label': 'Football', 'value': 'sepakbola'},
    {'label': 'F1', 'value': 'f1'},
    {'label': 'Moto GP', 'value': 'moto gp'},
    {'label': 'Racket', 'value': 'raket'},
    {'label': 'Others', 'value': 'olahraga lain'},
  ];

  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    final response = await request.get(
      'https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/json/',
    );

    var data = response;

    List<NewsEntry> listNews = [];
    for (var d in data) {
      if (d != null) {
        listNews.add(NewsEntry.fromJson(d));
      }
    }
    return listNews;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Warna Tema
    final Color accentBlue = const Color(0xFF2563EB);
    final Color bgDark = const Color(0xFF111827);
    final Color cardDark = const Color(0xFF1F2937);

    Widget bodyContent = Column(
      children: [
        // --- BAGIAN FILTER KATEGORI (DI ATAS) ---
        Container(
          color: bgDark,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category['label']!),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category['value']!;
                        });
                      }
                    },
                    // Styling Chip agar sesuai tema Dark
                    backgroundColor: cardDark,
                    selectedColor: accentBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? accentBlue : Colors.grey[800]!,
                      ),
                    ),
                    showCheckmark:
                        false, // Hilangkan centang default biar lebih bersih
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // --- BAGIAN LIST BERITA ---
        Expanded(
          child: FutureBuilder(
            future: fetchNews(request),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'No news yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                } else {
                  // --- LOGIKA FILTERING ---
                  List<NewsEntry> allNews = snapshot.data!;
                  List<NewsEntry> filteredNews;

                  if (_selectedCategory == 'All') {
                    filteredNews = allNews;
                  } else {
                    // Filter berdasarkan field category dari Django
                    filteredNews = allNews
                        .where(
                          (news) => news.fields.category == _selectedCategory,
                        )
                        .toList();
                  }

                  if (filteredNews.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(
                          () {},
                        ); // Memicu rebuild -> fetchNews dipanggil ulang
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        // Gunakan ListView agar bisa di-scroll/pull
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 60,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No news in this category.',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                      itemCount: filteredNews.length,
                      itemBuilder: (_, index) => NewsEntryCard(
                        news: filteredNews[index],
                        onRefresh: () {
                          setState(() {});
                        },
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Container(color: bgDark, child: bodyContent);
    } else {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          title: const Text('Sporra News'),
          backgroundColor: cardDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: const LeftDrawer(),
        body: bodyContent,
      );
    }
  }
}
