// lib/screens/activity_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'create_activity_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final Color _bgGrey = const Color(0xFFF9FAFB);
  final currentUser = FirebaseAuth.instance.currentUser; // ✅ ดึง User ปัจจุบันมารรอไว้เช็ค

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Activities",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateActivityPage()),
          );
        },
        backgroundColor: const Color(0xFF006400),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Activity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .where('status', isEqualTo: 'approved')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF006400)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("No activities yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          var activities = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              var data = activities[index].data() as Map<String, dynamic>;

              // ✅ 1. เช็คว่า User ปัจจุบันอยู่ใน list participants หรือยัง?
              List<dynamic> participants = data['participants'] ?? [];
              bool isJoined = false;
              if (currentUser != null) {
                // เช็คว่ามี uid ของเราอยู่ใน array หรือไม่
                isJoined = participants.any((p) => p['uid'] == currentUser!.uid);
              }

              Map<String, String> item = {
                "id": activities[index].id,
                "title": data['title'] ?? "Untitled",
                "date": _formatDate(data['dateTime']),
                "location": data['location'] ?? "Unknown",
                "image": data['image'] ?? "https://via.placeholder.com/400",
                "category": data['category'] ?? "General",
                "description": data['description'] ?? "",
                "organization": data['organization'] ?? "",
              };

              // ✅ ส่งสถานะ isJoined ไปที่ Card
              return ActivityCard(item: item, isJoined: isJoined);
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('MMM d, yyyy | HH:mm').format(date);
    }
    return timestamp.toString();
  }
}

// --- ActivityCard ---
class ActivityCard extends StatefulWidget {
  final Map<String, String> item;
  final bool isJoined; // ✅ รับค่าสถานะการเข้าร่วม

  const ActivityCard({
    super.key, 
    required this.item, 
    required this.isJoined // ✅ Required
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _isJoining = false;

  Future<void> _handleJoin(BuildContext context) async {
    setState(() => _isJoining = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      String studentId = userData?['studentId'] ?? "Unknown";
      String gender = userData?['gender'] ?? "Unknown";

      await FirebaseFirestore.instance.collection('activities').doc(widget.item['id']).update({
        'participants': FieldValue.arrayUnion([
          {
            'uid': user.uid,
            'studentId': studentId,
            'gender': gender,
            'joinedAt': Timestamp.now(),
          }
        ])
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'joinedActivities': FieldValue.arrayUnion([widget.item['title']]),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text("ลงทะเบียน '${widget.item['title']}' เรียบร้อย!")),
              ],
            ),
            backgroundColor: const Color(0xFF1DB954),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error joining: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showActivityDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        child: Image.network(
                          widget.item["image"]!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1DB954).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.item["category"]!,
                                  style: const TextStyle(
                                    color: Color(0xFF1DB954),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // ✅ Badge แสดงในหน้า Detail ด้วย ถ้าลงทะเบียนแล้ว
                              if (widget.isJoined)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, size: 16, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text("Registered", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.item["title"]!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C2F1C),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.calendar_month, widget.item["date"]!),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.location_on, widget.item["location"]!),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),
                          const Text(
                            "รายละเอียดกิจกรรม",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.item["description"] ?? "ไม่มีรายละเอียดเพิ่มเติม",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  
                  // ✅ ปุ่มด้านล่าง: เช็คสถานะ isJoined
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        // ⚠️ ถ้า isJoined เป็น true -> ปุ่มกดไม่ได้ (null)
                        onPressed: (widget.isJoined || _isJoining) 
                          ? null 
                          : () {
                              setModalState(() => _isJoining = true);
                              _handleJoin(context).then((_) {
                                if(mounted) setModalState(() => _isJoining = false);
                              });
                            }, 
                        style: ElevatedButton.styleFrom(
                          // เปลี่ยนสีปุ่ม: ถ้าลงแล้วเป็นสีเทา, ถ้ายังเป็นสีเขียว
                          backgroundColor: widget.isJoined ? Colors.grey[300] : const Color(0xFF1DB954),
                          disabledBackgroundColor: Colors.grey[300], // สีตอนกดไม่ได้
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isJoining 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              // เปลี่ยนข้อความตามสถานะ
                              widget.isJoined ? "Registered" : "Confirm Participation",
                              style: TextStyle(
                                color: widget.isJoined ? Colors.grey[600] : Colors.white, 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1DB954), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  widget.item["image"]!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.item["category"]!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C2F1C)),
                  ),
                ),
              ),
              
              // ✅ Badge "Registered" มุมซ้ายบนของการ์ด
              if (widget.isJoined)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green, // พื้นหลังสีเขียวทึบ
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Registered",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item["title"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C2F1C)),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.calendar_month, widget.item["date"]!),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.location_on, widget.item["location"]!),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () => _showActivityDetail(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1DB954), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    // เปลี่ยนข้อความปุ่มหน้าการ์ดด้วยก็ได้ ถ้าต้องการ
                    child: Text(
                      widget.isJoined ? "See Details ( Registered )" : "See Details",
                      style: const TextStyle(color: Color(0xFF1DB954), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}