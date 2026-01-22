import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // MOCK Controllers
  final TextEditingController nameCtrl =
      TextEditingController(text: "John Doe");
  final TextEditingController facultyCtrl =
      TextEditingController(text: "Engineering");
  final TextEditingController bioCtrl =
      TextEditingController(text: "I’m a KU student who loves coding and coffee.");

  String? gender = "Male";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003A1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003A1B),
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------- PROFILE IMAGE -------------------------
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: Colors.white70, width: 3),
                        image: const DecorationImage(
                          image: AssetImage("assets/mock/profile.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 20, color: Color(0xFF003A1B)),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ---------------------- NAME -------------------------
              _label("Display Name"),
              _inputField(controller: nameCtrl),

              const SizedBox(height: 18),

              // ---------------------- FACULTY -------------------------
              _label("Faculty"),
              _inputField(controller: facultyCtrl),

              const SizedBox(height: 18),

              // ---------------------- GENDER -------------------------
              _label("Gender"),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButton<String>(
                  value: gender,
                  dropdownColor: const Color(0xFF004D24),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white),
                  items: ["Male", "Female", "Other"]
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(g, style: const TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => gender = value);
                  },
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------- BIO -------------------------
              _label("Bio"),
              _inputField(
                controller: bioCtrl,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // ---------------------- SAVE BUTTON -------------------------
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
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Mock: just go back
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- HELPERS -------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
