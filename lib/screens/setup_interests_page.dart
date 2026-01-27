import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_layout.dart'; 

class SetupInterestsPage extends StatefulWidget {
  const SetupInterestsPage({super.key});

  @override
  State<SetupInterestsPage> createState() => _SetupInterestsPageState();
}

class _SetupInterestsPageState extends State<SetupInterestsPage> {
  // --- Constants Design ---
  final Color _primaryColor = const Color(0xFF005030); // Deep Green
  final Color _accentColor = const Color(0xFFC5A065); // Gold

  bool _isLoading = false;
  final List<String> _selectedInterests = [];

  // --- รายการความสนใจ ---
  final Map<String, List<String>> _categories = {
    "Sports & Active": [
      "🏸 Badminton", "🏋️ Gym/Fitness", "🏃 Running", "⚽ Football", 
      "🏀 Basketball", "🏊 Swimming", "🛹 Skateboard"
    ],
    "Food & Drink": [
      "🥘 Shabu/Mookrata", "☕ Café Hopping", "🌶️ Mala", "🧋 Bubble Tea", 
      "🍣 Sushi/Omakase", "🍻 Craft Beer/Bar", "🍳 Cooking"
    ],
    "Lifestyle & Hobbies": [
      "✈️ Travel", "📸 Photography", "🎸 Music/Concerts", "🎲 Board Games", 
      "🎮 E-Sports/Gaming", "🎬 Netflix/Movies", "🛍️ Shopping"
    ],
    "Pets": [
      "🐈 Cat Lover", "🐕 Dog Lover", "🐹 Hamster", "🦜 Exotic Pets"
    ],
    "Sub-Culture": [
      "🇰🇷 K-Pop", "🇹🇭 T-Pop", "🎌 Anime/Manga", "🔮 Tarot/Horoscope"
    ],
    "Study & Tech": [
      "💻 Coding", "📈 Investing/Crypto", "📚 Reading", "🗣️ Languages"
    ]
  };

  // --- Logic 1: Toggle Selection ---
  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < 10) { 
          _selectedInterests.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can select up to 10 interests")),
          );
        }
      }
    });
  }

  // --- Logic 2: กด Finish (บันทึกสิ่งที่เลือก) ---
  Future<void> _saveInterests() async {
    // ต้องเลือกอย่างน้อย 3 อย่างถึงจะกด Finish ได้
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least 3 interests")),
      );
      return;
    }
    await _finalizeSetup(saveInterests: true);
  }

  // --- Logic 3: กด Skip (ข้ามไปก่อน) ---
  Future<void> _skipSetup() async {
    // ข้ามไปเลย ไม่บันทึก interests แต่บันทึกว่า setupCompleted แล้ว
    await _finalizeSetup(saveInterests: false);
  }

  // --- ฟังก์ชันกลางสำหรับจบการทำงาน ---
  Future<void> _finalizeSetup({required bool saveInterests}) async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      
      Map<String, dynamic> dataToUpdate = {
        'setupCompleted': true, // ✅ สำคัญ! บอกระบบว่า User คนนี้ Setup เสร็จแล้ว
      };

      if (saveInterests) {
        dataToUpdate['interests'] = _selectedInterests;
      }

      // อัปเดตข้อมูลลง Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update(dataToUpdate);

      if (mounted) {
        // ไปหน้า Main Layout (เข้าแอปจริง)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Your Interests",
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w800, fontSize: 22),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context), 
        ),
        // ✅ เพิ่มปุ่ม Skip ตรงนี้
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _skipSetup,
            child: Text(
              "Skip",
              style: TextStyle(color: _primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar (Page 2 of 2)
          LinearProgressIndicator(value: 1.0, color: _accentColor, backgroundColor: Colors.grey[200], minHeight: 4),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pick at least 3 interests",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Show everyone what you're passionate about!",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 25),

                  // Loop สร้าง Categories และ Chips
                  ..._categories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key, 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: entry.value.map((interest) {
                            final isSelected = _selectedInterests.contains(interest);
                            return GestureDetector(
                              onTap: () => _toggleInterest(interest),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? _primaryColor : Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected ? _primaryColor : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected 
                                    ? [BoxShadow(color: _primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                    : [],
                                ),
                                child: Text(
                                  interest,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 25),
                      ],
                    );
                  }).toList(),
                  
                  const SizedBox(height: 80), // เผื่อที่ให้ปุ่มข้างล่าง
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button แบบยาว (Bottom Bar)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _saveInterests,
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Finish", // ✅ เอาตัวเลขออกแล้วครับ
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                ),
          ),
        ),
      ),
    );
  }
}