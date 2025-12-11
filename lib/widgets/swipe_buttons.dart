// lib/widgets/swipe_buttons.dart

import 'package:flutter/material.dart';

class SwipeButtons extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const SwipeButtons({
    super.key,
    required this.onLike,
    required this.onDislike,
  });

  // ----------------- BUTTON WIDGET -----------------
  Widget _circleButton({
    required IconData icon,
    required Color color,
    required double size,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            )
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.close,
          color: Colors.red,
          size: 60,
          onTap: onDislike,
        ),
        const SizedBox(width: 30),
        _circleButton(
          icon: Icons.favorite,
          color: Theme.of(context).colorScheme.primary, // ใช้สีหลักจาก Theme (สีเขียว)
          size: 60,
          onTap: onLike,
        ),
      ],
    );
  }
}