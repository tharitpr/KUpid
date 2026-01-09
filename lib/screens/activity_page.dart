import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // --- Mock Data: ข้อมูลจำลองกิจกรรม (ในอนาคตดึงจาก Backend) ---
  final List<Map<String, String>> activities = [
    {
      "title": "KU Fair 2026 : เกษตรแฟร์",
      "date": "2 - 10 กุมภาพันธ์ 2026",
      "location": "มหาวิทยาลัยเกษตรศาสตร์ บางเขน",
      "image": "https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop", // รูปตัวอย่าง
      "category": "Festival"
    },
    {
      "title": "Engineering Open House",
      "date": "15 มีนาคม 2026 | 09:00 - 16:00",
      "location": "อาคารชูชาติ กำภู (คณะวิศวะ)",
      "image": "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=2070&auto=format&fit=crop",
      "category": "Academic"
    },
    {
      "title": "Freshy Night Music Festival",
      "date": "20 มีนาคม 2026 | 18:00 เป็นต้นไป",
      "location": "สนามอินทรีจันทรสถิตย์",
      "image": "https://images.unsplash.com/photo-1459749411177-0473ef716175?q=80&w=2070&auto=format&fit=crop",
      "category": "Concert"
    },
    {
      "title": "KU Run วิ่งลั่นทุ่ง",
      "date": "1 เมษายน 2026 | 05:00 น.",
      "location": "รอบมหาวิทยาลัย",
      "image": "https://images.unsplash.com/photo-1552674605-46d50402f181?q=80&w=2070&auto=format&fit=crop",
      "category": "Sports"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // พื้นหลังสีเทาอ่อนให้การ์ดเด่นขึ้น
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF), // สีเขียวเกษตร
        title: const Text(
          "University Activities",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // เอาลูกศรย้อนกลับออก (เพราะอยู่ใน MainLayout)
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
          // 1. ส่วนรูปภาพ (Image Header)
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
              // Tag หมวดหมู่มุมขวาบน
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
                    item["category"]!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C2F1C),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. ส่วนเนื้อหา (Content)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อกิจกรรม
                Text(
                  item["title"]!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C2F1C),
                  ),
                ),
                const SizedBox(height: 10),
                
                // วันที่
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 18, color: Color(0xFF1DB954)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item["date"]!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // สถานที่
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Color(0xFF1DB954)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item["location"]!,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // ปุ่มเข้าร่วม
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action เมื่อกดดูรายละเอียด หรือ เข้าร่วม
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("สนใจกิจกรรม: ${item['title']}")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954), // เขียวเข้ม
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "ดูรายละเอียด",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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