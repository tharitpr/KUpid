// lib/screens/swipe_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/profile_card.dart';
import '../widgets/swipe_buttons.dart';
import '../services/user_service.dart';
import '../services/match_service.dart'; // Import MatchService
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_page.dart';

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
              // ต้องแน่ใจว่ามี uid หรือ id ส่งมาด้วย (จาก UserService)
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
          print("Error loading profiles: $e");
          setState(() => _isLoading = false);
        }
      }

      // --- 2. ฟังก์ชันจัดการ Backend (บันทึก Like/Pass) ---
      void _handleSwipeBackend(bool isLike) async {
        if (index >= _profiles.length) return;

        // ดึงข้อมูลคนที่เราเพิ่งปัด
        var targetUser = _profiles[index];
        String targetUserId = targetUser['uid']; // ID ของคนที่เราปัด

        if (targetUserId.isEmpty) {
          print("Error: No User ID found");
          return;
        }

        if (isLike) {
          print("❤️ Liking ${targetUser['name']}...");
          // เรียก Service ปัดขวา
          bool isMatch = await _matchService.swipeRight(targetUserId, targetUser['name']);
          
          if (isMatch && mounted) {
            // 🎉 MATCHED! โชว์ Dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("It's a Match! 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("คุณและเขาใจตรงกัน!"),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(targetUser['image']),
                    ),
                    const SizedBox(height: 10),
                    Text("Say hi to ${targetUser['name']}!"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Keep Swiping", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      Navigator.pop(context);
                  String myId = FirebaseAuth.instance.currentUser!.uid;
                      String partnerId = targetUserId;
                      String chatId = myId.compareTo(partnerId) < 0 ? "${myId}_$partnerId" : "${partnerId}_$myId";

                      // 2. เด้งไปหน้า ChatRoom
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
                    child: const Text("Send Message", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        } else {
          print("👎 Passing ${targetUser['name']}");
          // เรียก Service ปัดซ้าย
          await _matchService.swipeLeft(targetUserId);
        }
      }

      @override
      void dispose() {
        _animController.dispose();
        super.dispose();
      }

      // --- 3. ฟังก์ชัน Swipe ด้วยปุ่ม ---
      void _buttonSwipe(bool isRight) {
        if (index >= _profiles.length) return; 
        
        // เรียก Backend ทันทีที่กดปุ่ม
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

        // ถ้าลากเกินครึ่งจอ หรือ ปัดเร็วๆ
        if (_dragOffset.dx.abs() > screenWidth * 0.4 || velocity.abs() > 800) {
          final isRight = _dragOffset.dx > 0;
          
          // เรียก Backend ทันทีที่ปล่อยมือและคอนเฟิร์มการปัด
          _handleSwipeBackend(isRight);

          final endX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

          _animation = Tween<Offset>(
            begin: _dragOffset,
            end: Offset(endX, _dragOffset.dy), 
          ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
          
          _animController.forward();
        } else {
          // เด้งกลับ (ไม่ต้องเรียก Backend)
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
              onPressed: () {}, 
            )
          ],
        );
      }

      Widget _buildCardStack() {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
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