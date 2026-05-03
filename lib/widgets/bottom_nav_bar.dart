import 'dart:ui';
import 'package:flutter/material.dart';

import '../screens/hub_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/evidence_collection_screen.dart';

class AuraBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AuraBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, _) => const HubScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, _) => const EvidenceCollectionScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, _) => const NotificationsScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else {
      // Other screens not implemented yet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Screen coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // backdrop-blur-2xl approx
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.grid_view,
                  label: 'HUB',
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.receipt_long,
                  label: 'CLAIMS',
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.analytics,
                  label: 'INSIGHT',
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.settings,
                  label: 'SYSTEM',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;
    final Color itemColor = isActive ? const Color(0xFF818CF8) : Colors.white.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: isActive
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive ? Colors.white : itemColor, // requested white for Hub active, but then "active item uses indigo-400"
                // Let's use indigo-400 (#818CF8) for all active icons to be consistent, wait prompt says:
                // "Active: white color + drop-shadow" for Hub, "Active: indigo-400 + drop-shadow" for Insight.
                // Let's just use indigo-400 for both to be consistent with the "Active indicator: Color change only... active item uses indigo-400" rule at bottom.
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 10,
                fontWeight: FontWeight.w500, // font-medium
                letterSpacing: -0.5, // tracking-tighter
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
