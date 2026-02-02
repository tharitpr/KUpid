import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../services/auth_service.dart';
import 'setup_profile_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ เพิ่มส่วนนี้: สั่งให้โชว์ Popup ทันทีที่หน้าจอโหลดเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAppInfoDialog();
    });
  }

  // ✅ ฟังก์ชันแสดง Popup ข้อมูลแอป
  // ✅ ฟังก์ชันแสดง Popup ข้อมูลแอป (New Design)
  void _showAppInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, 
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            // Container หลัก
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------------------------------------------
                // 1. Header ส่วนหัว (Gradient Green)
                // ---------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF002e1c), Color(0xFF007a4a)], // ธีมเขียว KU
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Welcome to KUpid",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------
                // 2. Body เนื้อหา (English)
                // ---------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        "The exclusive dating & community app for Kasetsart University students.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      
                      // Feature List
                      _buildInfoRow(Icons.verified_user, "Verified Students", "Only legitimate @ku.th emails allowed."),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.favorite, "Find Your Match", "Connect based on faculty & interests."),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.security, "Safe & Secure", "Your privacy is our top priority."),

                      const SizedBox(height: 30),

                      // ---------------------------------------------
                      // 3. Button ปุ่มกด
                      // ---------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005433), // สีปุ่มเขียวเข้ม
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Widget สำหรับสร้างแถวข้อความ
  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF005433).withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF005433), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  // 4. ฟังก์ชันกดปุ่ม Login (ปรับปรุง Logic ความปลอดภัย)
  void _handleLogin() async {
    // 1. เช็ค Input ว่าง
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter Email and Password")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. เรียก Firebase Sign In
      var user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return; 
      
      setState(() => _isLoading = false);

      if (user != null) {
        debugPrint("Login successful - User: ${user.email}");
        debugPrint("Email Verified: ${user.emailVerified}");

        // Check email verification
        if (!user.emailVerified) {
          debugPrint("Warning: Email not verified");
          // ถ้ายัง -> เตะออกทันที
          await _authService.signOut();

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Verify Email Required"),
                content: const Text(
                  "This account has not been verified yet.\n\n"
                  "1. Check your Inbox or Junk Mail\n"
                  "2. Click the verification link in the email\n"
                  "3. Return and login again"
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("ตกลง"),
                  ),
                ],
              ),
            );
          }
          return; // จบการทำงาน ไม่ให้ไปต่อ
        }

        // ✅ ด่านที่ 2: เช็คว่ากรอกประวัติเสร็จหรือยัง?
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!mounted) return;

          bool isProfileComplete = false;
          if (userDoc.exists && userDoc.data() != null) {
            var data = userDoc.data() as Map<String, dynamic>;
            isProfileComplete = data['isProfileComplete'] ?? false;
            debugPrint("Profile Complete: $isProfileComplete");
          } else {
            debugPrint("Warning: User document not found in Firestore");
          }

          if (isProfileComplete) {
            debugPrint("Navigate to Main");
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            debugPrint("Navigate to Setup Profile");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SetupProfilePage()),
            );
          }
        } catch (e) {
          debugPrint("Error checking profile: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("เกิดข้อผิดพลาด: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

      } else {
        debugPrint("Login failed");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login failed (Wrong email or password)"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Unexpected error in login: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาดที่ไม่คาดคิด: $e"),
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
            child: SingleChildScrollView( 
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 80),
                  const SizedBox(height: 12),
                  const Text("KUpid", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Find your match @ Kasetsart University", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),

                  const SizedBox(height: 30),

                  // EMAIL FIELD
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email - @ku.th ", // Hint ให้ user รู้
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      prefixIcon: const Icon(Icons.email, color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white70, width: 1.2), borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD FIELD
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white70, width: 1.2), borderRadius: BorderRadius.circular(14)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // LOGIN BUTTON
                  GestureDetector(
                    onTap: _isLoading ? null : _handleLogin, 
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  const Divider(color: Colors.white24, thickness: 1.0, height: 40, indent: 20, endIndent: 20),
                  
                  // Trust Badge Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2), // Background color
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24), // Border
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trust badge icon
                        const Icon(Icons.verified_user_outlined, color: Color(0xFF69F0AE), size: 24), 
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Exclusive for KU Students",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Verified by University Email",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No account yet? ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/register");
                        },
                        child: const Text(
                          "Sign up here",
                          style: TextStyle(color: Color(0xFF1DB954), fontSize: 16, fontWeight: FontWeight.bold),
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