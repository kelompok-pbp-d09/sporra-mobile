import 'package:flutter/material.dart';
import 'package:sporra_mobile/news/models/news_entry.dart';
import 'package:sporra_mobile/news/widgets/news_entry_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class NewsEntryListPage extends StatefulWidget {
  const NewsEntryListPage({super.key});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  // Fungsi Fetch Data
  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    // Ganti URL dengan endpoint JSON kamu
    // Gunakan 10.0.2.2 untuk emulator Android, localhost untuk Web
    final response = await request.get('http://10.0.2.2:8000/json/');
    
    // Decode response menjadi list NewsEntry
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
    return Scaffold(
      appBar: AppBar(title: const Text('News Entry List')),
      // Drawer bisa ditambahkan di sini
      body: FutureBuilder(
        future: fetchNews(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Center(child: Text('Belum ada data berita.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => NewsEntryCard(
                  news: snapshot.data![index],
                  onTap: () {
                    // Navigasi ke detail bisa ditambahkan di sini nanti
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kamu memilih: ${snapshot.data![index].fields.title}"))
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}