// lib/widgets/profile_card.dart

import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final Map<String, String> profileData; 

  const ProfileCard({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        // ใช้ AssetImage จากโค้ดเดิมของคุณ
        image: DecorationImage(
          image: AssetImage(profileData["image"]!),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profileData["name"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                profileData["faculty"]!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}