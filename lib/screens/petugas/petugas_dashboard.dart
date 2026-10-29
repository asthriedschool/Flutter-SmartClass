import 'package:flutter/material.dart';

import '../../shared/app_colors.dart';
import '../../shared/widgets/organisms/smart_bottom_nav.dart';
import '../admin/room_page.dart';
import '../profile/profile_page.dart';
import '../schedule/schedule_page.dart';

class PetugasDashboard extends StatelessWidget {
  const PetugasDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const Expanded(
            child: SafeArea(
              child: Center(
                child: Text(
                  'Area petugas',
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            ),
          ),
          SmartBottomNav(
            currentIndex: 0,
            items: adminBottomNavItems,
            onSelected: (index) {
              if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RoomPage(),
                  ),
                );
                return;
              }
              if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SchedulePage(),
                  ),
                );
                return;
              }
              if (index == 3) {
                ProfilePage.open(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
