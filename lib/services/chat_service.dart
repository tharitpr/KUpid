import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. ดึงรายชื่อห้องแชท (Matches) ทั้งหมด
  Stream<QuerySnapshot> getChatRooms() {
    String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('matches')
        .where('users', arrayContains: currentUserId) // หาห้องที่มีเรา
        // .orderBy('lastMessageTime', descending: true) // (ถ้า Error Index ให้ปิดบรรทัดนี้ไปก่อน)
        .snapshots();
  }

  // 2. ดึงข้อความในห้องแชท
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('matches')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) 
        .snapshots();
  }

  // 3. ส่งข้อความ (หัวใจสำคัญ!)
  Future<void> sendMessage(String chatId, String message) async {
    String currentUserId = _auth.currentUser!.uid;

    // 3.1 บันทึกข้อความลงประวัติ
    await _firestore
        .collection('matches')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 3.2 อัปเดตหน้าห้อง (เพื่อให้ Chat List รู้ว่าคุยกันแล้ว)
    await _firestore.collection('matches').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
  
  // Helper: ดึงชื่อและรูปเพื่อน
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      var doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
       return null;
    }
  }
}