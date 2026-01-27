// lib/screens/profile_page.dart

import 'dart:convert';
//import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/user_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

  class _ProfilePageState extends State<ProfilePage> {
    final AuthService _authService = AuthService();
    final UserService _userService = UserService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // --- Theme Colors ---
    final Color _primaryGreen = const Color(0xFF006400);
    final Color _accentGreen = const Color(0xFF32CD32);
    final Color _bgGrey = const Color(0xFFF9FAFB);

    final String malePlaceholder = "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=600";
    bool _isUploading = false;

    // --- Cloudinary Config ---
    Future<void> _pickAndUploadGalleryPhoto() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (image == null) return;

      setState(() => _isUploading = true);

      String cloudName = "dgdl2uy9z"; 
      String uploadPreset = "Kupid_tharit"; // ✅ เช็คชื่อ Preset ให้ตรงกับใน Cloudinary

      try {
        var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
        var request = http.MultipartRequest("POST", uri);
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', image.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var jsonMap = jsonDecode(String.fromCharCodes(responseData));
          String newPhotoUrl = jsonMap['secure_url'];

          await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
            'galleryPhotos': FieldValue.arrayUnion([newPhotoUrl])
          });

          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added photo successfully!")));
        } else {
          var errorData = await response.stream.bytesToString();
          debugPrint("Cloudinary Error: $errorData");
        }
      } catch (e) {
        debugPrint("Error uploading: $e");
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }

    Future<void> _deletePhoto(String photoUrl) async {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Photo"),
          content: const Text("Are you sure you want to remove this photo?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
          ],
        ),
      ) ?? false;

      if (confirm) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
          'galleryPhotos': FieldValue.arrayRemove([photoUrl])
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: _bgGrey,
        appBar: AppBar(
          backgroundColor: _primaryGreen,
          elevation: 0,
          title: const Text("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () { 
                Navigator.pushNamed(context, '/editprofile');
              },
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("User not found"));
            }

            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

            String displayName = userData['name'] ?? "User";
            String displayImage = (userData['photoUrl'] != null && userData['photoUrl'].isNotEmpty)
                ? userData['photoUrl']
                : malePlaceholder;
            String faculty = userData['faculty'] ?? "Faculty";
            String age = userData['age'] != null ? "${userData['age']}" : "";
            String bio = userData['bio'] ?? "No bio yet...";
            String studentId = userData['studentId'] ?? "-";
           // String gender = userData['gender'] ?? "-";
            List<dynamic> galleryPhotos = userData['galleryPhotos'] ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  // -------------------------------------------------------
                  // 1. HEADER CARD (Avatar + Basic Info)
                  // -------------------------------------------------------
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 10, offset: const Offset(0, 5))],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(displayImage, fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 50, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -4, right: -4,
                                  child: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(color: _accentGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            // Name & Stats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("$displayName, $age", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.school, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(faculty, style: TextStyle(color: Colors.grey[600], fontSize: 14), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text("ID: $studentId", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Stats Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildStatItem("0", "Matches"),
                                      _buildStatItem("0", "Likes"),
                                      _buildStatItem("100%", "Profile"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------------------------------------
                  // 2. ABOUT ME (BIO) - ✅ สวยงามขึ้น
                  // -------------------------------------------------------
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.face, color: _primaryGreen),
                            const SizedBox(width: 8),
                            const Text("About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bio,
                          style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // 🏷️ Mockup Interests Tags (สิ่งที่ควรมี)
                        Row(
                          children: [
                            Icon(Icons.local_activity, color: _primaryGreen),
                            const SizedBox(width: 8),
                            const Text("Interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInterestChip("🏸 Badminton"),
                            _buildInterestChip("🥘 Shabu"),
                            _buildInterestChip("☕ Café Hopping"),
                            _buildInterestChip("💻 Coding"),
                            _buildInterestChip("🐈 Cats"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------------------------------------------------------
                  // 3. MY PHOTOS
                  // -------------------------------------------------------
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.photo_library, color: _primaryGreen),
                            const SizedBox(width: 8),
                            const Text("My Photos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                         itemCount: galleryPhotos.length < 6 ? galleryPhotos.length + 1 : galleryPhotos.length,
                          
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            if (index == galleryPhotos.length && galleryPhotos.length < 6) {
                              return GestureDetector(
                                onTap: _isUploading ? null : _pickAndUploadGalleryPhoto,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: _isUploading 
                                    ? const Center(child: CircularProgressIndicator()) 
                                    : Center(child: Icon(Icons.add_a_photo, color: Colors.grey[400], size: 28)),
                                ),
                              );
                            }
                            String imgUrl = galleryPhotos[index];
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(imgUrl, fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4, right: 4,
                                  child: GestureDetector(
                                    onTap: () => _deletePhoto(imgUrl),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: .8), shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // -------------------------------------------------------
                  // 4. SETTINGS
                  // -------------------------------------------------------
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(Icons.person_outline, "Account Settings"),
                        _buildSettingsTile(Icons.lock_outline, "Privacy & Safety"),
                        _buildSettingsTile(Icons.notifications_outlined, "Notifications"),
                        const Divider(),
                        InkWell(
                          onTap: () async {
                            await _authService.signOut();
                            if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 12), Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500))]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -------------------------------------------------------
                  // 🛠️ DEV OPTIONS
                  // -------------------------------------------------------
                  const SizedBox(height: 10),
                  const Center(child: Text("Developer Options", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 10),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.build, color: Colors.white),
                      label: const Text("GEN MOCK DATA", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        await _userService.generateMockUsers();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Generated 10 Mock Users!")));
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text("CHEAT: Everyone Likes Me ❤️", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        await _userService.cheatMakeEveryoneLikeMe();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("💖 Done!")));
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text("CHEAT: Force Match All", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        // await _userService.cheatForceMatchWithEveryone();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Chats created!")));
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      );
    }

    // --- Helper Widgets ---

    Widget _buildStatItem(String value, String label) {
      return Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)), 
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500]))
      ]);
    }

    Widget _buildSettingsTile(IconData icon, String title) {
      return InkWell(
        onTap: () {}, 
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12), 
          child: Row(children: [
            Icon(icon, color: Colors.grey[600], size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 16))), 
            const Icon(Icons.chevron_right, color: Colors.grey)
          ])
        )
      );
    }

    // Widget สำหรับสร้าง Chips สวยๆ
    Widget _buildInterestChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryGreen.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryGreen.withValues(alpha: .2)),
        ),
        child: Text(label, style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
      );
    }
  }