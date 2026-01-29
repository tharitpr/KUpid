// lib/screens/profile_page.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'edit_profile_page.dart'; 
import 'setup_interests_page.dart';
import 'privacy_settings_page.dart'; 
import 'notification_settings_page.dart'; 
import 'my_profile_preview_page.dart'; // ✅ Import หน้าใหม่ที่เราเพิ่งสร้าง

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
   // final Color _accentGreen = const Color(0xFF32CD32);
    final Color _bgGrey = const Color(0xFFF9FAFB);

    bool _isUploading = false;

    // --- Cloudinary Config ---
    Future<void> _pickAndUploadGalleryPhoto() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (image == null) return;

      setState(() => _isUploading = true);

      String cloudName = "dgdl2uy9z"; 
      String uploadPreset = "Kupid_tharit"; 

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

    // --- ✅ ฟังก์ชันยกเลิกกิจกรรม ---
    Future<void> _leaveActivity(String activityName) async {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Cancel Activity"),
          content: Text("Do you want to cancel joining '$activityName'?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      try {
        // 1. ลบออกจาก Profile เรา
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
          'joinedActivities': FieldValue.arrayRemove([activityName])
        });

        // 2. ลบออกจาก Activity Document (อันนี้ยากหน่อยเพราะต้องหา Doc ID จากชื่อ)
        // เพื่อความง่ายใน MVP เราอาจจะลบแค่ฝั่ง User ก่อนเพื่อให้หน้า UI อัปเดต
        // แต่ถ้าจะเอาสมบูรณ์ ต้อง query หา activity ที่มีชื่อนี้ แล้วลบ uid เราออกจาก participants array
        
        // (Optional: Advanced)
        final activityQuery = await FirebaseFirestore.instance
            .collection('activities')
            .where('title', isEqualTo: activityName)
            .limit(1)
            .get();

        if (activityQuery.docs.isNotEmpty) {
           final activityDoc = activityQuery.docs.first;
           
           // ต้องดึง array เดิมมา filter เอาตัวเราออก (เพราะใน participants เก็บเป็น Map {uid, gender...})
           List<dynamic> participants = activityDoc['participants'] ?? [];
           participants.removeWhere((p) => p['uid'] == currentUser!.uid);

           await FirebaseFirestore.instance.collection('activities').doc(activityDoc.id).update({
             'participants': participants
           });
        }

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Activity cancelled.")));

      } catch (e) {
        debugPrint("Error leaving activity: $e");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to cancel.")));
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: _bgGrey,
        appBar: AppBar(
          backgroundColor: _bgGrey,
          elevation: 0,
          title: const Text("My Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28)),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [],
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
            String displayImage = userData['photoUrl'] ?? "";
            String faculty = userData['faculty'] ?? "Faculty";
            
            // ใช้ Year แทน Age
            String year = userData['year'] ?? ""; 
            String displayYear = year.isNotEmpty ? ", $year" : "";

            String bio = userData['bio'] ?? "No bio yet...";
            String studentId = userData['studentId'] ?? "-";
            List<dynamic> galleryPhotos = userData['galleryPhotos'] ?? [];
            List<dynamic> interests = userData['interests'] ?? [];
            
            // ✅ ดึงรายการกิจกรรม
            List<dynamic> joinedActivities = userData['joinedActivities'] ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  // 1. HEADER CARD (Avatar + Basic Info)
                  // ---------------------------------------------------
                // 1. HEADER CARD (Avatar + Basic Info) - Modern UI
                // ---------------------------------------------------
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- 1.1 Avatar Section ---
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3), // Border ขาวรอบรูป
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45, // ขนาดรูป
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: displayImage.isNotEmpty
                                      ? NetworkImage(displayImage)
                                      : null,
                                  child: displayImage.isEmpty
                                      ? Icon(Icons.person, size: 45, color: Colors.grey[400])
                                      : null,
                                ),
                              ),
                              
                              // ปุ่ม Edit เล็กๆ ที่มุมรูป
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
                                    ],
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 20),

                          // --- 1.2 Info Section ---
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(
                                  "$displayName$displayYear",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                
                                // Faculty
                                Row(
                                  children: [
                                    Icon(Icons.school, size: 16, color: _primaryGreen),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        faculty,
                                        style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                // Student ID
                                Row(
                                  children: [
                                    Icon(Icons.badge, size: 16, color: _primaryGreen),
                                    const SizedBox(width: 6),
                                    Text(
                                      "ID: $studentId",
                                      style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- 1.3 Preview Button (Modern Style) ---
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.08), // พื้นหลังสีเขียวอ่อนจางๆ
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _primaryGreen.withOpacity(0.3)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              // แพ็คข้อมูลส่งไปหน้า Preview
                              Map<String, dynamic> myProfileData = {
                                ...userData,
                                'uid': currentUser!.uid,
                                'image': userData['photoUrl'],
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyProfilePreviewPage(profileData: myProfileData),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.visibility_outlined, color: _primaryGreen),
                                const SizedBox(width: 8),
                                Text(
                                  "Preview Profile Card",
                                  style: TextStyle(
                                    color: _primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                  const SizedBox(height: 12),

                  // -------------------------------------------------------------
                  // ส่วนแสดง My Activities (UI ปรับปรุงใหม่)
                  // -------------------------------------------------------------
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. หัวข้อ
                        Row(
                          children: [
                            Icon(Icons.event_note, color: _primaryGreen, size: 24),
                            const SizedBox(width: 8),
                            const Text("My Activities",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 2. เนื้อหา (รายการกิจกรรม)
                        if (joinedActivities.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text("You haven't joined any activities.",
                                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: joinedActivities.map((activityName) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12), // เว้นระยะระหว่างการ์ด
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!), // เส้นขอบบางๆ
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  // ไอคอนด้านหน้า (Leading)
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _primaryGreen.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.confirmation_number,
                                        color: _primaryGreen, size: 20),
                                  ),
                                  // ชื่อกิจกรรม
                                  title: Text(
                                    activityName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black87),
                                  ),
                                  // ปุ่มยกเลิก (Trailing)
                                  trailing: InkWell(
                                    onTap: () => _leaveActivity(activityName),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.exit_to_app, size: 14, color: Colors.red),
                                          SizedBox(width: 4),
                                          Text(
                                            "Leave",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 2. ABOUT ME & INTERESTS
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_activity, color: _primaryGreen),
                                const SizedBox(width: 8),
                                const Text("Interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupInterestsPage()));
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (interests.isEmpty)
                          const Text("No interests added yet.", style: TextStyle(color: Colors.grey))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: interests.map((interest) {
                              return _buildInterestChip(interest.toString());
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. MY PHOTOS
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
                          itemCount: galleryPhotos.length < 9 ? galleryPhotos.length + 1 : galleryPhotos.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            if (index == galleryPhotos.length && galleryPhotos.length < 9) {
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
                                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle),
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
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(Icons.person_outline, "Account Settings", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()))),
                        _buildSettingsTile(Icons.lock_outline, "Privacy & Safety", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySettingsPage()))),
                        _buildSettingsTile(Icons.notifications_outlined, "Notifications", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage()))),
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

                  // Dev Options
                  const SizedBox(height: 10),
                  const Center(child: Text("Developer Options", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 10),
                  
               /*   Container(
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
                  ),*/

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text("CHEAT: Everyone Likes Me ❤️", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        await _userService.cheatMakeEveryoneLikeMe();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("💖 Done! Everyone loves you.")));
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

   /* Widget _buildDefaultAvatar() {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.person, size: 50, color: Colors.grey),
        ),
      );
    } */

  /*  Widget _buildStatItem(String value, String label) {
      return Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)), 
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500]))
      ]);
    }*/

    Widget _buildSettingsTile(IconData icon, String title, {required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap, 
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

    Widget _buildInterestChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryGreen.withOpacity(0.2)),
        ),
        child: Text(label, style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
      );
    }
}