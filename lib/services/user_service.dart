import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ฟังก์ชันเสกคนทิพย์ (Mock Data)
  Future<void> generateMockUsers() async {
    // ข้อมูลจำลอง (ชื่อ, คณะ, รูป)
    List<Map<String, dynamic>> mockUsers = [
      {
        'name': 'Namfah',
        'faculty': 'Humanities',
        'bio': 'Love singing and cat person 🐱',
        'photoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        'interests': ['Music', 'Cats', 'Travel'],
      },
      {
        'name': 'James',
        'faculty': 'Engineering',
        'bio': 'Coding all night, sleeping all day ☕',
        'photoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
        'interests': ['Coding', 'Gaming', 'Coffee'],
      },
      {
        'name': 'Mint',
        'faculty': 'Economics',
        'bio': 'Looking for study buddy 📚',
        'photoUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        'interests': ['Reading', 'Investing', 'Badminton'],
      },
      {
        'name': 'Ball',
        'faculty': 'Agriculture',
        'bio': 'Nature lover 🌿',
        'photoUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
        'interests': ['Hiking', 'Plants', 'Photography'],
      },
      {
        'name': 'Ploy',
        'faculty': 'Business',
        'bio': 'Foodie & Traveler 🍜✈️',
        'photoUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        'interests': ['Food', 'Travel', 'Fashion'],
      },
    ];

    // วนลูปยิงข้อมูลเข้า Firebase
    for (var user in mockUsers) {
      // สร้าง ID อัตโนมัติ
      await _firestore.collection('users').add({
        ...user, // กระจายข้อมูล name, faculty, etc.
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': false,
        'id': '' // เดี๋ยวค่อยมาแก้ หรือปล่อยว่างไว้ก่อนก็ได้ เพราะ Firestore มี documentID อยู่แล้ว
      });
    }
    debugPrint("✅ เสกคนทิพย์เรียบร้อย 5 คน!");
  }

  // [CHEAT CODE] สั่งให้ Mock User ทุกคนในระบบ "ชอบเรา"
  Future<void> cheatMakeEveryoneLikeMe() async {
    String myId = _auth.currentUser!.uid;

    try {
      // 1. ดึง Mock User ทั้งหมดออกมา
      var usersSnapshot = await _firestore.collection('users').get();

      for (var doc in usersSnapshot.docs) {
        String mockUserId = doc.id;
        
        // ข้ามตัวเอง
        if (mockUserId == myId) continue;

        // 2. สร้างข้อมูลว่า "Mock User คนนี้ ชอบ เรา"
        await _firestore.collection('swipes').add({
          'from': mockUserId, // จาก: Mock User
          'to': myId,         // ถึง: ตัวเรา
          'type': 'like',
          'timestamp': FieldValue.serverTimestamp(),
          'targetName_DEBUG': 'ME (Force Like)', // ใส่ไว้ให้รู้ว่าโกงมา 555
        });
        
        debugPrint("✅ บังคับให้ ${doc['name']} ชอบเราแล้ว!");
      }
    } catch (e) {
      debugPrint("Cheat Error: $e");
    }
  }
  
  Future<List<Map<String, dynamic>>> getUsersToSwipe() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;

      // ดึงข้อมูลทั้งหมดจาก Collection 'users'
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      // กรองข้อมูล: เอาทุกคนที่ไม่ใช่ตัวเราเอง
      List<Map<String, dynamic>> users = snapshot.docs
          .where((doc) => doc.id != currentUserId) // ตัดตัวเราออก
          .map((doc) {
            // แปลงข้อมูลเป็น Map และยัด ID ใส่เข้าไปด้วย (เผื่อต้องใช้ตอนกด Like)
            var data = doc.data() as Map<String, dynamic>;
            data['uid'] = doc.id; 
            return data;
          })
          .toList();

      return users;
    } catch (e) {
        debugPrint("Error fetching users: $e");
      return [];
    }
  }
}

