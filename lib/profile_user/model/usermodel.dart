import 'dart:convert';

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
    });

    // Factory method untuk membuat instance dari JSON
    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json["username"] ?? "Unknown",
        fullName: json["full_name"] ?? "No Name",
        bio: json["bio"]?? "belum ada", // Boleh null karena tipe datanya String?
        phone: json["phone"]?? "belum ada", // Boleh null
        profilePicture: json["profile_picture"]?? "", // Boleh null
        
        // Handle null untuk role
        role: json["role"] ?? "user",
        
        // Handle null untuk integer (gunakan 0 sebagai default)
        eventsCreated: json["events_created"] ?? 0,
        newsCreated: json["news_created"] ?? 0,
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