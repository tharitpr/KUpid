// lib/screens/profile_page.dart

import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ฟังก์ชันสำหรับนำทางไปยังหน้าจอหลักอื่นๆ
    @override
    Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5F2E4),
              Color(0xFFE5F2E4),
              Color(0xFFF2F1E4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),  
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // HEADER -------------------------------------------------------------
              const Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // PROFILE CARD --------------------------------------------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  // ใช้สีอ่อนลงมาเพื่อให้มองเห็นขอบ Card บนพื้นหลังเข้ม
                  color: Colors.black.withOpacity(0.3), 
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    // AVATAR -------------------------------------------------------
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: Colors.white70, width: 3),
                        image: const DecorationImage(
                          image: AssetImage("assets/mock/profile.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NAME ---------------------------------------------------------
                    const Text(
                      "Tharit Chandee",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Computer Engineering • KU",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),

                    const SizedBox(height: 20),

                    // INFO LIST -----------------------------------------------------
                    _profileItem(Icons.email, "Email", "tharit@example.com"),
                    _profileItem(Icons.school, "Faculty", "Engineering"),
                    _profileItem(Icons.person, "Gender", "Male"),
                    _profileItem(Icons.favorite, "Status", "Ready to match"),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // EDIT PROFILE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF003A1B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/editprofile");
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LOGOUT
              TextButton(
                onPressed: () {
                  // TODO: เพิ่ม Logic Logout ที่นี่
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  // PROFILE ITEM UI (ย้ายมาอยู่นอก build method)
  // ------------------------------------------------------------------------
  static Widget _profileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}