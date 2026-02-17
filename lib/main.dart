// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/setup_profile_page.dart';

import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/profile_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/swipe_page.dart';
import 'screens/chat_list_page.dart';

import 'screens/friend_zone_page.dart';
import 'screens/main_layout.dart';
import 'screens/setup_interests_page.dart';
void main() async {
  // Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  


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
    
    await Future.delayed(const Duration(seconds: 2));
    
  
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KUpid",
      debugShowCheckedModeBanner: false,

   
      // THEME
     
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


      // ROUTES
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/main": (context) => const MainLayout(), 
        
        
        "/swipe": (context) => const SwipePage(), 
        "/chats": (context) => const ChatListPage(), 
        "/profile": (context) => const ProfilePage(), 
        "/friendzone": (context) => const FriendZonePage(),
        "/editprofile": (context) => const EditProfilePage(),
        "/setupprofile": (context) => const SetupProfilePage(),
        "/setupinterests": (context) => const SetupInterestsPage(),
      
        // "/chatroom": (context) => const ChatRoomPage(), 
      },
    );
  }
}