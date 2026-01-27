// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/setup_profile_page.dart';
// Screens
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/profile_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/swipe_page.dart';
import 'screens/chat_list_page.dart';
// import 'screens/chat_room_page.dart'; // ไม่ต้องใส่ใน Route แล้ว คอมเมนต์ออกหรือลบได้เลย
import 'screens/friend_zone_page.dart';
import 'screens/main_layout.dart';
import 'screens/setup_interests_page.dart';
void main() async {
  // 1. ตรึงหน้า Splash ไว้ก่อนจนกว่าจะโหลดทรัพยากรเสร็จ
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // (ลบบรรทัดซ้ำออกแล้ว)

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KupidApp());
}

class KupidApp extends StatefulWidget {
  const KupidApp({super.key});

  @override
  State<KupidApp> createState() => _KupidAppState();
}

class _KupidAppState extends State<KupidApp> {
  
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // 2. จำลองการโหลดข้อมูล
    await Future.delayed(const Duration(seconds: 2));
    
    // 3. เอาหน้า Splash ออก
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KUpid",
      debugShowCheckedModeBanner: false,

      // -------------------------
      // THEME
      // -------------------------
      theme: ThemeData(
        fontFamily: "Kanit",
        primaryColor: const Color(0xFF1DB954),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954),
          primary: const Color(0xFF1DB954),
          surface: const Color(0xFF0C2F1C),
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
        "/main": (context) => const MainLayout(), 
        
        // หน้าอื่นๆ (ใส่ไว้เผื่อใช้ แต่ chatroom เอาออกแล้ว)
        "/swipe": (context) => const SwipePage(), 
        "/chats": (context) => const ChatListPage(), 
        "/profile": (context) => const ProfilePage(), 
        "/friendzone": (context) => const FriendZonePage(),
        "/editprofile": (context) => const EditProfilePage(),
        "/setupprofile": (context) => const SetupProfilePage(),
        "/setupinterests": (context) => const SetupInterestsPage(),
        // ❌ ลบบรรทัด chatroom ออกครับ เพราะหน้าแชทเราต้องส่งค่า dynamic เสมอ
        // "/chatroom": (context) => const ChatRoomPage(), 
      },
    );
  }
}