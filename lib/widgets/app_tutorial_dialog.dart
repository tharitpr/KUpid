import 'package:flutter/material.dart';

class AppTutorialDialog extends StatefulWidget {
  const AppTutorialDialog({super.key});

  @override
  State<AppTutorialDialog> createState() => _AppTutorialDialogState();
}

class _AppTutorialDialogState extends State<AppTutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialData = [
    {
      "title": "ยินดีต้อนรับสู่ KUpid!",
      "desc": "พื้นที่หาเพื่อนและคนรู้ใจสำหรับเด็กเกษตรฯ โดยเฉพาะ",
      "icon": Icons.volunteer_activism,
      "color": Colors.pinkAccent,
    },
    {
      "title": "ปัดขวา = ชอบ (Like) 💚",
      "desc": "ถ้าเจอคนที่ใช่ ให้ปัดขวา หรือกดปุ่มหัวใจสีเขียว เพื่อส่งคำขอ",
      "icon": Icons.favorite,
      "color": Color(0xFF006400),
    },
    {
      "title": "ปัดซ้าย = ข้าม (Pass) ❌",
      "desc": "ถ้ายังไม่ใช่สไตล์ ให้ปัดซ้าย หรือกดปุ่มกากบาท เพื่อข้ามไปก่อน",
      "icon": Icons.close,
      "color": Colors.redAccent,
    },
    {
      "title": "It's a Match! 🎉",
      "desc": "ถ้าเขาคนนั้นกด Like คุณกลับมา ระบบจะจับคู่ให้คุณเริ่มแชทกันได้ทันที!",
      "icon": Icons.chat_bubble,
      "color": Colors.blueAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slide Content
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _tutorialData[index]['color'].withValues(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _tutorialData[index]['icon'],
                          size: 60,
                          color: _tutorialData[index]['color'],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _tutorialData[index]['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _tutorialData[index]['desc'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tutorialData.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF006400) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006400),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_currentPage < _tutorialData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    Navigator.pop(context); // ปิด Dialog เมื่อถึงหน้าสุดท้าย
                  }
                },
                child: Text(
                  _currentPage == _tutorialData.length - 1 ? "Let's Go!" : "Next",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}