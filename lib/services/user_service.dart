import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ฟังก์ชันเสกคนทิพย์ (Mock Data)
  Future<void> generateMockUsers() async {
    // ข้อมูลจำลอง (ชื่อ, คณะ, รูป, เพศ, อายุ, และรูป Gallery เพิ่มเติม)
    List<Map<String, dynamic>> mockUsers = [
      {
        'name': 'Namfah',
        'faculty': 'Humanities',
        'gender': 'Female',
        'age': 20,
        'bio': 'Love singing and cat person 🐱',
        'photoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        'interests': ['Music', 'Cats', 'Travel'],
        'galleryPhotos': [
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=400&q=80', // แมว
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=400&q=80', // คาเฟ่
          'https://images.unsplash.com/photo-1516280440614-6697288d5d38?auto=format&fit=crop&w=400&q=80', // ปาร์ตี้
        ]
      },
      {
        'name': 'James',
        'faculty': 'Engineering',
        'gender': 'Male',
        'age': 21,
        'bio': 'Coding all night, sleeping all day ☕',
        'photoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
        'interests': ['Coding', 'Gaming', 'Coffee'],
        'galleryPhotos': [
          'https://images.unsplash.com/photo-1587620962725-abab7fe55159?auto=format&fit=crop&w=400&q=80', // โต๊ะคอม
          'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&w=400&q=80', // กาแฟ
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=400&q=80', // เกม
        ]
      },
      {
        'name': 'Mint',
        'faculty': 'Economics',
        'gender': 'Female',
        'age': 22,
        'bio': 'Looking for study buddy 📚',
        'photoUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        'interests': ['Reading', 'Investing', 'Badminton'],
        'galleryPhotos': [
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80', // หนังสือ
          'https://images.unsplash.com/photo-1626224583764-84786c719718?auto=format&fit=crop&w=400&q=80', // แบดมินตัน
          'https://images.unsplash.com/photo-1553729459-efe14ef6055d?auto=format&fit=crop&w=400&q=80', // การเงิน
        ]
      },
      {
        'name': 'Ball',
        'faculty': 'Agriculture',
        'gender': 'Male',
        'age': 20,
        'bio': 'Nature lover 🌿',
        'photoUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
        'interests': ['Hiking', 'Plants', 'Photography'],
        'galleryPhotos': [
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=400&q=80', // ภูเขา
          'https://images.unsplash.com/photo-1501555088652-021faa106b9b?auto=format&fit=crop&w=400&q=80', // เดินป่า
          'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?auto=format&fit=crop&w=400&q=80', // ต้นไม้
        ]
      },
      {
        'name': 'Ploy',
        'faculty': 'Business',
        'gender': 'Female',
        'age': 21,
        'bio': 'Foodie & Traveler 🍜✈️',
        'photoUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        'interests': ['Food', 'Travel', 'Fashion'],
        'galleryPhotos': [
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80', // อาหาร
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=400&q=80', // ท่องเที่ยว
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=400&q=80', // แฟชั่น
        ]
      },
      {
        'name': 'Alex',
        'faculty': 'Arts',
        'gender': 'LGBTQ+',
        'age': 19,
        'bio': 'Fashion design student & Art lover 🎨',
        'photoUrl': 'https://images.unsplash.com/photo-1517070208541-6ddc4d3efbcb?auto=format&fit=crop&w=400&q=80',
        'interests': ['Art', 'Fashion', 'Museum'],
        'galleryPhotos': [
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&w=400&q=80', // งานศิลปะ
          'https://images.unsplash.com/photo-1529139574466-a302d2052574?auto=format&fit=crop&w=400&q=80', // ถ่ายแบบ
          'https://images.unsplash.com/photo-1518998053901-5348d3969105?auto=format&fit=crop&w=400&q=80', // แกลเลอรี่
        ]
      },
    ];

    // วนลูปยิงข้อมูลเข้า Firebase
    for (var user in mockUsers) {
        await _firestore.collection('users').add({
          ...user, // กระจายข้อมูล name, faculty, gender, age, galleryPhotos, etc.
          'createdAt': FieldValue.serverTimestamp(),
          'isOnline': false,
          'id': '' 
        });
      }
      debugPrint("✅ เสกคนทิพย์เรียบร้อย 6 คน (พร้อมรูป Gallery)!");
    }

    // [CHEAT CODE] สั่งให้ Mock User ทุกคนในระบบ "ชอบเรา"
    Future<void> cheatMakeEveryoneLikeMe() async {
      String myId = _auth.currentUser!.uid;

      try {
        var usersSnapshot = await _firestore.collection('users').get();

        for (var doc in usersSnapshot.docs) {
          String mockUserId = doc.id;
          
          if (mockUserId == myId) continue;

          await _firestore.collection('swipes').add({
            'from': mockUserId, 
            'to': myId,         
            'type': 'like',
            'timestamp': FieldValue.serverTimestamp(),
            'targetName_DEBUG': 'ME (Force Like)', 
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

        QuerySnapshot snapshot = await _firestore.collection('users').get();

        List<Map<String, dynamic>> users = snapshot.docs
            .where((doc) => doc.id != currentUserId) 
            .map((doc) {
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