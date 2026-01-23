import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter สำหรับดึง Auth (เผื่อหน้าอื่นเรียกใช้)
  FirebaseAuth get auth => _auth;

  // ฟังก์ชัน: ปัดขวา (Like)
  Future<bool> swipeRight(String targetUserId, String targetName) async {
    String currentUserId = _auth.currentUser!.uid;

    debugPrint("🔍 CHECKING MATCH...");
    debugPrint("👉 Me ($currentUserId) LIKE -> Them ($targetUserId)");

    try {
      // 1. บันทึกว่าเราชอบเขา
      await _firestore.collection('swipes').add({
        'from': currentUserId,
        'to': targetUserId,
        'targetName_DEBUG': targetName, // ใส่ชื่อไว้ดูง่ายๆ
        'type': 'like',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Recorded my swipe in DB");

      // 2. เช็คว่าเขาเคยชอบเราไหม?
      // (ค้นหาใน swipes ว่ามี document ไหนไหมที่ from=เขา, to=เรา, type=like)
      var checkSnapshot = await _firestore
          .collection('swipes')
          .where('from', isEqualTo: targetUserId)
          .where('to', isEqualTo: currentUserId)
          .where('type', isEqualTo: 'like')
          .get();

      debugPrint("🔎 Query Result: Found ${checkSnapshot.docs.length} documents");

      if (checkSnapshot.docs.isNotEmpty) {
        // --- 🎉 JACKPOT! เจอข้อมูลว่าเขาชอบเรา ---
        debugPrint("🎉 IT'S A MATCH! Creating chat room...");
        
        await _createMatch(currentUserId, targetUserId);
        return true; // Match!
      } else {
        debugPrint("❄️ No match yet. They haven't liked you (or Cheat Code didn't run for this user).");
        return false; // Not match
      }
    } catch (e) {
      debugPrint("❌ Error swipe right: $e");
      return false;
    }
  }

  // ฟังก์ชัน: ปัดซ้าย (Pass)
  Future<void> swipeLeft(String targetUserId) async {
    String currentUserId = _auth.currentUser!.uid;
    await _firestore.collection('swipes').add({
      'from': currentUserId,
      'to': targetUserId,
      'type': 'pass',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ฟังก์ชันสร้างห้องแชท
  Future<void> _createMatch(String user1, String user2) async {
    try {
      // สร้าง ID ห้อง (เรียงตามตัวอักษร เพื่อให้ user1_user2 กับ user2_user1 ได้ ID เดียวกัน)
      String chatId = user1.compareTo(user2) < 0 ? "${user1}_$user2" : "${user2}_$user1";

      await _firestore.collection('matches').doc(chatId).set({
        'users': [user1, user2], // Array นี้สำคัญมาก หน้า ChatList ใช้หาห้อง
        'matchedAt': FieldValue.serverTimestamp(),
        'lastMessage': "New Match! Say Hi 👋",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Created/Updated match room: matches/$chatId");
    } catch (e) {
      debugPrint("❌ Error creating match room: $e");
    }
  }

  // ดึงรายชื่อห้องแชท
  Stream<QuerySnapshot> getMatches() {
    String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        // .orderBy('lastMessageTime', descending: true) // ถ้า Error Index ให้คอมเมนต์บรรทัดนี้ออกก่อน
        .snapshots();
  }
  
  // Helper: ดึง User Profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      var doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }
}