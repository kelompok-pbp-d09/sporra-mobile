import 'dart:convert';

class UserStatus {
  final int id;
  final String content;
  final String createdAt;

  UserStatus({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) => UserStatus(
    id: json["id"],
    content: json["content"],
    createdAt: json["created_at"],
  );
}

class UserProfile {
    final String username;
    final String fullName;
    final String bio; 
    final String phone; 
    final String profilePicture; 
    final String role;
    final int eventsCreated;
    final int newsCreated;
    final int totalComments; 
    final int totalNewsRealtime;
    
    final List<UserStatus> statuses;

    UserProfile({
        required this.username,
        required this.fullName,
        required this.bio,
        required this.phone,
        required this.profilePicture,
        required this.role,
        required this.eventsCreated,
        required this.newsCreated,
        required this.totalComments,
        required this.totalNewsRealtime,
        required this.statuses, // required
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json["username"] ?? "Unknown",
        fullName: json["full_name"] ?? "No Name",
        bio: json["bio"] ?? "-",
        phone: json["phone"] ?? "-",
        profilePicture: json["profile_picture"] ?? "",
        role: json["role"] ?? "user",
        eventsCreated: json["events_created"] ?? 0,
        newsCreated: json["news_created"] ?? 0,
        totalComments: json["total_comments"] ?? 0, 
        totalNewsRealtime: json["total_news_realtime"] ?? 0,
        
        statuses: json["statuses"] != null 
            ? List<UserStatus>.from(json["statuses"].map((x) => UserStatus.fromJson(x))) 
            : [],
    );
    
    bool get isAdmin => role == 'admin';
}