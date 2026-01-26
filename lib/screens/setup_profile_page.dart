// lib/screens/setup_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_layout.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับ Text Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // ตัวแปรสำหรับ Dropdown
  String? _selectedGender;
  String? _selectedFaculty;
  bool _isLoading = false;

  // รายชื่อคณะ
  final List<String> _faculties = [
    "Engineering (วิศวกรรมศาสตร์)",
    "Science (วิทยาศาสตร์)",
    "Agriculture (เกษตร)",
    "Business Administration (บริหารธุรกิจ)",
    "Humanities (มนุษยศาสตร์)",
    "Social Sciences (สังคมศาสตร์)",
    "Economics (เศรษฐศาสตร์)",
    "Education (ศึกษาศาสตร์)",
    "Agro-Industry (อุตสาหกรรมเกษตร)",
    "Fisheries (ประมง)",
    "Architecture (สถาปัตยกรรมศาสตร์)",
    "Veterinary Medicine (สัตวแพทยศาสตร์)",
    "Environment (สิ่งแวดล้อม)",
    "Other (อื่นๆ)"
  ];

  // รายชื่อเพศ
  final List<String> _genders = ["Male", "Female", "LGBTQ+", "Prefer not to say"];

  // --- Logic 1: Validate Student ID ---
  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) return 'Enter student ID';
    if (value.length != 10) return 'Student ID must be 10 digits';
    
    if (int.tryParse(value) == null) return 'Must be numeric only';

    // เช็คปีการศึกษา (2 ตัวแรก)
    int year = int.parse(value.substring(0, 2));
    if (year < 50 || year > 75) { // ปรับช่วงปีให้กว้างขึ้นเผื่อซิ่วหรือปีเก่า
      return 'Invalid ID (Year 50-75 only)';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw "User not logged in";

      String uid = currentUser.uid;
      String studentId = _studentIdController.text.trim();

      // --- Logic 2: ตรวจสอบรหัสซ้ำ ---
      final QuerySnapshot existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .get();

      // เช็คว่ามีคนใช้นี้ไปแล้วหรือยัง (ที่ไม่ใช่เรา)
      bool isDuplicate = existingUser.docs.any((doc) => doc.id != uid);

      if (isDuplicate) {
        throw "รหัสนิสิตนี้ ($studentId) ถูกใช้งานแล้ว!";
      }

      // บันทึกข้อมูล
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'studentId': studentId,
        'gender': _selectedGender,
        'faculty': _selectedFaculty,
        'age': int.tryParse(_ageController.text.trim()) ?? 20,
        'bio': _bioController.text.trim(),
        'isProfileComplete': true,
        // รูป Default
        'photoUrl': _selectedGender == 'Female' 
            ? 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=600'
            : 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=600',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        // ไปหน้า Main
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const MainLayout())
        );
      }

    } catch (e) {
      if (mounted) {
        showDialog(
          context: context, 
          builder: (c) => AlertDialog(
            title: const Text("Save Failed"),
            content: Text(e.toString().replaceAll("Exception:", "")),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text("Personal Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Enter real information to verify as a student", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 30),

              // 1. Name
              _buildTextField(
                controller: _nameController,
                label: "Display Name / Nickname",
                icon: Icons.face,
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),

              // 2. Student ID
              _buildTextField(
                controller: _studentIdController,
                label: "Student ID (10 digits)",
                icon: Icons.badge,
                isNumber: true,
                maxLength: 10,
                validator: _validateStudentId,
              ),
              const SizedBox(height: 16),

              // 3. Faculty
              _buildDropdownField(
                label: "Faculty",
                icon: Icons.school,
                value: _selectedFaculty,
                items: _faculties,
                onChanged: (val) => setState(() => _selectedFaculty = val),
              ),
              const SizedBox(height: 16),

              // 4. Gender
              _buildDropdownField(
                label: "Gender",
                icon: Icons.wc,
                value: _selectedGender,
                items: _genders,
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 16),

              // 5. Age & Bio
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: "Age",
                      icon: Icons.cake,
                      isNumber: true,
                      maxLength: 2,
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _bioController,
                label: "Bio (Tell us about yourself)",
                icon: Icons.edit_note,
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Save Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper สร้าง Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  // Helper สร้าง Dropdown Field (แก้แล้ว ✅)
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      // ❌ ลบ key ออกเพื่อแก้ปัญหา Duplicate keys
      value: value, // ใช้ value แทน initialValue เพื่อให้มันอัปเดตตาม State
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Please select $label" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      isExpanded: true,
    );
  }
}