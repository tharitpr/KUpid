// lib/screens/my_profile_preview_page.dart

import 'package:flutter/material.dart';

class MyProfilePreviewPage extends StatelessWidget {
  // รับข้อมูลแบบ Map เหมือนเดิม เพื่อความง่ายในการส่งต่อ
  final Map<String, dynamic> profileData;

  const MyProfilePreviewPage({super.key, required this.profileData});

  // ฟังก์ชันดูรูปเต็มจอ
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
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white),
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
    // แกะข้อมูล
    final String imageUrl = profileData['image'] ?? profileData['photoUrl'] ?? "";
    final String name = profileData['name'] ?? "Unknown";
    final String year = profileData['year'] ?? "";
    final String displayYear = year.isNotEmpty ? ", $year" : "";
    final String faculty = profileData['faculty'] ?? "Kasetsart University";
    final String bio = profileData['bio'] ?? "No bio available.";
    
    final List<dynamic> joinedActivities = profileData['joinedActivities'] ?? [];
    final List<dynamic> interests = profileData['interests'] ?? [];
    final List<dynamic> galleryPhotos = profileData['galleryPhotos'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            pinned: true,
            backgroundColor: const Color(0xFF006400),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty 
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                  )
                : Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 80, color: Colors.grey)),
            ),
          ),

          // 2. เนื้อหา (ไม่มีปุ่ม Like/Nope)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อ
                  Text(
                    "$name$displayYear", 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  
                  // คณะ
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(faculty, style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                      ),
                    ],
                  ),
                  
                  // Activities
                  if (joinedActivities.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006400).withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF006400).withValues(alpha: .3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Joined Activities:", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: joinedActivities.map((activity) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFF006400), borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.event, color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text("$activity", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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

                  // Bio
                  const Text("About Me", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(bio, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5)),

                  const SizedBox(height: 24),

                  // Interests
                  if (interests.isNotEmpty) ...[
                    const Text("Interests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: interests.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006400).withValues(alpha: .05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF006400).withValues(alpha: .1)),
                          ),
                          child: Text("$tag", style: const TextStyle(color: Color(0xFF006400), fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Gallery
                  if (galleryPhotos.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 24),
                    const Text("Gallery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
                      ),
                      itemCount: galleryPhotos.length,
                      itemBuilder: (context, index) {
                        String imgUrl = galleryPhotos[index];
                        return GestureDetector(
                          onTap: () => _openFullScreenImage(context, imgUrl),
                          child: Hero(
                            tag: imgUrl,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200])),
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
    );
  }
}