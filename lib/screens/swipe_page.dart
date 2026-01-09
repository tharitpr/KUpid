// lib/screens/swipe_page.dart
import 'package:flutter/material.dart';
//import 'dart:math';

// **นำเข้า Widget ที่แยกไฟล์แล้ว**
import '../widgets/profile_card.dart'; 
import '../widgets/swipe_buttons.dart'; 
// import '../widgets/match_popup.dart'; // เตรียมใช้ Match Popup ในอนาคต

class SwipePage extends StatefulWidget {
 const SwipePage({super.key});

 @override
 State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage>
 with SingleTickerProviderStateMixin {
 late AnimationController _controller;
 Offset cardOffset = Offset.zero;

 final List<Map<String, String>> mockProfiles = [
 {
 "name": "Alice, 20",
 "faculty": "Faculty of Engineering",
 "image": "assets/mock/girl1.jpg"
 },
 {
 "name": "Beem, 21",
 "faculty": "Faculty of Science",
 "image": "assets/mock/girl2.jpg"
},
 {
 "name": "Mint, 22",
 "faculty": "Faculty of Architecture",
 "image": "assets/mock/girl3.jpg"
 },
 ];

 int index = 0;
  int _selectedIndex = 0; // **สถานะสำหรับ Bottom Navigation**

 @override
 void initState() {
 super.initState();
  _controller = AnimationController(
   vsync: this,
   duration: const Duration(milliseconds: 300),
  );
 }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Logic การนำทางใน Bottom Nav
  void _onNavigate(int newIndex) {
    if (_selectedIndex == newIndex) return; // ไม่ทำอะไรถ้ากดหน้าเดิม

    String routeName = '/swipe'; // ค่าเริ่มต้น

    switch (newIndex) {
      case 0: // Swipe Page (อยู่หน้านี้แล้ว)
        routeName = '/swipe'; 
        break;
      case 1: // Chat List Page
        routeName = '/friendzone';
        break;
      case 2: // Profile Page
        routeName = '/chats';
        break;
      case 3: // Profile Page
        routeName = '/profile';
        break;
    }
    
    // **นำทางไปยังหน้าจอใหม่**
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  void _swipe(bool isRight) {
    final oldIndex = index;
    // Mock: เปลี่ยนการ์ดเฉย ๆ
    setState(() {
      if (index < mockProfiles.length - 1) {
        index++;
      } else {
        index = 0;
      }
      cardOffset = Offset.zero;

      // Match Logic (Mock)
      if (isRight && oldIndex % 2 == 0) { 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IT'S A MATCH!")));
      }
    });
  }

 @override
 Widget build(BuildContext context) {
 final profile = mockProfiles[index];
    final Color primaryColor = Theme.of(context).primaryColor;


    return Scaffold(
      // ------------------------------------------------
      // BODY (ส่วน Swipe Logic เดิม)
      // ------------------------------------------------
      body: Container(
        // ใช้ Container เพื่อกำหนด Gradient พื้นหลัง
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 151, 193, 159),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea( 
          child: Stack(
            children: [
              // ---------------- HEADER (Love Zone) ----------------
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Center(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "LOVE ",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                        ),
                      ),
                      TextSpan(
                        text: "Zone",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
              
            Positioned(
            top: 75,
            left: 0,     // ยืดให้เต็มความกว้าง
            right: 0,    // ยืดให้เต็มความกว้าง
            child: Center( // จัดกึ่งกลางข้อความ
            child: Text(
              "Kasetsart University", 
              style: TextStyle(
                fontSize: 16, 
                color: Colors.black,
              ),
            ),
            ),
            ),

            
              // ---------------- CARD AREA ----------------
              Center(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      cardOffset += details.delta;
                    });
                  },
                  onPanEnd: (details) {
                    if (cardOffset.dx.abs() > 120) {
                      _swipe(cardOffset.dx > 0); 
                    } else {
                      setState(() => cardOffset = Offset.zero);
                    }
                  },
                  child: Transform.translate(
                    offset: cardOffset,
                    child: Transform.rotate(
                      angle: cardOffset.dx * 0.002,
                      child: ProfileCard(profileData: profile),
                    ),
                  ),
                ),
              ),

              // ---------------- BUTTONS ----------------
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SwipeButtons(
                    onLike: () => _swipe(true),
                    onDislike: () => _swipe(false),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      
      // ------------------------------------------------
      // BOTTOM NAVIGATION BAR (ส่วนที่เพิ่มเข้ามา)
      // ------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // พื้นหลังสีขาว
        selectedItemColor: primaryColor, // สีเขียวหลัก
        unselectedItemColor: Colors.grey, // สีเทา
        currentIndex: 0, // ตั้งค่าให้หน้า Swipe ถูกเลือกเสมอ (Index 0)
        onTap: _onNavigate, // เมื่อมีการกดไอคอน
        type: BottomNavigationBarType.fixed, 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Love',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Friends',
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