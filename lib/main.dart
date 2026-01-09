// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // เพิ่มตัวนี้

// Screens
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/profile_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/swipe_page.dart';
import 'screens/chat_list_page.dart';
import 'screens/chat_room_page.dart';
import 'screens/friend_zone_page.dart';
import 'screens/main_layout.dart';

void main() {
  // 1. ตรึงหน้า Splash ไว้ก่อนจนกว่าจะโหลดทรัพยากรเสร็จ
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  runApp(const KupidApp());
}

class KupidApp extends StatefulWidget { // เปลี่ยนเป็น StatefulWidget เพื่อจัดการการเอา Splash ออก
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
    // 2. จำลองการโหลดข้อมูล หรือเช็คระบบ KU All Login ตรงนี้ (เช่น 2-3 วินาที)
    // ในอนาคตคุณสามารถเช็คได้ว่า user เคย login หรือยังที่นี่
    await Future.delayed(const Duration(seconds: 2));
    
    // 3. เมื่อทุกอย่างพร้อมแล้ว ให้นำหน้า Splash ออกเพื่อแสดงผลแอป
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
        primaryColor: const Color(0xFF0C2F1C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954),
          primary: const Color(0xFF1DB954),
          surface: const Color(0xFF0C2F1C), // แทนที่ background ใน Flutter เวอร์ชั่นใหม่
        ),
        scaffoldBackgroundColor: const Color(0xFF0C2F1C),
        useMaterial3: true,
      ),

      // -------------------------
      // ROUTES
      // -------------------------
      initialRoute: "/login", // เริ่มต้นที่หน้า Login ถูกแล้ว
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        
        // ✅ เพิ่มบรรทัดนี้สำคัญที่สุด! 
        // เพื่อให้ตอน Login สำเร็จ เราจะสั่ง pushNamed มาที่ "/main"
        "/main": (context) => const MainLayout(), 
        
        // ⚠️ หมายเหตุ: Route พวกข้างล่างนี้ (swipe, chats, profile) 
        // จริงๆ แทบไม่ได้ใช้แล้ว เพราะมันถูกยัดไส้อยู่ใน MainLayout หมดแล้ว
        // แต่ใส่ทิ้งไว้ก็ได้ครับ ไม่ error (เผื่ออนาคตอยากเปิดแยก)
        "/swipe": (context) => const SwipePage(), 
        "/chats": (context) => const ChatListPage(), 
        "/profile": (context) => const ProfilePage(), 
        "/friendzone": (context) => const FriendZonePage(),
        "/editprofile": (context) => const EditProfilePage(),
        "/chatroom": (context) => const ChatRoomPage(),
      },
    );
  }
}