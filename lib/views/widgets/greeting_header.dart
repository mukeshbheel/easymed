import 'package:flutter/material.dart';

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
          "Hello, Joanna",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
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
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: "today",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF4A340), // warm orange highlight
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
