import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // --- Mock Data: เพิ่ม field 'description' เพื่อใช้โชว์ใน popup ---
  final List<Map<String, String>> activities = [
    {
      "title": "KU Fair 2026",
      "date": "Feb 2-10, 2026",
      "location": "Kasetsart University Campus",
      "image": "https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop",
      "category": "Festival",
      "description": "The biggest festival of the year! Meet 500+ vendors, food stalls, and enjoy concerts by famous artists. Perfect for networking and experiencing campus life!"
    },
    {
      "title": "Engineering Open House",
      "date": "Mar 15, 2026 | 09:00 - 16:00",
      "location": "Engineering Building",
      "image": "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=2070&auto=format&fit=crop",
      "category": "Academic",
      "description": "Welcome to the Engineering Faculty! Tour our state-of-the-art laboratories, meet senior students, and explore exciting AI robotics projects."
    },
    {
      "title": "Freshy Night Music Festival",
      "date": "Mar 20, 2026 | 18:00 onwards",
      "location": "University Stadium",
      "image": "https://images.unsplash.com/photo-1459749411177-0473ef716175?q=80&w=2070&auto=format&fit=crop",
      "category": "Concert",
      "description": "Amazing welcome concert for freshmen! Get ready to dance with famous bands and musicians. This is the event of the year!"
    },
    {
      "title": "KU Run - Campus Run",
      "date": "Apr 1, 2026 | 05:00 AM",
      "location": "Around Campus",
      "image": "https://images.unsplash.com/photo-1552674605-46d50402f181?q=80&w=2070&auto=format&fit=crop",
      "category": "Sports",
      "description": "Run for health around the beautiful campus! Choose 5km or 10km routes. Part of the proceeds support scholarships for students in need."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          "University Activities",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final item = activities[index];
            return ActivityCard(item: item);
          },
        ),
      ),
    );
  }
}

// --- Widget แยก: การ์ดกิจกรรม ---
class ActivityCard extends StatelessWidget {
  final Map<String, String> item;

  const ActivityCard({super.key, required this.item});

  // --- ฟังก์ชันแสดง Pop-up (Modal Bottom Sheet) ---
  void _showActivityDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ให้ขยายเต็มจอได้ถ้ายาว
      backgroundColor: Colors.transparent, // เพื่อให้เห็นมุมโค้ง
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, // สูง 85% ของหน้าจอ
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // 1. Header Image + Close Button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    child: Image.network(
                      item["image"]!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Content Details (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item["category"]!,
                          style: const TextStyle(
                            color: Color(0xFF1DB954),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Title
                      Text(
                        item["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C2F1C),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Rows
                      _buildInfoRow(Icons.calendar_month, item["date"]!),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, item["location"]!),
                      
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        "รายละเอียดกิจกรรม",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item["description"] ?? "ไม่มีรายละเอียดเพิ่มเติม", // ใช้ข้อมูลใหม่
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                      ),
                      const SizedBox(height: 80), // เผื่อที่ให้ปุ่มด้านล่าง
                    ],
                  ),
                ),
              ),

              // 3. Fixed Join Button at Bottom
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // ปิด popup
                      // Show Success Message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 10),
                              Text("ลงทะเบียนเข้าร่วม '${item['title']}' สำเร็จ!"),
                            ],
                          ),
                          backgroundColor: const Color(0xFF1DB954),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "ยืนยันการเข้าร่วม",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ส่วนรูปภาพ
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item["image"]!,
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
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item["category"]!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C2F1C)),
                  ),
                ),
              ),
            ],
          ),

          // 2. ส่วนเนื้อหาการ์ด (ย่อ)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"]!,
                  maxLines: 1, // ตัดคำถ้ายาวเกิน
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C2F1C)),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.calendar_month, item["date"]!),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.location_on, item["location"]!),
                
                const SizedBox(height: 16),
                
                // ปุ่มดูรายละเอียด (กดแล้วเรียกฟังก์ชัน popup)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton( // เปลี่ยนเป็น Outlined เพื่อให้ดูเบากว่าปุ่ม Join ใน Popup
                    onPressed: () => _showActivityDetail(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1DB954), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "ดูรายละเอียด",
                      style: TextStyle(color: Color(0xFF1DB954), fontSize: 16, fontWeight: FontWeight.bold),
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