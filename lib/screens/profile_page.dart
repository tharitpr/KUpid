// lib/screens/profile_page.dart

import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- Constants สีตาม Theme KUpid ---
  final Color _primaryGreen = const Color(0xFF006400); // เขียวเข้ม
  final Color _accentGreen = const Color(0xFF32CD32);  // เขียวสด
  final Color _bgGrey = const Color(0xFFF9FAFB);       // เทาอ่อนมาก

  // ข้อมูลจำลอง (Mock Data)
  final List<String> _interests = ['Photography', 'Coffee', 'Reading', 'Music', 'Travel', 'Art'];
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1554151228-14d9def656ec?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=300&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey, // พื้นหลังสีเทาอ่อน
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false, // ไม่แสดงปุ่ม Back เพราะอยู่ใน Main Menu
        actions: [
          // ปุ่ม Settings (ฟันเฟือง) มุมขวาบน
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/editprofile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -------------------------------------------------------
            // 1. PROFILE HEADER SECTION (ข้อมูลส่วนตัว + สถิติ)
            // -------------------------------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Avatar & Edit Icon ---
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            // TODO: เปลี่ยนเป็น AssetImage('assets/mock/profile.jpg') ถ้ามีรูปในเครื่อง
                            image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                      ),
                      // ปุ่มดินสอเล็กๆ ตรงมุมรูป
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/editprofile');
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
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
                        const Text(
                          "Arisa, 21",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text("Engineering Faculty", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats Row
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
            
            const SizedBox(height: 1), // เส้นคั่น

            // -------------------------------------------------------
            // 2. MY PHOTOS SECTION (รูปภาพ)
            // -------------------------------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("My Photos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () {},
                        child: Text("Add Photo", style: TextStyle(color: _primaryGreen)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _photos.length + 1, // +1 คือปุ่ม Add
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index < _photos.length) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_photos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        // ปุ่ม Add (+)
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.grey[400], size: 30),
                                Text("Add", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // -------------------------------------------------------
            // 3. ABOUT ME & INTERESTS (เกี่ยวกับฉัน และ ความสนใจ)
            // -------------------------------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("About Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.edit_outlined, size: 20, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Love exploring new cafes and taking photos around campus! Always up for an adventure or a good conversation over coffee. Let's connect! ☕📸",
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Text("Interests", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(color: _primaryGreen, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // -------------------------------------------------------
            // 4. PROFILE INSIGHTS (ข้อมูลเชิงลึก)
            // -------------------------------------------------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _buildInsightItem(Icons.favorite, "Profile Views", "Last 7 days", "127", _primaryGreen),
                  const SizedBox(height: 12),
                  _buildInsightItem(Icons.star, "Likes Received", "All time", "342", _accentGreen),
                  const SizedBox(height: 12),
                  _buildInsightItem(Icons.people, "Mutual Friends", "On KUpid", "23", Colors.purple),
                ],
              ),
            ),

            // -------------------------------------------------------
            // 5. SETTINGS & LOGOUT (ตั้งค่า และ ออกจากระบบ)
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
                  
                  // ปุ่ม Logout
                  InkWell(
                    onTap: () {
                      // กลับไปหน้า Login และลบประวัติการย้อนกลับทั้งหมด
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String subtitle, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title) {
    return InkWell(
      onTap: () {
        // TODO: เชื่อมหน้า Settings ย่อย
      },
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