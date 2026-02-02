// lib/screens/main_layout.dart

import 'package:flutter/material.dart';

// นำเข้าหน้าจอหลัก
import 'swipe_page.dart'; 
import 'activity_page.dart';
import 'chat_list_page.dart'; 
import 'profile_page.dart'; 
// ✅ นำเข้า Widget สอนเล่น (ตรวจสอบ path ให้ถูกต้องนะครับ)
import '../widgets/app_tutorial_dialog.dart'; 

class MainLayout extends StatefulWidget {
  // ✅ 1. เพิ่มตัวแปรรับค่า showTutorial
  final bool showTutorial;

  const MainLayout({
    super.key,
    this.showTutorial = false, // ค่าเริ่มต้นเป็น false (ไม่โชว์)
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
    int _selectedIndex = 0; 

    // รายการหน้าจอที่ Bottom Nav จะสลับไปมาระหว่าง
    final List<Widget> _pages = [
      const SwipePage(),      // Index 0: หน้า Swiping
      const ActivityPage(),   // Index 1: หน้า Activity
      const ChatListPage(),   // Index 2: หน้า Chat List
      const ProfilePage(),    // Index 3: หน้า Profile
    ];

    @override
    void initState() {
      super.initState();
      // ✅ 2. เช็คว่าต้องโชว์ Tutorial ไหม (ทำหลังจากหน้าจอสร้างเสร็จ)
      if (widget.showTutorial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false, // บังคับให้กดปุ่มใน Dialog เท่านั้น
            builder: (context) => const AppTutorialDialog(),
          );
        });
      }
    }

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
        bottomNavigationBar: Container(
          // เพิ่มเงาให้ดูสวยงามขึ้น
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar( // ใช้ NavigationBar แบบใหม่ (Material 3) จะดูทันสมัยกว่า BottomNavigationBar
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF006400).withValues(alpha: .15), // สีพื้นหลังปุ่มที่ถูกเลือก (เขียวอ่อนจางๆ)
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: Color(0xFF006400)),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today, color: Color(0xFF006400)),
                label: 'Activities',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF006400)),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: Color(0xFF006400)),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    }
}