// lib/screens/main_layout.dart

import 'package:flutter/material.dart';

// นำเข้าหน้าจอหลัก
import 'swipe_page.dart'; 
import 'activity_page.dart';
import 'chat_list_page.dart'; 
import 'profile_page.dart'; 

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
    int _selectedIndex = 0; 

    // รายการหน้าจอที่ Bottom Nav จะสลับไปมาระหว่าง
    final List<Widget> _pages = [
      const SwipePage(), //Index 0: หน้า Swiping
      const ActivityPage(),  // Index 1: หน้า Activity
      const ChatListPage(),  // Index 2: หน้า Chat List
      const ProfilePage(),   // Index 3: หน้า Profile
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      // ใช้ Scaffold เพื่อใส่ Bottom Navigation Bar
      return Scaffold(
        // body แสดงหน้าจอตาม index ที่ถูกเลือก
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),

        // ------------------------------------------------
        // Bottom Navigation Bar (ปรับตามโทนเขียว/ขาว)
        // ------------------------------------------------
              bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // พื้นหลังสีขาว
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Activities'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    }
  }