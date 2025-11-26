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
  
  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    final response = await request.get('https://afero-aqil-sporra.pbp.cs.ui.ac.id/news/json/');
    
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

    // 1. Definisikan bodyContent (Isi Halaman) dalam variabel
    Widget bodyContent = FutureBuilder(
      future: fetchNews(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Belum ada data berita.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => NewsEntryCard(
                news: snapshot.data![index],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Kamu memilih: ${snapshot.data![index].fields.title}"),
                    ),
                  );
                },
              ),
            );
          }
        }
      },
    );

    // 2. Logika Pengembalian (Return) berdasarkan isEmbedded
    if (widget.isEmbedded) {
      return Container(
        color: const Color(0xFF111827),
        child: bodyContent,
      );
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFF111827),
        appBar: AppBar(
          title: const Text('News List'),
          backgroundColor: const Color(0xFF1F2937),
          foregroundColor: Colors.white,
        ),
        drawer: const LeftDrawer(),
        body: bodyContent,
      );
    }
  }
}