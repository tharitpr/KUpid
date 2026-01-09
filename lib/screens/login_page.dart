import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
                width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF002e1c), // เขียวเข้ม
              Color(0xFF005433), // เขียวกลาง
              Color(0xFF007a4a), // เขียวอ่อน
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // -----------------------------
                // LOGO / APP NAME
                // -----------------------------
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 12),
                Text(
                  "KUpid",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Find your match @ Kasetsart University",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                // -----------------------------
                // EMAIL TEXT FIELD
                // -----------------------------
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 1.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -----------------------------
                // PASSWORD TEXT FIELD
                // -----------------------------
                TextField(
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 1.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // -----------------------------
                // LOGIN BUTTON
                // -----------------------------
                GestureDetector(
                  onTap: () {
                     Navigator.pushNamed(context, '/main');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954), // เขียวสดกดเข้าได้
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        "เข้าสู่ระบบ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 5),
                const Divider(
                color: Colors.white24, // สีของเส้น (แนะนำสีจางๆ บนพื้นเขียวเข้ม)
                thickness: 1.0,        // ความหนาของเส้น
                height: 40,            // ความสูงของพื้นที่ "รอบๆ" เส้น (ทำหน้าที่เหมือน Margin บน-ล่าง)
                indent: 20,            // เว้นระยะจากซ้าย
                endIndent: 20,),
                const SizedBox(height: 5),

                GestureDetector(
                  onTap: () {
                     Navigator.pushNamed(context, '/swipe');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954), // เขียวสดกดเข้าได้
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        "KU All Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // -----------------------------
                // REGISTER LINK
                // -----------------------------
                Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text("ยังไม่มีบัญชี? ", // เคาะวรรคท้ายนิดนึงจะได้ไม่ติดกัน
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.none, // ปกติส่วนถามมักไม่มีขีดเส้นใต้ (แล้วแต่ Design นะครับ)
                      ),
                    ),
                    
                    // --- ข้อความที่ 2 ---
                  GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: const
                  Text("สมัครสมาชิกที่นี่",
                      style: TextStyle( // decoration ต้องอยู่ในนี้
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                    //    decoration: TextDecoration.underline, 
                      ),
                    ),)
                  ],
                  ),
                

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
