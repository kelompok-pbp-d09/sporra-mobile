import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporra_mobile/profile_user/model/usermodel.dart';
import 'package:sporra_mobile/Ticketing/Screens/myBookings.dart';

class ProfilePage extends StatefulWidget {
  final bool isOwnProfile;
  final String? username;

  const ProfilePage({Key? key, this.isOwnProfile = true, this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _bgGray900 = const Color(0xFF111827);
  final Color _bgGray800 = const Color(0xFF1F2937);
  final Color _bgGray700 = const Color(0xFF374151);
  final Color _textGray400 = const Color(0xFF9CA3AF);

  late Future<UserProfile> _profileFuture;
  bool isOwnProfile = false;
  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _profileFuture = fetchUserProfile(request);
  }

  void refreshProfile() {
    final request = context.read<CookieRequest>();
    setState(() {
      _profileFuture = fetchUserProfile(request);
    });
  }

  Future<UserProfile> fetchUserProfile(CookieRequest request) async {
    String url = 'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/json/';
    if (widget.username != null) {
      url = 'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/json/${widget.username}/';
    }

    final response = await request.get(url);

   if (response['status'] == true) {
      // Set status isOwnProfile berdasarkan respons dari Django (jika ditambahkan) 
      // atau logika sederhana: jika widget.username == null, maka profil sendiri.
      // Namun, amannya kita cek username dari response vs logged in user jika ada, 
      // tapi untuk simplifikasi:
      
      setState(() {
         // Jika widget.username kosong, berarti buka profil sendiri via navbar
         // Jika widget.username ada, cek logic lain atau anggap sementara false (viewer mode)
         // (Idealnya backend mengirim flag 'is_own_profile')
         if (widget.username == null) {
            isOwnProfile = true;
         } else {
            // Cek field dari JSON backend jika Anda menambahkannya di langkah 1
            // isOwnProfile = response['is_own_profile'] ?? false;
            
            // Atau default ke false jika melihat profil orang lain
            isOwnProfile = false; 
         }
      });

      return UserProfile.fromJson(response);
    } else {
      throw Exception('Gagal memuat profil: ${response['message']}');
    }
  }

  // --- LOGIC EDIT PROFILE (BARU) ---
  void _showEditProfileDialog(CookieRequest request, UserProfile profile) {
    // Controller diisi dengan data saat ini
    final TextEditingController _nameController = TextEditingController(
      text: profile.fullName,
    );
    final TextEditingController _bioController = TextEditingController(
      text: profile.bio,
    );
    final TextEditingController _phoneController = TextEditingController(
      text: profile.phone,
    );
    final TextEditingController _pfpController = TextEditingController(
      text: profile.profilePicture,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bgGray800,
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField("Full Name", _nameController),
                const SizedBox(height: 12),
                _buildTextField("Bio", _bioController, maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField(
                  "Phone Number",
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField("Profile Picture URL", _pfpController),
              ],
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
              onPressed: () async {
                // Validasi sederhana
                if (_nameController.text.isEmpty) return;

                Navigator.pop(context); // Tutup dialog

                try {
                  // Kirim ke Django (Endpoint BARU yang kita buat di views.py)
                  final response = await request.post(
                    'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/edit-profile-flutter/',
                    {
                      'full_name': _nameController.text,
                      'bio': _bioController.text,
                      'phone': _phoneController.text,
                      'profile_picture': _pfpController.text,
                    },
                  );

                  if (response['status'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile berhasil diperbarui!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    refreshProfile(); // Refresh UI
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal: ${response['message']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print("Error updating profile: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Terjadi kesalahan: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  // Helper untuk membuat TextField input
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _textGray400, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _bgGray700,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // --- LOGIC TAMBAH & EDIT STATUS (UPDATED) ---
  void _showStatusDialog(CookieRequest request, {UserStatus? existingStatus}) {
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
              onPressed: () async {
                if (_controller.text.trim().isEmpty) return;

                Navigator.pop(context); // Tutup dialog

                try {
                  // Cek apakah ini EDIT atau TAMBAH BARU
                  if (existingStatus != null) {
                    // --- LOGIKA EDIT (POST ke endpoint edit_status) ---
                    final response = await request.post(
                      'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/edit_status/${existingStatus.id}/',
                      {'content': _controller.text},
                    );

                    if (response['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Status berhasil diperbarui!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      refreshProfile(); // Refresh UI
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Gagal edit status: ${response['error'] ?? 'Unknown error'}",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    // --- LOGIKA TAMBAH BARU (POST ke endpoint add_status) ---
                    final response = await request.post(
                      'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/add_status/',
                      {'content': _controller.text},
                    );

                    if (response['id'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Status berhasil ditambahkan!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      refreshProfile(); // Refresh UI
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Gagal menambah status"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print("Error status action: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Terjadi kesalahan koneksi"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  // --- LOGIC HAPUS STATUS (LAMA) ---
  void _showDeleteConfirmDialog(CookieRequest request, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _bgGray800,
          title: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 48,
          ),
          content: const Text(
            "Hapus status ini?",
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
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final response = await request.post(
                    'https://afero-aqil-sporra.pbp.cs.ui.ac.id/profile_user/delete_status/$id/',
                    {},
                  );
                  if (response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Status dihapus!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    refreshProfile();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gagal menghapus status."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print("Error deleting: $e");
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

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
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
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
                "Tidak ada data",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final userProfile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(
                  userProfile,
                  request,
                ), // Pass Request disini
                const SizedBox(height: 24),
                if (userProfile.isAdmin) _buildAdminSection(),
                if (userProfile.isAdmin) const SizedBox(height: 24),
                _buildStatistics(userProfile),
                const SizedBox(height: 24),
                _buildStatusSection(userProfile, request),
                const SizedBox(height: 24),
                _buildEventSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UPDATED PROFILE HEADER (Dengan Tombol Edit) ---
  Widget _buildProfileHeader(UserProfile profile, CookieRequest request) {
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
                  (profile.profilePicture != "" &&
                          profile.profilePicture.startsWith("http"))
                      ? profile.profilePicture
                      : 'https://cdn-icons-png.flaticon.com/128/1077/1077063.png',
                ),
                backgroundColor: _bgGray700,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // TOMBOL EDIT (Hanya jika profil milik sendiri)
                        if (isOwnProfile)
                          InkWell(
                            onTap: () =>
                                _showEditProfileDialog(request, profile),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      "@${profile.username}",
                      style: TextStyle(color: _textGray400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio.isNotEmpty ? profile.bio : "-",
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "📱 ${profile.phone.isNotEmpty ? profile.phone : "-"}",
                      style: TextStyle(color: _textGray400, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... (Sisa fungsi _buildStatistics, _buildAdminSection, _buildStatusSection, _buildEventSection tetap sama seperti kode Anda sebelumnya) ...

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgGray800,
        border: Border.all(color: Colors.red[600]!.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text("Admin Privilege Active", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // --- UPDATED STATUS LIST (Dengan Tombol Edit) ---
  Widget _buildStatusSection(UserProfile profile, CookieRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgGray800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOwnProfile ? "Status Saya" : "Status Pengguna Ini",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isOwnProfile)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  // Panggil dialog TANPA parameter existingStatus untuk menambah baru
                  onPressed: () => _showStatusDialog(request),
                  child: const Text(
                    "+ Tambah",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (profile.statuses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Belum ada status.",
                style: TextStyle(
                  color: _textGray400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profile.statuses.length,
              itemBuilder: (context, index) {
                final status = profile.statuses[index];
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

                          // --- TOMBOL AKSI (EDIT & DELETE) ---
                          if (isOwnProfile)
                            Row(
                              children: [
                                // Tombol Edit
                                GestureDetector(
                                  // Panggil dialog DENGAN parameter existingStatus
                                  onTap: () => _showStatusDialog(
                                    request,
                                    existingStatus: status,
                                  ),
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12), // Jarak antar tombol
                                // Tombol Delete
                                GestureDetector(
                                  onTap: () => _showDeleteConfirmDialog(
                                    request,
                                    status.id,
                                  ),
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
      child: isOwnProfile
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsPage(),
                        ),
                      );
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
