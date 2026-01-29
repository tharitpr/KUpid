// lib/widgets/profile_card.dart

import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileCard({
    super.key,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    // เตรียมข้อมูล
    final String name = profileData['name'] ?? "Unknown";
    final String year = profileData['year'] ?? "";
    final String displayYear = year.isNotEmpty ? ", $year" : "";
    final String faculty = profileData['faculty'] ?? "Kasetsart University";
    final String bio = profileData['bio'] ?? "";
    final String? gender = profileData['gender']; 
    
    // ✅ ดึงคะแนน Match Score ที่คำนวณจาก Algorithm
    final int matchScore = profileData['matchScore'] ?? 0;

    // ดึงข้อมูลกิจกรรม
    final List<dynamic> joinedActivities = profileData['joinedActivities'] ?? [];

    // ดึง Tags
    final List<dynamic> interests = profileData['interests'] ?? ["Music", "Travel", "Cat Lover"]; 

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand, 
          children: [
            // ---------------------------------------------------
            // 1. ส่วนแสดงรูปภาพ
            // ---------------------------------------------------
            Hero(
              tag: 'profile_image_${profileData['uid'] ?? profileData['name']}', 
              child: Image.network(
                profileData['image'] ?? "https://via.placeholder.com/400",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.green,
                    ),
                  );
                },
              ),
            ),

            // ---------------------------------------------------
            // 2. เงาสีดำไล่ระดับ (Gradient Overlay)
            // ---------------------------------------------------
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.9), 
                  ],
                  stops: const [0.0, 0.5, 0.7, 1.0],
                ),
              ),
            ),

            // ---------------------------------------------------
            // ✅ 3. EXPLAINABILITY BADGE (Match Score)
            // ---------------------------------------------------
            if (matchScore > 0)
              Positioned(
                top: 20,
                right: 20,
                child: _buildMatchScoreBadge(matchScore),
              ),

            // ---------------------------------------------------
            // 4. ข้อมูล Text & Tags
            // ---------------------------------------------------
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 4.1 ชื่อ + ชั้นปี + เพศ + ไอคอนยืนยัน
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "$name$displayYear", 
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // ไอคอนเพศ
                      Icon(
                        _getGenderIcon(gender),
                        color: _getGenderColor(gender), 
                        size: 24,
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 5)],
                      ),

                      const SizedBox(width: 8),
                      
                      // Verified Badge
                      const Icon(Icons.verified, color: Colors.blueAccent, size: 24),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 4.2 คณะ
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          faculty,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // 4.3 แสดง Current Activity (ถ้ามี)
                  if (joinedActivities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: joinedActivities.map((activity) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6), 
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006400).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_available, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  "$activity", 
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // 4.4 เส้นคั่น
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(color: Colors.white.withOpacity(0.3), height: 1),
                  ),

                  // 4.5 Interest Tags
                  if (interests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interests.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(
                              "$tag",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // 4.6 Bio
                  if (bio.isNotEmpty)
                    Text(
                      bio,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // Widget: Match Score Badge (Explainability)
  // ---------------------------------------------------
  Widget _buildMatchScoreBadge(int score) {
    Color badgeColor;
    String label;
    IconData icon;

    if (score >= 50) {
      badgeColor = Colors.amber; // ทอง (คะแนนสูงมาก)
      label = "Super Match";
      icon = Icons.star;
    } else if (score >= 30) {
      badgeColor = Colors.lightGreenAccent; // เขียวอ่อน (คะแนนดี)
      label = "High Compatibility";
      icon = Icons.thumb_up;
    } else {
      badgeColor = Colors.white70; // ทั่วไป
      label = "Match Score";
      icon = Icons.insert_chart;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6), // พื้นหลังทึบแสงให้อ่านง่าย
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$score%", 
                style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 14)
              ),
              if(score >= 30) // โชว์ข้อความเฉพาะคะแนนเยอะๆ
              Text(
                label, 
                style: TextStyle(color: badgeColor.withOpacity(0.8), fontSize: 8)
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // Helper Functions
  // ---------------------------------------------------
  IconData _getGenderIcon(String? gender) {
    switch (gender) {
      case 'Male': return Icons.male;
      case 'Female': return Icons.female;
      case 'LGBTQ+': return Icons.transgender; 
      default: return Icons.person; 
    }
  }

  Color _getGenderColor(String? gender) {
    switch (gender) {
      case 'Male': return Colors.blueAccent;
      case 'Female': return Colors.pinkAccent;
      case 'LGBTQ+': return Colors.purpleAccent; 
      default: return Colors.white70;
    }
  }
}