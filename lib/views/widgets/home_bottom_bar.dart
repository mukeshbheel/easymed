import 'package:flutter/material.dart';
import 'package:medicine_app/views/manage_reminders_screen.dart';

class HomeBottomBar extends StatelessWidget {
  final VoidCallback onAddTap;

  const HomeBottomBar({
    super.key,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 40,
        right: 40,
        top: 12,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ManageRemindersScreen()),
            );
          }, child: _NavIcon(icon: Icons.edit_note)),
          // _NavIcon(icon: Icons.bar_chart_rounded),

          /// CENTER ADD BUTTON
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A5AE0),
                    Color(0xFF8E7BFF),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // _NavIcon(icon: Icons.notifications_none),
          _NavIcon(icon: Icons.person_outline),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;

  const _NavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 26,
      color: Colors.grey.shade500,
    );
  }
}
