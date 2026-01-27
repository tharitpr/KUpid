// lib/screens/swipe_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Widgets
import '../widgets/profile_card.dart';
import '../widgets/swipe_buttons.dart';

// Services
import '../services/user_service.dart';
import '../services/match_service.dart';

// Pages
import 'chat_room_page.dart';
import 'profile_detail_page.dart'; // ✅ Import หน้า Detail

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with SingleTickerProviderStateMixin {
  
  // Service Instances
  final MatchService _matchService = MatchService();
  
  // Data Variables
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;

  // Animation Variables
  int index = 0;
  Offset _dragOffset = Offset.zero;
  late AnimationController _animController;
  late Animation<Offset> _animation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    
    // Setup Animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_animController);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (index < _profiles.length) index++; 
          _dragOffset = Offset.zero;
          _animController.reset(); 
        });
      }
    });

    // เรียกดึงข้อมูลทันทีที่เปิดหน้า
    _loadProfiles();
  }

  // --- 1. ฟังก์ชันดึงข้อมูลจาก Firebase ---
  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    
    try {
      var users = await UserService().getUsersToSwipe();
      
      var formattedUsers = users.map((user) {
        return {
          ...user,
          "image": user['photoUrl'] ?? "https://via.placeholder.com/400",
          "name": user['name'] ?? "Unknown", 
          "uid": user['uid'] ?? user['id'] ?? "", 
        };
      }).toList();

      if (mounted) {
        setState(() {
          _profiles = formattedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profiles: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. ฟังก์ชันจัดการ Backend (บันทึก Like/Pass) ---
  void _handleSwipeBackend(bool isLike) async {
    if (index >= _profiles.length) return;

    var targetUser = _profiles[index];
    String targetUserId = targetUser['uid'];

    if (targetUserId.isEmpty) {
      debugPrint("Error: No User ID found");
      return;
    }

    if (isLike) {
      debugPrint("❤️ Liking ${targetUser['name']}...");
      bool isMatch = await _matchService.swipeRight(targetUserId, targetUser['name']);
      
      if (isMatch && mounted) {
        _showMatchDialog(targetUser, targetUserId);
      }
    } else {
      debugPrint("👎 Passing ${targetUser['name']}");
      await _matchService.swipeLeft(targetUserId);
    }
  }

  void _showMatchDialog(Map<String, dynamic> targetUser, String targetUserId) {
    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้กดปุ่มเท่านั้น
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent, // ให้พื้นหลังใส เพื่อทำ Layer สวยๆ
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Title
              const Text(
                "It's a Match!",
                style: TextStyle(
                  fontFamily: 'Cursive', // หรือใช้ Font หนาๆ
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF006400), // สีเขียวเข้ม
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You and this person liked each other.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              
              const SizedBox(height: 30),

              // 2. Avatar with Heart Decoration
              Stack(
                alignment: Alignment.center,
                children: [
                  // วงกลม Effect พื้นหลัง
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF006400).withOpacity(0.1),
                    ),
                  ),
                  // รูป Profile
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF006400), width: 4), // ขอบสีเขียว
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(targetUser['image']),
                      onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.person),
                    ),
                  ),
                  // ไอคอนหัวใจดวงเล็ก
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Name
              Text(
                "Say hello to ${targetUser['name']}!",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // 4. Primary Button (Send Message) - Gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006400), Color(0xFF32CD32)], // ไล่สีเขียว
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF32CD32).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Logic เดิมในการไปหน้าแชท
                    String myId = FirebaseAuth.instance.currentUser!.uid;
                    String partnerId = targetUserId;
                    String chatId = myId.compareTo(partnerId) < 0 ? "${myId}_$partnerId" : "${partnerId}_$myId";

                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          chatId: chatId,
                          friendName: targetUser['name'],
                          friendImage: targetUser['image'],
                        )
                      )
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Send Message", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 5. Secondary Button (Keep Swiping)
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  "Keep Swiping",
                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- 3. ฟังก์ชัน Swipe ด้วยปุ่ม ---
  void _buttonSwipe(bool isRight) {
    if (index >= _profiles.length) return; 
    
    _handleSwipeBackend(isRight);

    final screenWidth = MediaQuery.of(context).size.width;
    final endX = isRight ? screenWidth : -screenWidth;
    
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endX, 0), 
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _animController.forward();
  }

  // --- 4. ฟังก์ชัน Swipe ด้วยมือ (Pan End) ---
  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_dragOffset.dx.abs() > screenWidth * 0.4 || velocity.abs() > 800) {
      final isRight = _dragOffset.dx > 0;
      
      _handleSwipeBackend(isRight);

      final endX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(endX, _dragOffset.dy), 
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      
      _animController.forward();
    } else {
      _animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut)); 
      
      _animController.forward();
    }
    
    setState(() => _isDragging = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: _buildCustomAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: index < _profiles.length 
                        ? _buildCardStack() 
                        : _buildEmptyState(), 
                  ),
                ),
                
                if (index < _profiles.length)
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

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: "KU", style: TextStyle(color: Colors.green, fontSize: 34, fontWeight: FontWeight.bold)),
                TextSpan(text: "pid", style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
          
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.favorite, color: Colors.red, size: 22),
         
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.grey),
          onPressed: () {}, 
        )
      ],
      automaticallyImplyLeading: false
    );
  }

  // ✅ แก้ไขส่วนนี้: เพิ่ม onTap ให้กดไปหน้า Detail ได้
  Widget _buildCardStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // การ์ดใบที่ 2 (รองพื้น)
            if (index + 1 < _profiles.length) 
              Transform.scale(
                scale: 0.95, 
                child: Transform.translate(
                  offset: const Offset(0, 10), 
                  child: Opacity(
                    opacity: 0.6, 
                    child: ProfileCard(profileData: _profiles[index + 1]), 
                  ),
                ),
              ),

            // การ์ดใบที่ 1 (ตัวที่ปัดได้)
            GestureDetector(
              // ✅ เพิ่ม onTap: แตะเพื่อดูรายละเอียด
              onTap: () async {
                setState(() => _isDragging = false); // หยุด Drag ชั่วคราว
                
                // ไปหน้า Detail และรอผลลัพธ์
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileDetailPage(
                      profileData: _profiles[index],
                    ),
                  ),
                );

                // ถ้ากดปุ่ม Like/Nope กลับมาจากหน้า Detail
                if (result == true) _buttonSwipe(true);
                if (result == false) _buttonSwipe(false);
              },

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
                  final offset = _animController.isAnimating ? _animation.value : _dragOffset;
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
                            ProfileCard(profileData: _profiles[index]), 
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

  Widget _buildStatusOverlay(double dx) {
    if (dx == 0) return const SizedBox.shrink();

    final isLike = dx > 0;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), 
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
              setState(() {
                index = 0;
              });
              _loadProfiles(); 
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