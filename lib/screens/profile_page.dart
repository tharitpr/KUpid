// lib/screens/profile_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  // --- Constants สีตาม Theme KUpid ---
  final Color _primaryGreen = const Color(0xFF006400); 
  final Color _accentGreen = const Color(0xFF32CD32);  
  final Color _bgGrey = const Color(0xFFF9FAFB);       

  // ✅ แก้ลิงก์ 1: รูป Profile Default (ใช้รูปคนจริงจาก Pexels)
  final String malePlaceholder = "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=600";

  // ✅ แก้ลิงก์ 2: รูปใน Gallery (เปลี่ยนเป็น Direct Link ทั้งหมด)
  final List<String> _photos = [
    'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=600', // ผู้ชายขับรถ (แทนลิงก์รถสปอร์ตที่เสีย)
    'https://images.pexels.com/photos/837358/pexels-photo-837358.jpeg?auto=compress&cs=tinysrgb&w=600',   // ผู้ชายใส่แว่นเท่ๆ
    'https://images.pexels.com/photos/874158/pexels-photo-874158.jpeg?auto=compress&cs=tinysrgb&w=600',    // ผู้ชายยิ้ม
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          Map<String, dynamic> userData = {};
          if (snapshot.hasData && snapshot.data!.exists) {
            userData = snapshot.data!.data() as Map<String, dynamic>;
          }

          String displayName = userData['name'] ?? "User Name";
          // ถ้าไม่มีรูปใน DB ให้ใช้ malePlaceholder ที่แก้ลิงก์แล้ว
          String displayImage = (userData['photoUrl'] != null && userData['photoUrl'].isNotEmpty) 
              ? userData['photoUrl'] 
              : malePlaceholder;
              
          String faculty = userData['faculty'] ?? "Engineering Faculty";
          String age = userData['age'] != null ? ", ${userData['age']}" : "";

          return SingleChildScrollView(
            child: Column(
              children: [
                // -------------------------------------------------------
                // 1. PROFILE HEADER SECTION
                // -------------------------------------------------------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Avatar ---
                      Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                              ]
                            ),
                            // ✅ ใช้ ClipRRect + Image.network พร้อม Error Builder
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                displayImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // ถ้าโหลดรูปไม่ได้ ให้โชว์กล่องสีเทาแทนแอปแดง
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 50, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _accentGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 20),

                      // --- Name & Stats ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$displayName$age", 
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(faculty, style: TextStyle(color: Colors.grey[600], fontSize: 14), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem("48", "Matches"),
                                _buildStatItem("12", "Events"),
                                _buildStatItem("95%", "Rating"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 1),

                // -------------------------------------------------------
                // 2. MY PHOTOS SECTION
                // -------------------------------------------------------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("My Photos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _photos.length + 1,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          if (index < _photos.length) {
                            // ✅ Grid View ก็ต้องใส่ Error Builder กันรูปเสีย
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _photos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  );
                                },
                              ),
                            );
                          } 
                          else {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Center(
                                child: Icon(Icons.add, color: Colors.grey[400], size: 30),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // -------------------------------------------------------
                // 3. SETTINGS & LOGOUT
                // -------------------------------------------------------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 12, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _buildSettingsTile("Account Settings"),
                      _buildSettingsTile("Privacy & Safety"),
                      _buildSettingsTile("Notifications"),
                      const Divider(height: 20),
                      
                      InkWell(
                        onTap: () async {
                          await _authService.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 12),
                              Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Center(child: Text("Developer Options (Demo Only)", style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 10),

                // -------------------------------------------------------
                // 🛠️ CHEAT CODES ZONE
                // -------------------------------------------------------
                
                // 1. GEN MOCK DATA
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.build, color: Colors.white),
                    label: const Text("GEN MOCK DATA (Dev Only)", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      await _userService.generateMockUsers();
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Generated 10 Mock Users!")));
                    },
                  ),
                ),

                // 2. CHEAT: Make Everyone Like Me
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.favorite, color: Colors.white),
                    label: const Text("CHEAT: Make Everyone Like Me ❤️", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      await _userService.cheatMakeEveryoneLikeMe();
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("💖 Everyone likes you now! Go Swipe!")));
                    },
                  ),
                ),

                // 3. CHEAT: Force Match All
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text("CHEAT: Force Match All (Create Chats)", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                 //      await _userService.cheatForceMatchWithEveryone();
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ All chats created! Check Messages tab.")));
                    },
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildSettingsTile(String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 16))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}