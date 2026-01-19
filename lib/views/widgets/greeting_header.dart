import 'package:flutter/material.dart';
import 'package:medicine_app/utils/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Avatar
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: const AssetImage(
            "assets/images/profile.png", // replace with your image
          ),
        ),

        const SizedBox(height: 16),

        /// Greeting
        const Text(
          "Hello, Buddy",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 8),

        /// Title with highlighted word
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Your medicines for ",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              TextSpan(
                text: "today",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary, // warm orange highlight
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
