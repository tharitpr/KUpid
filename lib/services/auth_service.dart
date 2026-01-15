import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ใช้บันทึกข้อมูลเบื้องต้น

class AuthService {
  // Instance ของ Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Sign Up (สมัครสมาชิก)
  Future<User?> signUp(String email, String password, String name, String faculty) async {
    try {
      // สร้าง User ใน Authentication Service
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // อัปเดตเวลา Login ล่าสุดลงใน Database (Collection 'users')
        await _firestore.collection('users').doc(result.user!.uid).update({
          'last_login': FieldValue.serverTimestamp(), // เวลาปัจจุบันของ Server
          'isOnline': true,
        });
      }
      
      User? user = result.user;

      // *สำคัญ* : พอสมัครเสร็จ เราต้องสร้างข้อมูลใน User Service (Firestore) ทันที
      // นี่คือจุดเชื่อมต่อระหว่าง Auth Service -> User Service
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': name,
          'faculty': faculty,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': "", // ไว้ค่อยมาใส่รูปทีหลัง
          'isOnline': true,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Auth Error: ${e.message}");
      return null; // หรือจะ throw error ออกไปจัดการที่ UI ก็ได้
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