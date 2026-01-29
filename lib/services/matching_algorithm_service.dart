// lib/services/matching_algorithm_service.dart

class MatchingAlgorithmService {
  
  // ฟังก์ชันหลัก: เรียงลำดับผู้ใช้ตามความเหมาะสม (Compatibility Score)
  List<Map<String, dynamic>> sortUsersByCompatibility({
    required Map<String, dynamic> myProfile, 
    required List<Map<String, dynamic>> otherUsers
  }) {
    // 1. วนลูปให้คะแนนทุกคน
    for (var user in otherUsers) {
      int score = _calculateScore(myProfile, user);
      user['matchScore'] = score; // แปะคะแนนไว้ที่ตัว user
    }

    // 2. เรียงลำดับ (คะแนนมาก -> น้อย)
    // ถ้าคะแนนเท่ากัน ให้สุ่มลำดับนิดหน่อยเพื่อความไม่จำเจ
    otherUsers.sort((a, b) {
      int scoreA = a['matchScore'] ?? 0;
      int scoreB = b['matchScore'] ?? 0;
      return scoreB.compareTo(scoreA); // มากไปน้อย
    });

    return otherUsers;
  }

  // ฟังก์ชันย่อย: คำนวณคะแนนความเข้ากันได้
  int _calculateScore(Map<String, dynamic> me, Map<String, dynamic> other) {
    int score = 0;

    // ---------------------------------------------------------
    // 1. INTERESTS (ความสนใจ) - Priority สูงสุด (สำคัญอันดับ 1)
    // ---------------------------------------------------------
    // ให้คะแนนสูงถึง 30 คะแนน ต่อ 1 เรื่องที่ตรงกัน
    List myInterests = me['interests'] ?? [];
    List theirInterests = other['interests'] ?? [];
    
    // หาตัวที่ซ้ำกัน (Intersection)
    var commonInterests = myInterests.toSet().intersection(theirInterests.toSet());
    score += (commonInterests.length * 30); 


    // ---------------------------------------------------------
    // 2. ACTIVITIES (กิจกรรมร่วมกัน) - Priority รองลงมา
    // ---------------------------------------------------------
    // ให้ 20 คะแนน ถ้าเข้าร่วมกิจกรรมเดียวกัน (แสดงว่าว่างตรงกัน/ชอบอะไรคล้ายกัน)
    List myActivities = me['joinedActivities'] ?? [];
    List theirActivities = other['joinedActivities'] ?? [];

    var commonActivities = myActivities.toSet().intersection(theirActivities.toSet());
    score += (commonActivities.length * 20);


    // ---------------------------------------------------------
    // 3. FACULTY (คณะ)
    // ---------------------------------------------------------
    // ให้ 10 คะแนน ถ้าอยู่คณะเดียวกัน (คุยกันง่ายขึ้น)
    String myFaculty = me['faculty'] ?? "";
    String theirFaculty = other['faculty'] ?? "";
    if (myFaculty.isNotEmpty && myFaculty == theirFaculty) {
      score += 10;
    }


    // ---------------------------------------------------------
    // 4. YEAR (ชั้นปี) & AGE (อายุ)
    // ---------------------------------------------------------
    // ให้ 5 คะแนน ถ้าอยู่ปีเดียวกัน
    String myYear = me['year'] ?? "";
    String theirYear = other['year'] ?? "";
    if (myYear.isNotEmpty && myYear == theirYear) {
      score += 5;
    }

    // (แถม) อายุใกล้เคียงกัน (+/- 1 ปี) ให้เพิ่มอีก 3 คะแนน
    // สมมติว่ามี field 'age' หรือคำนวณจากปีเกิด
    // int myAge = int.tryParse(me['age'].toString()) ?? 0;
    // int theirAge = int.tryParse(other['age'].toString()) ?? 0;
    // if (myAge > 0 && theirAge > 0 && (myAge - theirAge).abs() <= 1) {
    //   score += 3;
    // }

    return score;
  }
}