import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003A1B), // เขียวเข้ม
              Color(0xFF005A2B), // เขียวกลาง
              Color(0xFF007A3B), // เขียวอ่อน
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
                // LOGO MOCKUP
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

                // FORM -----------------------------------------------------
                _buildInput("Email", Icons.email),
                const SizedBox(height: 20),

                _buildInput("Password", Icons.lock, obscure: true),
                const SizedBox(height: 20),

                _buildInput("Confirm Password", Icons.lock_outline, obscure: true),
                const SizedBox(height: 20),

                _buildInput("Display Name", Icons.person),
                const SizedBox(height: 20),

                _buildInput("Major / Faculty", Icons.school),
                const SizedBox(height: 20),

                // Gender dropdown mock
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: const Color(0xFF004D24),
                    value: null,
                    hint: const Text(
                      "Gender",
                      style: TextStyle(color: Colors.white70),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ["Male", "Female", "Other"]
                        .map((gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(
                                gender,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ))
                        .toList(),
                    onChanged: (_) {},
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
                    onPressed: () {},
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BACK TO LOGIN
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // CUSTOM INPUT FIELD MOCKUP
  // -------------------------------------------------------------
  static Widget _buildInput(String label, IconData icon, {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
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
