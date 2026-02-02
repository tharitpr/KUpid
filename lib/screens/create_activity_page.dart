// lib/screens/create_activity_page.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _activityIdController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();

  // Variables
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = 'Academic';
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ['Academic', 'Sports', 'Entertainment', 'Volunteer', 'Food & Drink', 'Travel'];
  final Color _primaryGreen = const Color(0xFF006400);

  // --- Cloudinary Config ---
  final String cloudName = "dgdl2uy9z"; 
  final String uploadPreset = "Kupid_tharit"; 

  // --- Image Picker (ใช้สูตร maxWidth: 800) ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      // ✅ ใช้ maxWidth: 800 ช่วยลดขนาดภาพ ป้องกันแอปเด้งจากเมมเต็ม
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 800, 
      );
      
      if (image != null) {
        setState(() => _imageFile = File(image.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      // ถ้าเด้งตรงนี้ แสดงว่าเป็นที่ Permission 100%
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot pick image. Check permissions.")));
    }
  }

  // --- Date Picker ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // --- Time Picker ---
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // --- ☁️ Cloudinary Upload Function ---
  Future<String?> _uploadImageToCloudinary(File image) async {
    try {
      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      var request = http.MultipartRequest("POST", uri);
      
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var jsonMap = jsonDecode(String.fromCharCodes(responseData));
        return jsonMap['secure_url'];
      } else {
        debugPrint("Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  // --- Submit Logic ---
  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Date & Time")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String finalImageUrl = "https://images.unsplash.com/photo-1523580494863-6f3031224c94?q=80&w=2070&auto=format&fit=crop"; 

      if (_imageFile != null) {
        String? uploadedUrl = await _uploadImageToCloudinary(_imageFile!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        } else {
          throw Exception("Failed to upload image.");
        }
      }

      final DateTime dateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('activities').add({
        'activityId': _activityIdController.text.trim(),
        'organization': _organizationController.text.trim(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
        'maxParticipants': int.tryParse(_maxParticipantsController.text) ?? 0,
        'dateTime': Timestamp.fromDate(dateTime),
        'image': finalImageUrl, 
        'hostId': user.uid,
        'status': 'pending', 
        'participants': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Activity Submitted! Waiting for Admin Approval."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // 1. เช็ค mounted ของ State ก่อน
      if (!mounted) return;
      
      // 2. ดึง ScaffoldMessengerState ออกมาล่วงหน้า หรือเช็ค context.mounted อีกครั้ง
      final messenger = ScaffoldMessenger.of(context);
      
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Create Activity", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Picker Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("Upload Cover Image", style: TextStyle(color: Colors.grey[500])),
                          ],
                        )
                      : Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Icon(Icons.edit, color: _primaryGreen, size: 18),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Activity ID & Organization
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _activityIdController,
                      label: "Activity ID (เลขกิจกรรม)",
                      icon: Icons.tag,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _organizationController,
                      label: "Organization (สังกัด)",
                      icon: Icons.business,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Title
              _buildTextField(
                controller: _titleController,
                label: "Activity Name",
                icon: Icons.event,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // 4. Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: _primaryGreen, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              _selectedDate == null ? "Select Date" : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                              style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: _primaryGreen, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                              style: TextStyle(color: _selectedTime == null ? Colors.grey : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Location & Max Participants
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _locationController,
                      label: "Location",
                      icon: Icons.location_on,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _maxParticipantsController,
                      label: "Max People",
                      icon: Icons.group,
                      isNumber: true,
                      validator: (v) => v!.isEmpty ? "Req" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Category Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Description
              _buildTextField(
                controller: _descriptionController,
                label: "Description & Details",
                icon: Icons.description,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _submitActivity,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text("Uploading...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        )
                      : const Text("Request Approval (ส่งอนุมัติ)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: TextField ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryGreen, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}