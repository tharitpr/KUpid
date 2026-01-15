import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. ดึงรายชื่อห้องแชท (Matches) ทั้งหมดของเรา
  Stream<QuerySnapshot> getChatRooms() {
    String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('matches')
        .where('users', arrayContains: currentUserId) // หาห้องที่มีเราอยู่
        .orderBy('lastMessageTime', descending: true) // เรียงตามเวลาล่าสุด
        .snapshots();
  }

  // 2. ดึงข้อความในห้องแชท (Messages)
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('matches')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // เอาใหม่สุดขึ้นก่อน
        .snapshots();
  }

  // 3. ส่งข้อความ (Send Message)
  Future<void> sendMessage(String chatId, String message) async {
    String currentUserId = _auth.currentUser!.uid;
    
    try {
      // 3.1 เพิ่มข้อความลงใน Sub-collection 'messages'
      await _firestore
          .collection('matches')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3.2 อัปเดตข้อมูลล่าสุดที่ตัวห้อง (เพื่อให้หน้า List รู้ว่ามีข้อความใหม่)
      await _firestore.collection('matches').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Helper: ดึงข้อมูลคู่สนทนา (User Profile)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      var doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print("Error getting user profile: $e");
      return null;
    }
  }
}