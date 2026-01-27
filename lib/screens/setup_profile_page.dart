// lib/screens/setup_profile_page.dart

import 'dart:io'; // ✅ Needed for File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // ✅ For picking images
import 'package:http/http.dart' as http; // ✅ For uploading to Cloudinary
import 'dart:convert'; // ✅ For parsing JSON
import 'main_layout.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Variables
  String? _selectedGender;
  String? _selectedFaculty;
  bool _isLoading = false;
  File? _imageFile; // ✅ Variable to store the selected image

  // Constants for Design
  final Color _primaryColor = const Color(0xFF005030); // Deep Green
  final Color _accentColor = const Color(0xFFC5A065); // Muted Gold
  final double _fieldRadius = 16.0;

  final List<String> _faculties = [   
  "Agriculture (เกษตร)",
  "Agro-Industry (อุตสาหกรรมเกษตร)",
  "Architecture (สถาปัตยกรรมศาสตร์)",
  "Business Administration (บริหารธุรกิจ)",
  "Economics (เศรษฐศาสตร์)",
  "Education (ศึกษาศาสตร์)",
  "Engineering (วิศวกรรมศาสตร์)",
  "Environment (สิ่งแวดล้อม)",
  "Fisheries (ประมง)",
  "Forestry (วนศาสตร์)",
  "Humanities (มนุษยศาสตร์)",
  "International College (วิทยาลัยนานาชาติ)",
  "Medicine (แพทยศาสตร์)",
  "Nursing (พยาบาลศาสตร์)",
  "Pharmacy (เภสัชศาสตร์)",
  "School of Integrated Science (วิทยาลัยบูรณาการศาสตร์)",
  "Science (วิทยาศาสตร์)",
  "Social Sciences (สังคมศาสตร์)",
  "Veterinary Medicine (สัตวแพทยศาสตร์)",
  "Veterinary Technology (เทคนิคการสัตวแพทย์)",
  ];

  final List<String> _genders = ["Male", "Female", "LGBTQ+", "Prefer not to say"];

  // ---------------------------------------------------------
  // ✅ 1. Function to Pick Image (Gallery/Camera)
  // ---------------------------------------------------------
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800, // Resize to save data
                );
                if (image != null) setState(() => _imageFile = File(image.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                );
                if (image != null) setState(() => _imageFile = File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // ✅ 2. Function to Upload Image to Cloudinary (Free & No Card)
  // ---------------------------------------------------------
  Future<String?> _uploadImageToCloudinary(File image) async {
    // 👇👇 REPLACE THESE WITH YOUR CLOUDINARY DETAILS 👇👇
    String cloudName = "dgdl2uy9z"; 
    String uploadPreset = "Kupid_tharit"; 
    // 👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆

    try {
      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      var request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url']; // Get the URL
      } else {
        debugPrint("Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading: $e");
      return null;
    }
  }

  // --- Logic Validations ---
  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) return 'Please enter student ID';
    if (value.length != 10) return 'Must be 10 digits';
    if (int.tryParse(value) == null) return 'Numeric only';
    int year = int.parse(value.substring(0, 2));
    if (year < 50 || year > 75) return 'Invalid Year (50-75)';
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

      // Check for duplicate Student ID
      final QuerySnapshot existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .get();

      bool isDuplicate = existingUser.docs.any((doc) => doc.id != uid);

      if (isDuplicate) {
        throw "Student ID ($studentId) is already taken.";
      }

      // ✅ 3. Upload Image Logic
      String? photoUrl;
      if (_imageFile != null) {
        // If user picked an image, upload to Cloudinary
        photoUrl = await _uploadImageToCloudinary(_imageFile!);
      } 
      
      // If upload failed or no image picked, use default avatar
      photoUrl ??= _selectedGender == 'Female'
            ? 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=600'
            : 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=600';

      // ✅ 4. Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'studentId': studentId,
        'gender': _selectedGender,
        'faculty': _selectedFaculty,
        'age': int.tryParse(_ageController.text.trim()) ?? 20,
        'bio': _bioController.text.trim(),
        'isProfileComplete': true,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainLayout()));
      }
    } catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (c) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Oops!"),
                  content: Text(e.toString().replaceAll("Exception:", "")),
                  actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
                ));
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
          "Create Profile",
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Avatar Section (Clickable)
              Center(
                child: Stack(
                  children: [
                    // 1. ตัวรูปภาพ Avatar (กดเพื่อเปลี่ยนรูป)
                GestureDetector(
                  onTap: _pickImage, // Tap to pick image
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          // If image selected, show it. Else show icon.
                          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                          child: _imageFile == null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[100],
                                  child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                      if (_imageFile != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageFile = null; // ล้างค่ารูปภาพทิ้ง
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[600], // สีแดง
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                    
                  ),
                ),
                ],
                ),
              ),
              const SizedBox(height: 30),

              const Text("About You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Tell us a bit about yourself to find the best match.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 20),

              // 1. Name
              _buildModernField(
                controller: _nameController,
                label: "Nickname",
                hint: "What should we call you?",
                icon: Icons.face_retouching_natural,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),

              // 2. Student ID
              _buildModernField(
                controller: _studentIdController,
                label: "Student ID",
                hint: "XXXXXXXXXX",
                icon: Icons.school_outlined,
                isNumber: true,
                maxLength: 10,
                validator: _validateStudentId,
              ),

              // 3. Faculty & Gender Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildModernDropdown(
                      label: "Faculty",
                      icon: Icons.domain,
                      value: _selectedFaculty,
                      items: _faculties,
                      onChanged: (val) => setState(() => _selectedFaculty = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildModernDropdown(
                      label: "Gender",
                      icon: Icons.wc,
                      value: _selectedGender,
                      items: _genders,
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: _buildModernField(
                      controller: _ageController,
                      label: "Age",
                      hint: "20",
                      icon: Icons.cake_outlined,
                      isNumber: true,
                      maxLength: 2,
                      validator: (val) => val!.isEmpty ? "Req" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 40, color: Colors.black12),

              // 4. BIO SECTION
              const Text("Your Bio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues( alpha: .05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primaryColor.withValues(alpha: .1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: _primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Tip: Mention your hobbies, favorite food, or study major to start a conversation!",
                        style: TextStyle(fontSize: 12, color: _primaryColor.withValues(alpha: .8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              _buildModernField(
                controller: _bioController,
                label: "Bio",
                icon: Icons.edit_note,
                maxLines: 4,
                hint: "Ex. I love playing Badminton at Gyimnasium 1, hunting for Shabu buffets, and I'm currently suffering in GenPhy...",
              ),

              const SizedBox(height: 40),

              // Submit Button
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_fieldRadius),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: .3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                  gradient: LinearGradient(
                    colors: [_primaryColor, const Color(0xFF007A50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_fieldRadius)),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Complete Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Unchanged)
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_fieldRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          maxLength: maxLength,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: _accentColor),
            filled: true,
            fillColor: Colors.transparent,
            counterText: "",
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
              borderSide: BorderSide(color: _primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            floatingLabelStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_fieldRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            )).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Required" : null,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _accentColor),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide(color: _primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          floatingLabelStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        isExpanded: true,
      ),
    );
  }
}