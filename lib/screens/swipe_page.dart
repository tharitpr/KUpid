// lib/screens/swipe_page.dart
import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/swipe_buttons.dart'; 
class SwipePage extends StatefulWidget {  
  const SwipePage({super.key});

  @override  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
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
  // ❌ ลบ int _selectedIndex ออกแล้ว

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

  // ❌ ลบ void _onNavigate ออกแล้ว

  void _swipe(bool isRight) {
    final oldIndex = index;
      setState(() {
      if (index < mockProfiles.length - 1) {
        index++;
      } else {
        index = 0;
      }
        cardOffset = Offset.zero;

    if (isRight && oldIndex % 2 == 0) { 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IT'S A MATCH!")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = mockProfiles[index];
    // ไม่ต้องดึง primaryColor มาใช้กับ Navbar แล้ว

    return Scaffold(
      // ------------------------------------------------
      // BODY (เหลือแค่ส่วนเนื้อหา)
      // ------------------------------------------------
    body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
          colors: [
              Color(0xFFE5F2E4),
              Color(0xFFE5F2E4),
              Color(0xFFF2F1E4),
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
                left: 0, 
                right: 0, 
                child: Center( 
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
      
      // ❌ ลบ bottomNavigationBar ทิ้งไปเลย
    );
  }
}