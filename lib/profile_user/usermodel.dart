import 'dart:convert';

class UserProfile {
    final String username;
    final String fullName;
    final String? bio; // Bisa null (blank=True di Django)
    final String? phone; // Bisa null
    final String? profilePicture; // Bisa null
    final String role;
    final int eventsCreated;
    final int newsCreated;
    
    // Field dari @property di Django (hasil hitungan)
    final int totalComments; 
    final int totalNewsRealtime;

    UserProfile({
        required this.username,
        required this.fullName,
        this.bio,
        this.phone,
        this.profilePicture,
        required this.role,
        required this.eventsCreated,
        required this.newsCreated,
        required this.totalComments,
        required this.totalNewsRealtime,
    });

    // Factory method untuk membuat instance dari JSON
    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json["username"],
        fullName: json["full_name"],
        bio: json["bio"],
        phone: json["phone"],
        profilePicture: json["profile_picture"],
        role: json["role"],
        eventsCreated: json["events_created"],
        newsCreated: json["news_created"],
        // Pastikan key JSON ini sesuai dengan yang Anda return di views.py
        totalComments: json["total_comments"] ?? 0, 
        totalNewsRealtime: json["total_news_realtime"] ?? 0,
    );

    // Method untuk mengubah instance kembali ke JSON
    Map<String, dynamic> toJson() => {
        "username": username,
        "full_name": fullName,
        "bio": bio,
        "phone": phone,
        "profile_picture": profilePicture,
        "role": role,
        "events_created": eventsCreated,
        "news_created": newsCreated,
        "total_comments": totalComments,
        "total_news_realtime": totalNewsRealtime,
    };
    
    // Helper untuk mengecek apakah user adalah admin
    bool get isAdmin => role == 'admin';
}