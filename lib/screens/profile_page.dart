// lib/screens/profile_page.dart

import 'package:firebase_auth/firebase_auth.dart'; // import เพื่อดึงข้อมูล user ปัจจุบัน
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // 1. Import Service
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. เรียกใช้ AuthService
  final AuthService _authService = AuthService();
  
  // ดึงข้อมูล User ปัจจุบันมาโชว์ (เพื่อ Test ว่า Login มาจริง)
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // --- Constants สีตาม Theme KUpid ---
  final Color _primaryGreen = const Color(0xFF006400); 
  final Color _accentGreen = const Color(0xFF32CD32);  
  final Color _bgGrey = const Color(0xFFF9FAFB);       

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
              // Navigator.pushNamed(context, '/editprofile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                          image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80'),
                            fit: BoxFit.cover,
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
                        // *จุดแก้: ลองดึง Email มาโชว์แทนชื่อ เพื่อยืนยันว่า Backend ทำงาน*
                        Text(
                          currentUser?.email ?? "Arisa, 21", // ถ้ามี User จริง ให้โชว์ Email
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
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
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_photos[index]),
                              fit: BoxFit.cover,
                            ),
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
            // 5. SETTINGS & LOGOUT
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
                  
                  // ปุ่ม Logout (แก้ไขแล้ว)
                  InkWell(
                    // 2. เพิ่ม async logic ตรงนี้
                    onTap: () async {
                      // สั่ง Firebase ให้ Sign Out
                      await _authService.signOut();

                      if (context.mounted) {
                        // กลับไปหน้า Login (ต้องแน่ใจว่าใน main.dart มี route ชื่อ '/login')
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        
                        // หรือถ้า route '/login' ไม่เวิร์ค ให้ใช้บรรทัดล่างนี้แทน:
                        // Navigator.of(context).pushAndRemoveUntil(
                        //   MaterialPageRoute(builder: (context) => const LoginPage()), 
                        //   (route) => false
                        // );
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

            // -------------------------------------------------------
            // DEV ONLY: ปุ่มสร้างข้อมูลคนปลอม (Mock Data)
            // -------------------------------------------------------
            Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // สีส้มให้รู้ว่าเป็นปุ่มเทส
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.build, color: Colors.white),
                  label: const Text("GEN MOCK DATA (Dev Only)", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    // เรียกฟังก์ชันเสกคน
                    await UserService().generateMockUsers();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ สร้างข้อมูลคนปลอมเสร็จแล้ว! เช็ค Firestore ได้เลย")),
                      );
                    }
                  },
                ),
              ),

              // ... (ปุ่ม Gen Mock Data เดิม) ...

              const SizedBox(height: 10), // เว้นวรรคนิดนึง

              // ปุ่ม Cheat Code: บังคับให้ทุกคนชอบเรา
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent, // สีชมพู
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text("CHEAT: Make Everyone Like Me ❤️", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    // เรียกใช้สูตรโกง
                    await UserService().cheatMakeEveryoneLikeMe();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("เสร็จ! ตอนนี้คุณฮอตมาก ทุกคนชอบคุณหมดแล้ว ไปปัดขวาเลย!")),
                      );
                    }
                  },
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