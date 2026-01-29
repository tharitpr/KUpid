// lib/screens/privacy_settings_page.dart

import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // ตัวแปรจำลองสำหรับ Toggle (เพื่อให้กดเล่นได้ ดูมีชีวิตชีวา)
  bool _showStudentId = true;
  bool _showEmail = false;
  bool _allowNotifications = true;

  final Color _primaryGreen = const Color(0xFF006400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // สีพื้นหลังเทาอ่อน
      appBar: AppBar(
        title: const Text("Privacy & Safety", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section 1: Privacy Controls ---
            const Text(
              "Privacy Controls",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: "Show Student ID",
                    subtitle: "Allow others to see your KU Student ID",
                    value: _showStudentId,
                    onChanged: (v) => setState(() => _showStudentId = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: "Show Email Address",
                    subtitle: "Visible on your profile page",
                    value: _showEmail,
                    onChanged: (v) => setState(() => _showEmail = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: "Activity Notifications",
                    subtitle: "Receive alerts for joined activities",
                    value: _allowNotifications,
                    onChanged: (v) => setState(() => _allowNotifications = v),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- Section 2: KUpid Community Guidelines ---
            const Text(
              "Community Guidelines",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryGreen.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: _primaryGreen),
                      const SizedBox(width: 10),
                      Text("Safe Meetups at KU", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryGreen)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGuidelineItem("1. Meet in public campus areas (Library, Cafeterias)."),
                  _buildGuidelineItem("2. Verify participant's Student ID if possible."),
                  _buildGuidelineItem("3. Be respectful to all students and staff."),
                  _buildGuidelineItem("4. Report any suspicious behavior immediately."),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Section 3: Data Policy (Static Text) ---
            const Text(
              "Data Policy",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "KUpid respects your privacy. We only collect your Kasetsart University student information (Name, Student ID, Faculty) to verify your identity and facilitate campus activities. Your data will not be shared with third parties without your consent.",
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
            ),

            const SizedBox(height: 40),

            // --- Footer Version ---
            const Center(
              child: Text(
                "KUpid Version 1.0.0\nMade with 💚 for KU Students",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Widget สำหรับสร้าง Switch สวยๆ
  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return SwitchListTile(
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF1DB954), // สีเขียว Spotify/KU
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
    );
  }

  // Helper Widget สำหรับข้อความ Guideline
  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}