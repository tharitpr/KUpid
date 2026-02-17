// lib/widgets/emergency_button.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactDialog extends StatelessWidget {
  const EmergencyContactDialog({super.key});

  
  final String _kuEmergencyNumber = "029428111"; 
  final String _securityNumber = "025790113";   

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch $launchUri");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
    
            // 1. Header สีแดงไล่เฉด (Gradient Header)
           
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF512F), Color(0xFFDD2476)], // แดงส้ม -> แดงเข้ม
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sos_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "EMERGENCY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    "ติดต่อฉุกเฉิน",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            
            // 2. Content & Buttons
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  const Text(
                    "คุณต้องการความช่วยเหลือด่วนหรือไม่?\nเลือกหน่วยงานที่ต้องการติดต่อด้านล่าง",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                 
                  _buildEmergencyButton(
                    label: "เรียกรถพยาบาล / กองยานฯ",
                    subLabel: "Medical / Vehicle Service",
                    icon: Icons.medical_services_outlined,
                    color: Colors.orange.shade700,
                    onTap: () => _makePhoneCall(_kuEmergencyNumber),
                  ),

                  const SizedBox(height: 12),

             
                  _buildEmergencyButton(
                    label: "แจ้งเหตุ รปภ. มก.",
                    subLabel: "Security Guard",
                    icon: Icons.local_police_outlined,
                    color: Colors.red.shade700,
                    onTap: () => _makePhoneCall(_securityNumber),
                  ),

                  const SizedBox(height: 20),

                  // Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("ยกเลิก (Cancel)", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper 
  Widget _buildEmergencyButton({
    required String label,
    required String subLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues( alpha: .15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subLabel,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}