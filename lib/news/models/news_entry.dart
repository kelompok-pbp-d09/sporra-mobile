// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

List<NewsEntry> newsEntryFromJson(String str) => List<NewsEntry>.from(json.decode(str).map((x) => NewsEntry.fromJson(x)));

String newsEntryToJson(List<NewsEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsEntry {
    String model;
    String pk;
    Fields fields;

    NewsEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String title;
    String content;
    String category;
    String thumbnail;
    int newsViews;
    DateTime createdAt;
    bool isFeatured; // Kita anggap ini is_news_hot nanti
    int? author;     // Ubah jadi nullable (int?) untuk jaga-jaga

    Fields({
        required this.title,
        required this.content,
        required this.category,
        required this.thumbnail,
        required this.newsViews,
        required this.createdAt,
        required this.isFeatured,
        this.author, // Hapus 'required'
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        content: json["content"],
        category: json["category"],
        // Handle jika thumbnail null
        thumbnail: json["thumbnail"] ?? "", 
        newsViews: json["news_views"],
        createdAt: DateTime.parse(json["created_at"]),
        
        // PERBAIKAN UTAMA DI SINI:
        // Gunakan '?? false' agar jika datanya tidak ada di JSON, defaultnya jadi false.
        isFeatured: json["is_featured"] ?? false, 
        
        // PERBAIKAN KEDUA:
        // Author bisa null di Django, jadi kita terima null juga di sini
        author: json["author"], 
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "content": content,
        "category": category,
        "thumbnail": thumbnail,
        "news_views": newsViews,
        "created_at": createdAt.toIso8601String(),
        "is_featured": isFeatured,
        "author": author,
    };
}