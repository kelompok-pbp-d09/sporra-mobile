import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sporra_mobile/news/models/news_entry.dart'; 

void main() {
  group('NewsEntry Model Tests', () {
    // 1. Define sample JSON data that matches your backend response
    // We use a raw string to simulate the API response
    const String sampleJsonString = '''
    [
      {
        "model": "news.newsentry",
        "pk": "b3e09842-8888-4444-9999-1234567890ab",
        "fields": {
          "title": "Flutter is Great",
          "content": "Full article content here.",
          "category": "Tech",
          "thumbnail": "https://example.com/image.png",
          "news_views": 150,
          "created_at": "2023-10-27T10:00:00Z",
          "is_featured": true,
          "author": "Jane Doe",
          "author_pfp": "https://example.com/jane.png"
        }
      }
    ]
    ''';

    test('newsEntryFromJson parses a valid list of JSON objects', () {
      // Act
      final List<NewsEntry> result = newsEntryFromJson(sampleJsonString);

      // Assert
      expect(result.length, 1);
      expect(result.first.model, "news.newsentry");
      expect(result.first.fields.title, "Flutter is Great");
      expect(result.first.fields.newsViews, 150);
      expect(result.first.fields.isFeatured, true);
      
      // Verify Date Parsing
      expect(result.first.fields.createdAt.year, 2023);
      expect(result.first.fields.createdAt.month, 10);
    });

    test('fromJson handles missing optional fields (Null Safety checks)', () {
      // Create a JSON map that is MISSING 'thumbnail', 'is_featured', and 'author_pfp'
      final Map<String, dynamic> partialJson = {
        "model": "news.newsentry",
        "pk": "123",
        "fields": {
          "title": "Incomplete News",
          "content": "Content",
          "category": "General",
          // "thumbnail" is missing
          "news_views": 0,
          "created_at": "2023-01-01T00:00:00Z",
          // "is_featured" is missing
          "author": "Admin",
          // "author_pfp" is missing
        }
      };

      // Act
      final entry = NewsEntry.fromJson(partialJson);

      // Assert: Check if the '??' operators in your code worked
      expect(entry.fields.thumbnail, ""); // Should default to empty string
      expect(entry.fields.isFeatured, false); // Should default to false
      expect(entry.fields.authorPfp, ""); // Should default to empty string
    });

    test('toJson converts object back to Map correctly', () {
      // Arrange
      final entry = NewsEntry(
        model: "test.model",
        pk: "123",
        fields: Fields(
          title: "Test Title",
          content: "Test Content",
          category: "Test Cat",
          thumbnail: "img.png",
          newsViews: 10,
          createdAt: DateTime(2023, 1, 1),
          isFeatured: true,
          author: "Tester",
          authorPfp: "pfp.png",
        ),
      );

      // Act
      final jsonMap = entry.toJson();
      final fieldsMap = jsonMap['fields'];

      // Assert
      expect(jsonMap['model'], "test.model");
      expect(fieldsMap['title'], "Test Title");
      
      // Note: Your code serializes date to Iso8601 string
      expect(fieldsMap['created_at'], contains("2023-01-01"));
      
      // Note: Check the key names match exactly what your toJson defines
      expect(fieldsMap['author_pfp_url'], "pfp.png"); // Your toJson uses 'author_pfp_url'
    });
  });
}