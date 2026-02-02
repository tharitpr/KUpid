// lib/screens/notification_settings_page.dart

import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // --- Mock State Variables (ตัวแปรจำลองสถานะ) ---
  bool _activityReminders = true;  // เตือนก่อนเริ่มกิจกรรม
  bool _statusUpdates = true;      // เตือนเมื่อสถานะกิจกรรมเปลี่ยน (Approved)
  bool _newRecommendations = false; // แนะนำกิจกรรมใหม่ๆ
  bool _sound = true;              // เสียง
  bool _vibrate = true;            // สั่น

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // พื้นหลังสีเทาอ่อน
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section 1: Activity Alerts ---
            const Text(
              "Activity Alerts",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: "Activity Reminders",
                    subtitle: "Notify me 1 hour before activity starts",
                    value: _activityReminders,
                    icon: Icons.access_alarm,
                    onChanged: (v) => setState(() => _activityReminders = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: "Status Updates",
                    subtitle: "Notify when my activity is approved",
                    value: _statusUpdates,
                    icon: Icons.check_circle_outline,
                    onChanged: (v) => setState(() => _statusUpdates = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: "New Recommendations",
                    subtitle: "Suggest activities based on my interest",
                    value: _newRecommendations,
                    icon: Icons.recommend,
                    onChanged: (v) => setState(() => _newRecommendations = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Section 2: App System ---
            const Text(
              "System & Sounds",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: "Sound",
                    subtitle: "Play sound for incoming notifications",
                    value: _sound,
                    icon: Icons.volume_up,
                    onChanged: (v) => setState(() => _sound = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: "Vibrate",
                    subtitle: "Vibrate on new notification",
                    value: _vibrate,
                    icon: Icons.vibration,
                    onChanged: (v) => setState(() => _vibrate = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // --- Info Text ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "You can also manage system-level notifications in your device settings.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget: Switch Tile ---
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF1DB954), // สีเขียวสวยๆ
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
    );
  }
}