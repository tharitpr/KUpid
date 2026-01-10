// lib/screens/swipe_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/swipe_buttons.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  // Mock Data
  final List<Map<String, String>> mockProfiles = [
    {"name": "Alice, 20", "faculty": "Faculty of Engineering", "image": "assets/mock/girl1.jpg"},
    {"name": "Beem, 21", "faculty": "Faculty of Science", "image": "assets/mock/girl2.jpg"},
    {"name": "Mint, 22", "faculty": "Faculty of Architecture", "image": "assets/mock/girl3.jpg"},
    {"name": "Fah, 19", "faculty": "Faculty of Agro-Industry", "image": "assets/mock/girl4.jpg"},
    {"name": "Ploy, 23", "faculty": "Faculty of Humanities", "image": "assets/mock/girl5.jpg"},
  ];

  int index = 0;
  Offset _dragOffset = Offset.zero;
  late AnimationController _animController;
  late Animation<Offset> _animation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_animController);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (index < mockProfiles.length) index++;
          _dragOffset = Offset.zero;
          _animController.reset(); // รีเซ็ตเพื่อรอใบถัดไป
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ฟังก์ชัน Swipe ด้วยปุ่ม
  void _buttonSwipe(bool isRight) {
    if (index >= mockProfiles.length) return;
    
    // จำลองการลากไปสุดขอบจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = isRight ? screenWidth : -screenWidth;

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endX, 0), // ลากไปแนวนอน
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _animController.forward();
  }

  // ฟังก์ชันเมื่อปล่อยมือจากการลาก
  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;

    // ถ้าลากเกินครึ่งจอ หรือ ปัดเร็วๆ
    if (_dragOffset.dx.abs() > screenWidth * 0.4 || velocity.abs() > 800) {
      final isRight = _dragOffset.dx > 0;
      final endX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(endX, _dragOffset.dy), // ส่งการ์ดบินออกไป
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      
      _animController.forward();
    } else {
      // ถ้าลากไม่พอก็เด้งกลับที่เดิม
      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut)); // เด้งดึ๋ง
      
      _animController.forward();
    }
    
    setState(() => _isDragging = false);
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // พื้นหลังเทาอ่อน สะอาดตา
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          // พื้นที่การ์ด (ใช้ Expanded เพื่อดันปุ่มลงล่าง)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: index < mockProfiles.length 
                  ? _buildCardStack() // แสดงการ์ดถ้ายังมีข้อมูล
                  : _buildEmptyState(), // แสดงหน้าว่างถ้าข้อมูลหมด
            ),
          ),
          
          // ปุ่มควบคุมด้านล่าง
          if (index < mockProfiles.length)
             Padding(
               padding: const EdgeInsets.only(bottom: 30),
               child: SwipeButtons(
                  onLike: () => _buttonSwipe(true),
                  onDislike: () => _buttonSwipe(false),
               ),
             ),
        ],
      ),
    );
  }

  // 1. APP BAR สไตล์ Tinder/KUpid
  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.green, size: 28),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: "KU", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                TextSpan(text: "pid", style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.grey),
          onPressed: () {}, // ปุ่ม Filter
        )
      ],
    );
  }

  // 2. CARD STACK SYSTEM
  Widget _buildCardStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // --- การ์ดใบหลัง (Back Card) ---
            if (index + 1 < mockProfiles.length)
              Transform.scale(
                scale: 0.95, // เล็กกว่าใบหน้านิดหน่อย
                child: Transform.translate(
                  offset: const Offset(0, 10), // อยู่ต่ำกว่านิดหน่อย
                  child: Opacity(
                    opacity: 0.6, // จางกว่า
                    child: ProfileCard(profileData: mockProfiles[index + 1]),
                  ),
                ),
              ),

            // --- การ์ดใบหน้า (Front Card) ---
            GestureDetector(
              onPanStart: (_) => setState(() => _isDragging = true),
              onPanUpdate: (details) {
                setState(() {
                  _dragOffset += details.delta;
                });
              },
              onPanEnd: _onPanEnd,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  // คำนวณตำแหน่ง: ถ้ากำลัง Animate ให้ใช้ค่าจาก Controller, ถ้าลากอยู่ให้ใช้ค่าจากนิ้ว
                  final offset = _animController.isAnimating ? _animation.value : _dragOffset;
                  // คำนวณมุมหมุน: ยิ่งลากไกล ยิ่งเอียงมาก (สูงสุด 15 องศา)
                  final angle = (offset.dx / constraints.maxWidth) * (pi / 8);
                  final double scale = _isDragging ? 1.05 : 1.0;

                  return Transform.translate(
                    offset: offset,
                    child: Transform.rotate(
                      angle: angle,
                      child: Transform.scale(
                        scale: scale,
                      child: Stack(
                        children: [
                          ProfileCard(profileData: mockProfiles[index]),
                          
                          // --- LIKE / NOPE OVERLAY ---
                          _buildStatusOverlay(offset.dx),
                        ],
                      ),
                    ),
                  ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. OVERLAY แสดงคำว่า LIKE/NOPE บนการ์ด
  Widget _buildStatusOverlay(double dx) {
    if (dx == 0) return const SizedBox.shrink();

    final isLike = dx > 0;
    final opacity = (dx.abs() / 150).clamp(0.0, 1.0); // ยิ่งลากไกล ยิ่งชัด

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // ต้องตรงกับ ProfileCard
          color: isLike ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        ),
        child: Center(
          child: Transform.rotate(
            angle: isLike ? -0.2 : 0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isLike ? Colors.green : Colors.red, 
                  width: 4
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isLike ? "LIKE" : "NOPE",
                style: TextStyle(
                  color: isLike ? Colors.green : Colors.red,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. EMPTY STATE เมื่อไพ่หมด
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
            ),
            child: const Icon(Icons.search, size: 60, color: Colors.green),
          ),
          const SizedBox(height: 20),
          const Text(
            "No more profiles",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Check back later for more KU students!",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() => index = 0); // รีเซ็ตเพื่อ demo
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Refresh", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}