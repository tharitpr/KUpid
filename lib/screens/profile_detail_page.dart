import 'package:flutter/material.dart';

class ProfileDetailPage extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileDetailPage({super.key, required this.profileData});

  // ฟังก์ชันสำหรับเปิดดูรูปเต็มจอ (พร้อมซูมได้)
  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (c, e, s) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      Text("Image failed", style: TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // เตรียมข้อมูล
    final String imageUrl = profileData['image'] ?? "";
    final String name = profileData['name'] ?? "Unknown";
    
    // ✅ เปลี่ยนจาก Age เป็น Year
    final String year = profileData['year'] ?? "";
    final String displayYear = year.isNotEmpty ? ", $year" : "";

    final String faculty = profileData['faculty'] ?? "Kasetsart University";
    final String bio = profileData['bio'] ?? "No bio available.";
    
    // ✅ ดึงข้อมูลกิจกรรม
    final List<dynamic> joinedActivities = profileData['joinedActivities'] ?? [];

    final List<dynamic> interests = profileData['interests'] ?? [];
    final List<dynamic> galleryPhotos = profileData['galleryPhotos'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. รูปภาพปกเต็มจอ (SliverAppBar)
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                pinned: true,
                backgroundColor: const Color(0xFF006400),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'profile_image_${profileData['uid'] ?? name}',
                    child: imageUrl.isNotEmpty 
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                          ),
                        )
                      : Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 80, color: Colors.grey)),
                  ),
                ),
              ),

              // 2. เนื้อหาข้อมูลด้านล่าง
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120), // เว้นที่ล่างเผื่อปุ่ม
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อและชั้นปี
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "$name$displayYear", // ✅ แสดงชั้นปี
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: Colors.blueAccent, size: 28),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // คณะ
                      Row(
                        children: [
                          Icon(Icons.school, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              faculty,
                              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                      
                      // ✅ แสดงกิจกรรมที่กำลังเข้าร่วม (เด่นชัดกว่า Card เล็กน้อย)
                      if (joinedActivities.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006400).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF006400).withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Event Schedule (กิจกรรมที่เข้าร่วม):",
                                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              // ใช้ Wrap เพื่อปูเรียงกันสวยๆ
                              Wrap(
                                spacing: 8, // ระยะห่างแนวนอน
                                runSpacing: 8, // ระยะห่างแนวตั้ง
                                children: joinedActivities.map((activity) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006400),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.event, color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          "$activity",
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // About Me
                      const Text("About Me", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        bio,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Interests
                      if (interests.isNotEmpty) ...[
                        const Text("Interests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: interests.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006400).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF006400).withOpacity(0.1)),
                              ),
                              child: Text(
                                "$tag",
                                style: const TextStyle(color: Color(0xFF006400), fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // GALLERY SECTION
                      if (galleryPhotos.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text("Gallery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: Text("${galleryPhotos.length}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Grid แสดงรูป
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, 
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1, 
                          ),
                          itemCount: galleryPhotos.length,
                          itemBuilder: (context, index) {
                            String imgUrl = galleryPhotos[index];
                            return GestureDetector(
                              onTap: () => _openFullScreenImage(context, imgUrl),
                              child: Hero(
                                tag: imgUrl,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[100], // พื้นหลังรูป
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                      loadingBuilder: (c, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. ปุ่ม NOPE / LIKE แบบเดิม
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ปุ่ม NOPE
                FloatingActionButton.extended(
                  heroTag: "nope_btn",
                  backgroundColor: Colors.white,
                  elevation: 5,
                  onPressed: () => Navigator.pop(context, false), // ส่งค่า false (ไม่ชอบ)
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text("NOPE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                
                const SizedBox(width: 20),
                
                // ปุ่ม LIKE
                FloatingActionButton.extended(
                  heroTag: "like_btn",
                  backgroundColor: const Color(0xFF006400),
                  elevation: 5,
                  onPressed: () => Navigator.pop(context, true), // ส่งค่า true (ชอบ)
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text("LIKE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}