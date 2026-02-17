import 'dart:math';

class MatchingAlgorithmService {
  
  // ฟังก์ชันหลัก: เรียงลำดับผู้ใช้ตามความเหมาะสม (Compatibility Score)
    List<Map<String, dynamic>> sortUsersByCompatibility({
      required Map<String, dynamic> myProfile, 
      required List<Map<String, dynamic>> otherUsers
    }) {
      for (var user in otherUsers) {
        // เปลี่ยนมาใช้การคำนวณแบบใหม่ที่ให้ผลลัพธ์เป็น 0-100%
        double score = _calculateJaccardBoostScore(myProfile, user);
        user['matchScore'] = score.round(); 
      }

      otherUsers.sort((a, b) {
        int scoreA = a['matchScore'] ?? 0;
        int scoreB = b['matchScore'] ?? 0;
        return scoreB.compareTo(scoreA);
      });

      return otherUsers;
    }

    // ฟังก์ชันย่อย: คำนวณคะแนนด้วยหลักการ Jaccard + Boosting
    double _calculateJaccardBoostScore(Map<String, dynamic> me, Map<String, dynamic> other) {
      
      // 1. คำนวณค่าความคล้ายคลึงพื้นฐาน (Jaccard Index: Intersection / Union)
      double rawInterestIdx = _getJaccardIndex(me['interests'] ?? [], other['interests'] ?? []);
      double rawActivityIdx = _getJaccardIndex(me['joinedActivities'] ?? [], other['joinedActivities'] ?? []);

      // หากไม่มีอะไรตรงกันเลย ให้ 0 ทันที
      if (rawInterestIdx == 0 && rawActivityIdx == 0) return 0.0;

      // ---------------------------------------------------------
      // หลักการ Scale คะแนนให้สูง (The 80% Target Strategy)
      // ---------------------------------------------------------
      
      // A. Base Score (คะแนนฐาน): ทันทีที่มีจุดร่วม เราให้ "แต้มเปิดใจ" ก่อนเลย 45 คะแนน
      // เพื่อให้คะแนนไม่ดูน้อยเกินไปจนผู้ใช้เสียความรู้สึก
      double score = 45.0;

      // B. Interest Boost (น้ำหนัก 35%): 
      // ใช้ sqrt() เพื่อดึงค่าที่น้อยให้สูงขึ้น เช่น 0.2 (20%) จะกลายเป็น 0.44 (44%)
      // แล้วคูณด้วยน้ำหนัก 35 คะแนน
      score += (sqrt(rawInterestIdx) * 35);

      // C. Activity Boost (น้ำหนัก 10%):
      score += (sqrt(rawActivityIdx) * 10);

      // D. Community Bonus (10%): 
      // ถ้าอยู่คณะเดียวกันหรือปีเดียวกัน ให้คะแนนส่วนนี้เพิ่มเข้าไปตรงๆ
      if (me['faculty'] != null && me['faculty'] != "" && me['faculty'] == other['faculty']) {
        score += 7.0; // คณะเดียวกันได้ 7%
      }
      if (me['year'] != null && me['year'] != "" && me['year'] == other['year']) {
        score += 3.0; // ปีเดียวกันได้ 3%
      }

      // จำกัดผลลัพธ์ไม่ให้เกิน 100
      return score.clamp(0.0, 100.0);
    }

    // ฟังก์ชันคำนวณสัดส่วน Jaccard (เป็นมาตรฐานสากล)
    double _getJaccardIndex(List listA, List listB) {
      if (listA.isEmpty || listB.isEmpty) return 0.0;
      
      final setA = listA.toSet();
      final setB = listB.toSet();
      
      final intersection = setA.intersection(setB).length;
      final union = setA.union(setB).length;
      
      return intersection / union; 
    }
  }