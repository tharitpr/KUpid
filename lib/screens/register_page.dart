import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// import 'setup_profile_page.dart'; // No need - go to login after signup

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();}

  class _RegisterPageState extends State<RegisterPage> {
    final AuthService _authService = AuthService();

    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();

    bool _isLoading = false;

    void _handleRegister() async {
      String email = _emailController.text.trim().toLowerCase();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      // 1. Check Empty
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields")),
        );
        return;
      }

      // 2. Verify it's a university email
      bool isKUEmail = email.endsWith('@ku.th');
      if (!isKUEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Only university email (@ku.th) is allowed"),
            backgroundColor: Colors.red,
          ),
        );
        return; // หยุดทำงาน ไม่ให้สมัคร
      }

      // 3. Check Password Match
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      setState(() => _isLoading = true);

      // 4. Call service (will handle email verification)
      var user = await _authService.signUp(email, password);

      if (mounted) setState(() => _isLoading = false);

      if (user != null) {
        // 5. Registration successful - show dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Must click button to close
            builder: (context) => AlertDialog(
              title: const Text("Registration Successful!"),
              content: const Text(
                "Verification email has been sent to your email address.\n\n"
                "1. Check your Inbox or Junk Mail\n"
                "2. Click the verification link in the email\n"
                "3. Return to login"
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // ปิด Dialog
                    Navigator.pop(context); // กลับไปหน้า Login
                  },
                  child: const Text("OK, Go to Login", style: TextStyle(color: Color(0xFF003A1B))),
                ),
              ],
            ),
          );
        }
      } else {
        // สมัครไม่ผ่าน
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("สมัครไม่สำเร็จ (Email อาจถูกใช้แล้ว หรือรหัสสั้นเกินไป)"),
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
      _confirmPasswordController.dispose();
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
                Color(0xFF002e1c), 
                Color(0xFF005433), 
                Color(0xFF007a4a), 
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
                  const Icon(Icons.favorite, color: Colors.white, size: 80),
                  const SizedBox(height: 12),
                  const Text("KUpid", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 40),
                  const Text("Create your account", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 35),

                  _buildInput("Email (@ku.th / @live.ku.th)", Icons.email, controller: _emailController),
                  const SizedBox(height: 20),

                  _buildInput("Password", Icons.lock, obscure: true, controller: _passwordController),
                  const SizedBox(height: 20),

                  _buildInput("Confirm Password", Icons.lock_outline, obscure: true, controller: _confirmPasswordController),
                  const SizedBox(height: 35),

                  // REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF003A1B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF003A1B))
                          : const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BACK TO LOGIN
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildInput(String label, IconData icon, {bool obscure = false, required TextEditingController controller}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
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