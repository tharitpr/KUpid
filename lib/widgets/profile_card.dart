  import 'package:flutter/material.dart';

  class ProfileCard extends StatelessWidget {
    final Map<String, dynamic> profileData;

    const ProfileCard({
      super.key,
      required this.profileData,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity,
        height: double.infinity, // ให้เต็มพื้นที่ Stack
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
              // 1. ส่วนแสดงรูปภาพ (ตัวปัญหาที่ต้องแก้)
              Image.network(
                profileData['image'] ?? "https://via.placeholder.com/400", // ดึง URL จาก key 'image'
                fit: BoxFit.cover,
                // เพิ่มตัวกัน Error ถ้ารูปโหลดไม่ได้ให้โชว์สีเทาแทน
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  );
                },
                // เพิ่ม Loading Builder ให้หมุนๆ ระหว่างรอรูป
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),

              // 2. เงาสีดำด้านล่าง (เพื่อให้ตัวหนังสือชัด)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),

              // 3. ข้อมูล Text (ชื่อ, อายุ, คณะ)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profileData['name']}", // ชื่อ
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${profileData['faculty'] ?? 'Kasetsart University'}", // คณะ (ใส่ default ไว้กัน null)
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }