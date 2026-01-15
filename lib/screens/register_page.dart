import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // อย่าลืม import service ที่เราสร้าง

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. เรียกใช้ Service
  final AuthService _authService = AuthService();

  // 2. สร้าง Controllers สำหรับรับค่าจากฟอร์ม
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();

  // ตัวแปรสำหรับ Dropdown และ Loading
  String? _selectedGender;
  bool _isLoading = false;

  // 3. ฟังก์ชันกดปุ่มสมัคร
  void _handleRegister() async {
    // Basic Validation (เช็คค่าว่าง)
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    // เช็คว่ารหัสผ่านตรงกันไหม
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")),
      );
      return;
    }

    setState(() => _isLoading = true); // หมุนติ้วๆ

    // เรียก Service Backend
    var user = await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _facultyController.text.trim(),
    );

    setState(() => _isLoading = false); // หยุดหมุน

    if (user != null) {
      // สมัครสำเร็จ -> ไปหน้า Main (เชื่อมต่อแล้ว!)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      // สมัครไม่ผ่าน -> แจ้งเตือน
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("สมัครสมาชิกไม่สำเร็จ (Email อาจซ้ำหรือรหัสสั้นเกินไป)"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // คืนค่า Memory เมื่อปิดหน้านี้
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _facultyController.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO
                const Icon(Icons.favorite, color: Colors.white, size: 80),
                const SizedBox(height: 12),
                const Text(
                  "KUpid",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                 const SizedBox(height: 40),

                // TITLE
                const Text(
                  "Create your account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                 const SizedBox(height: 35),

                // FORM (ผูก Controller เข้าไป) --------------------------
                _buildInput("Email", Icons.email, controller: _emailController),
                const SizedBox(height: 20),

                _buildInput("Password", Icons.lock, obscure: true, controller: _passwordController),
                const SizedBox(height: 20),

                _buildInput("Confirm Password", Icons.lock_outline, obscure: true, controller: _confirmPasswordController),
                const SizedBox(height: 20),

                _buildInput("Display Name", Icons.person, controller: _nameController),
                const SizedBox(height: 20),

                _buildInput("Major / Faculty", Icons.school, controller: _facultyController),
                const SizedBox(height: 20),

                // Gender Dropdown (ปรับให้ทำงานได้จริง)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xFF004D24),
                      value: _selectedGender,
                      hint: const Text("Gender", style: TextStyle(color: Colors.white70)),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      isExpanded: true,
                      items: ["Male", "Female", "Other"]
                          .map((gender) => DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender, style: const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF003A1B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    // ถ้ากำลังโหลด ให้ปุ่มกดไม่ได้ (null)
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF003A1B))
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // BACK TO LOGIN
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget: เพิ่ม parameter controller
  Widget _buildInput(String label, IconData icon,
      {bool obscure = false, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller, // ผูก controller ตรงนี้
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          icon: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}
