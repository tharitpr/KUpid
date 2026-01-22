import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // 1. Import Service

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. เรียกใช้ AuthService
  final AuthService _authService = AuthService();

  // 3. สร้าง Controller รับค่าจากช่องกรอก
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // สถานะการโหลด (หมุนติ้วๆ)
  bool _isLoading = false;

  // 4. ฟังก์ชันกดปุ่ม Login
  void _handleLogin() async {
    // เช็คว่ากรอกครบไหม
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอก Email และ Password")),
      );
      return;
    }

    // เริ่มโหลด
    setState(() => _isLoading = true);

    // เรียก Firebase
    var user = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // หยุดโหลด
    setState(() => _isLoading = false);

    if (user != null) {
      // Login สำเร็จ -> ไปหน้า Main
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      // Login พลาด -> แจ้งเตือน
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login ไม่สำเร็จ (อีเมลหรือรหัสผ่านผิด)"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            child: SingleChildScrollView( // เพิ่ม Scroll เพื่อไม่ให้คีย์บอร์ดบัง
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
                  const Text(
                    "KUpid",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
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
                    controller: _emailController, // ผูกตัวแปร
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      prefixIcon: const Icon(Icons.email, color: Colors.white70), // เพิ่มไอคอนสวยๆ
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
                    controller: _passwordController, // ผูกตัวแปร
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70), // เพิ่มไอคอนสวยๆ
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
                  // LOGIN BUTTON (แก้ไขให้กดแล้ว Login จริง)
                  // -----------------------------
                  GestureDetector(
                    onTap: _isLoading ? null : _handleLogin, // ถ้าโหลดอยู่ ห้ามกดซ้ำ
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isLoading 
                          // ถ้าโหลดอยู่ ให้โชว์วงกลมหมุนๆ
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          // ถ้าปกติ โชว์ข้อความเดิม
                          : const Text(
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
                  
                  // เส้นคั่น
                  const Divider(
                    color: Colors.white24,
                    thickness: 1.0,
                    height: 40,
                    indent: 20,
                    endIndent: 20,
                  ),
                  
                  const SizedBox(height: 5),

                  // ปุ่ม KU All Login (อันนี้ไว้ Mock หรือทำทีหลัง)
                  GestureDetector(
                    onTap: () {
                      // ตอนนี้ให้ข้ามไปก่อน เหมือนเดิม
                       Navigator.pushNamed(context, '/swipe');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent, // เปลี่ยนเป็นโปร่งใสให้ดูรองลงมา
                        border: Border.all(color: Colors.white70), // ใส่ขอบแทน
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "ยังไม่มีบัญชี? ",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/register");
                        },
                        child: const Text(
                          "สมัครสมาชิกที่นี่",
                          style: TextStyle(
                            color: Color(0xFF1DB954), // ใช้สีเขียวสดให้เด่น
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
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
