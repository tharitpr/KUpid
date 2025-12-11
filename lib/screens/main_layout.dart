// lib/screens/main_layout.dart

import 'package:flutter/material.dart';

// นำเข้าหน้าจอหลัก
import 'swipe_page.dart'; 
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
    const SwipePage(),     // Index 0: หน้า Swiping
    const ChatListPage(),  // Index 1: หน้า Chat List
    const ProfilePage(),   // Index 2: หน้า Profile
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
      body: _pages[_selectedIndex], 

      // ------------------------------------------------
      // Bottom Navigation Bar (ปรับตามโทนเขียว/ขาว)
      // ------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // พื้นหลังสีขาว
        selectedItemColor: Theme.of(context).primaryColor, // สีเขียวหลักของ Theme
        unselectedItemColor: Colors.grey, // สีไอคอนที่ไม่ได้เลือก
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}