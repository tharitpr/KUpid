// lib/screens/edit_profile_page.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

  class _EditProfilePageState extends State<EditProfilePage> {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final _formKey = GlobalKey<FormState>();

    // Controllers
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _bioController = TextEditingController();
    
    // State Variables
    String? _selectedFaculty;
    String? _selectedGender;
    String? _photoUrl; // เก็บ URL รูปปัจจุบัน
    bool _isLoading = true; // โหลดข้อมูลตอนแรก
    bool _isSaving = false; // โหลดตอนกดเซฟ

    // Constants (Theme สีเขียวเกษตร)
    final Color _primaryGreen = const Color(0xFF006400); 
    final Color _accentGreen = const Color(0xFF32CD32);  
    final Color _bgGrey = const Color(0xFFF9FAFB);
    final double _fieldRadius = 16.0;

    // Dropdown Lists
    final List<String> _faculties = [
      "Engineering (วิศวกรรมศาสตร์)", "Science (วิทยาศาสตร์)", "Agriculture (เกษตร)",
      "Business Administration (บริหารธุรกิจ)", "Humanities (มนุษยศาสตร์)", 
      "Social Sciences (สังคมศาสตร์)", "Economics (เศรษฐศาสตร์)", "Education (ศึกษาศาสตร์)", 
      "Agro-Industry (อุตสาหกรรมเกษตร)", "Fisheries (ประมง)", 
      "Architecture (สถาปัตยกรรมศาสตร์)", "Veterinary Medicine (สัตวแพทยศาสตร์)", 
      "Environment (สิ่งแวดล้อม)", "Other (อื่นๆ)"
    ];
    final List<String> _genders = ["Male", "Female", "LGBTQ+", "Prefer not to say"];

    @override
    void initState() {
      super.initState();
      _fetchUserData();
    }

    // ✅ 1. ดึงข้อมูลเก่ามาโชว์
    Future<void> _fetchUserData() async {
      if (currentUser == null) return;

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? "";
            _bioController.text = data['bio'] ?? "";
            _selectedFaculty = data['faculty'];
            _selectedGender = data['gender'];
            _photoUrl = data['photoUrl'];
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
        setState(() => _isLoading = false);
      }
    }

    // ✅ 2. อัปโหลดรูปใหม่ (Cloudinary)
    Future<void> _pickAndUploadImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);

      if (image == null) return;

      // Show loading indicator on avatar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading image...")));

      String cloudName = "dgdl2uy9z"; 
      String uploadPreset = "kupid_unsigned"; // ✅ ใช้ Preset เดียวกับหน้าอื่น

      try {
        var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
        var request = http.MultipartRequest("POST", uri);
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', image.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var jsonMap = jsonDecode(String.fromCharCodes(responseData));
          
          setState(() {
            _photoUrl = jsonMap['secure_url']; // อัปเดต URL ใน State เพื่อโชว์รูปใหม่ทันที
          });
        } else {
          debugPrint("Upload Failed: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Error uploading: $e");
      }
    }

    // ✅ 3. บันทึกข้อมูลลง Firestore
    Future<void> _saveProfile() async {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isSaving = true);

      try {
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'faculty': _selectedFaculty,
          'gender': _selectedGender,
          'photoUrl': _photoUrl, // บันทึกรูปใหม่ (ถ้ามีการเปลี่ยน)
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated! ✅")));
          Navigator.pop(context); // กลับไปหน้า Profile
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      // Default placeholder ถ้ายังไม่มีรูป
      String displayImage = (_photoUrl != null && _photoUrl!.isNotEmpty)
          ? _photoUrl!
          : "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=600";

      return Scaffold(
        backgroundColor: _bgGrey,
        appBar: AppBar(
          backgroundColor: _primaryGreen,
          elevation: 0,
          title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------------- PROFILE IMAGE -------------------------
                      Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 120, height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: NetworkImage(displayImage),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: _accentGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // ---------------------- FORM FIELDS -------------------------
                      _buildModernField(
                        controller: _nameController, 
                        label: "Display Name", 
                        icon: Icons.person_outline
                      ),
                      
                      _buildModernDropdown(
                        label: "Faculty", 
                        icon: Icons.school_outlined, 
                        value: _selectedFaculty, 
                        items: _faculties, 
                        onChanged: (val) => setState(() => _selectedFaculty = val)
                      ),
                      
                      _buildModernDropdown(
                        label: "Gender", 
                        icon: Icons.wc, 
                        value: _selectedGender, 
                        items: _genders, 
                        onChanged: (val) => setState(() => _selectedGender = val)
                      ),
                      
                      _buildModernField(
                        controller: _bioController, 
                        label: "Bio", 
                        icon: Icons.edit_note, 
                        maxLines: 4
                      ),

                      const SizedBox(height: 30),

                      // ---------------------- SAVE BUTTON -------------------------
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_fieldRadius),
                          gradient: LinearGradient(colors: [_primaryGreen, const Color(0xFF007A50)]),
                          boxShadow: [BoxShadow(color: _primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_fieldRadius)),
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      );
    }

    // ---------------------- HELPERS (Modern Style) -------------------------

    Widget _buildModernField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      int maxLines = 1,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (val) => val!.isEmpty ? "Required" : null,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              floatingLabelStyle: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    Widget _buildModernDropdown({
      required String label,
      required IconData icon,
      required String? value,
      required List<String> items,
      required Function(String?) onChanged,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            floatingLabelStyle: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold),
          ),
          isExpanded: true,
        ),
      );
    }
  }