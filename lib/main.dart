// lib/main.dart

import 'package:flutter/material.dart';

// Screens
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/profile_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/swipe_page.dart'; // นำเข้า
import 'screens/chat_list_page.dart'; // นำเข้า
import 'screens/chat_room_page.dart';

void main() {
  runApp(const KupidApp());
}

class KupidApp extends StatelessWidget {
  const KupidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KUpid",
      debugShowCheckedModeBanner: false,

      // -------------------------
      // THEME (เหมือนเดิม)
      // -------------------------
      theme: ThemeData(
        fontFamily: "Kanit",
        primaryColor: const Color(0xFF0C2F1C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954),
          primary: const Color(0xFF1DB954),
          background: const Color(0xFF0C2F1C),
        ),
        scaffoldBackgroundColor: const Color(0xFF0C2F1C),
        useMaterial3: true,
      ),

      // -------------------------
      // ROUTES
      // -------------------------
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        
        // **เปิด Route ที่ใช้ใน Bottom Nav**
        "/swipe": (context) => const SwipePage(), 
        "/chats": (context) => const ChatListPage(), 
        "/profile": (context) => const ProfilePage(), 
        
        "/editprofile": (context) => const EditProfilePage(),
        "/chatroom": (context) => const ChatRoomPage(),
      },
    );
  }
}