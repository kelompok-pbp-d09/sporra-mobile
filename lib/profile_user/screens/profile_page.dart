import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/profile_user/model/usermodel.dart';

// Model sederhana untuk Status (karena tidak ada di file usermodel.dart yang kamu upload)
class UserStatus {
  final int id;
  String content;
  final String createdAt;
  UserStatus({
    required this.id,
    required this.content,
    required this.createdAt,
  });
}

class ProfilePage extends StatefulWidget {
  final bool isOwnProfile;

  const ProfilePage({Key? key, this.isOwnProfile = true}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Warna custom
  final Color _bgGray900 = const Color(0xFF111827);
  final Color _bgGray800 = const Color(0xFF1F2937);
  final Color _bgGray700 = const Color(0xFF374151);
  final Color _textGray400 = const Color(0xFF9CA3AF);

  List<UserStatus> statuses = [];

  // --- FUNGSI FETCH DATA (Mirip punya temanmu) ---
  Future<UserProfile> fetchUserProfile(CookieRequest request) async {
    // Ganti URL sesuai environment (10.0.2.2 untuk Emulator Android)
    final response = await request.get(
      'http://localhost:8000/profile_user/json/',
    );

    // Cek apakah response valid dan status True
    if (response['status'] == true) {
      return UserProfile.fromJson(response);
    } else {
      throw Exception('Gagal memuat profil: ${response['message']}');
    }
  }

  // --- LOGIC SECTION (ADD, EDIT, DELETE) ---

  void _showStatusDialog({UserStatus? existingStatus}) {
    final TextEditingController _controller = TextEditingController(
      text: existingStatus != null ? existingStatus.content : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bgGray800,
          title: Text(
            existingStatus != null ? 'Edit Status' : 'Tambah Status',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Apa yang kamu pikirkan?",
              hintStyle: TextStyle(color: _textGray400),
              filled: true,
              fillColor: _bgGray700,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
              ),
              onPressed: () {
                if (_controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Status tidak boleh kosong"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  if (existingStatus != null) {
                    // Edit Logic
                    existingStatus.content = _controller.text;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Status berhasil diperbarui!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Add Logic
                    statuses.insert(
                      0,
                      UserStatus(
                        id: DateTime.now().millisecondsSinceEpoch,
                        content: _controller.text,
                        createdAt:
                            "Just Now", // Di real app, gunakan DateFormat
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Status berhasil ditambahkan!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bgGray800,
          title: const Center(
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus status ini? Tindakan ini tidak dapat dibatalkan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              onPressed: () {
                setState(() {
                  statuses.removeWhere((element) => element.id == id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Status berhasil dihapus!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET BUILDER ---

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: _bgGray900,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: _bgGray800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // MENGGUNAKAN FUTURE BUILDER (Seperti teman Anda)
      body: FutureBuilder<UserProfile>(
        future: fetchUserProfile(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: _textGray400),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Tidak ada data profil",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Data berhasil diambil
          final userProfile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(userProfile),
                const SizedBox(height: 24),
                if (userProfile.isAdmin) _buildAdminSection(),
                if (userProfile.isAdmin) const SizedBox(height: 24),
                _buildStatistics(userProfile),
                const SizedBox(height: 24),
                _buildStatusSection(),
                const SizedBox(height: 24),
                _buildEventSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER (Disesuaikan menerima parameter userProfile) ---

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgGray800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  (profile.profilePicture != null &&
                          profile.profilePicture!.isNotEmpty)
                      ? profile.profilePicture!
                      : 'https://cdn-icons-png.flaticon.com/128/1077/1077063.png',
                ),
                backgroundColor: _bgGray700,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "@${profile.username}",
                      style: TextStyle(color: _textGray400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio,
                      style: TextStyle(color: Colors.grey[300]),
                    ), // bio sudah non-nullable di model baru
                    const SizedBox(height: 4),
                    Text(
                      "📱 ${profile.phone}",
                      style: TextStyle(color: _textGray400, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isOwnProfile) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Navigasi ke Edit Profile")),
                  );
                },
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatistics(UserProfile profile) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgGray800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "${profile.totalComments}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Komentar",
                  style: TextStyle(color: _textGray400, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgGray800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "${profile.newsCreated}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "News",
                  style: TextStyle(color: _textGray400, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgGray800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.red[500], size: 20),
              const SizedBox(width: 8),
              const Text(
                "Privilege Admin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Sebagai Admin, pengguna ini memiliki hak istimewa:",
            style: TextStyle(color: Colors.grey[300]),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint("Membuat, mengedit, dan menghapus News."),
          _buildBulletPoint("Membuat, mengedit, dan menghapus Event."),
          _buildBulletPoint("Membuat, mengedit, dan menghapus Ticket."),
          _buildBulletPoint("Menghapus Komentar milik pengguna lain."),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: _textGray400, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgGray800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isOwnProfile ? "Status Saya" : "Status Pengguna Ini",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.isOwnProfile)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _showStatusDialog(),
                  child: const Text(
                    "+ Tambah",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // List Status
          if (statuses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                widget.isOwnProfile
                    ? "Kamu belum membuat status apapun."
                    : "Pengguna ini belum membuat status.",
                style: TextStyle(
                  color: _textGray400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true, // Penting agar tidak scroll conflict
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgGray700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.content,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            status.createdAt,
                            style: TextStyle(color: _textGray400, fontSize: 12),
                          ),
                          if (widget.isOwnProfile)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _showStatusDialog(existingStatus: status),
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () =>
                                      _showDeleteConfirmDialog(status.id),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgGray800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: widget.isOwnProfile
          ? Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Event yang Saya Booking",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                    ),
                    onPressed: () {
                      // Navigate to My Booking
                    },
                    child: const Text(
                      "Lihat Tiketku",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Event yang Dibooking",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Informasi event yang dibooking bersifat pribadi.",
                  style: TextStyle(
                    color: _textGray400,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
    );
  }
}
