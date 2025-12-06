class UserStatus {
    final int id;
    final String content;
    final String createdAt; // Dikirim sebagai String dari backend
    final String username; // Biasanya kita butuh nama pembuat status

    UserStatus({
        required this.id,
        required this.content,
        required this.createdAt,
        required this.username,
    });

    factory UserStatus.fromJson(Map<String, dynamic> json) => UserStatus(
        id: json["id"],
        content: json["content"],
        createdAt: json["created_at"],
        // Asumsi backend mengirimkan username penulis status
        username: json["username"] ?? "", 
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "content": content,
        "created_at": createdAt,
        "username": username,
    };
}