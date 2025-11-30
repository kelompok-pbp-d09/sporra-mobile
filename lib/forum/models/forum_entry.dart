// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

import '../../news/models/news_entry.dart';

ForumEntry forumEntryFromJson(String str) => ForumEntry.fromJson(json.decode(str));

String forumEntryToJson(ForumEntry data) => json.encode(data.toJson());

class ForumEntry {
  String forumId;
  NewsEntry article;
  List<Comment> comments;
  List<TopForum> topForums;
  List<NewsEntry> hottestArticles;

  ForumEntry({
    required this.forumId,
    required this.article,
    required this.comments,
    required this.topForums,
    required this.hottestArticles,
  });

  factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
    forumId: json["forum_id"],
    article: NewsEntry.fromJson(json["article"]),
    comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
    topForums: List<TopForum>.from(json["top_forums"].map((x) => TopForum.fromJson(x))),
    hottestArticles: List<NewsEntry>.from(json["hottest_articles"].map((x) => NewsEntry.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "forum_id": forumId,
    "article": article.toJson(),
    "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
    "top_forums": List<dynamic>.from(topForums.map((x) => x.toJson())),
    "hottest_articles": List<dynamic>.from(hottestArticles.map((x) => x.toJson())),
  };
}

class Comment {
  int id;
  String author;
  String content;
  int score;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.score,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json["id"],
    author: json["author"],
    content: json["content"],
    score: json["score"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "author": author,
    "content": content,
    "score": score,
    "created_at": createdAt.toIso8601String(),
  };
}

class TopForum {
  String articleId;
  String title;
  int postCount;

  TopForum({
    required this.articleId,
    required this.title,
    required this.postCount,
  });

  factory TopForum.fromJson(Map<String, dynamic> json) => TopForum(
    articleId: json["article_id"],
    title: json["title"],
    postCount: json["post_count"],
  );

  Map<String, dynamic> toJson() => {
    "article_id": articleId,
    "title": title,
    "post_count": postCount,
  };
}
