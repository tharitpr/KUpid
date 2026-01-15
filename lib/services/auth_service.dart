import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instance ของ Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Sign Up (สมัครสมาชิก)
  Future<User?> signUp(String email, String password, String name, String faculty) async {
    try {
      // 1. สร้าง User ใน Authentication Service
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      // 2. บันทึกข้อมูล Profile ลง Firestore (ทำรอบเดียวพอครับ)
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': name,
          'faculty': faculty,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // เก็บแค่เวลาที่สมัคร
          'photoUrl': "", // รูปว่างไว้ก่อน
          // ตัดส่วน last_login และ isOnline ออกตามที่ต้องการครับ
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Auth Error: ${e.message}");
      return null;
    }
  }

  // 2. Sign In (เข้าสู่ระบบ)
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 3. Sign Out (ออกจากระบบ)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. Get Current User (เช็คว่าใครล็อกอินอยู่)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}