import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../providers/main_tab_controller.dart';
import '../widgets/common/app_svg_icon.dart';
import 'home_page.dart';
import 'list_page.dart';
import 'profile_page.dart';
import 'schedule_page.dart';

class _TabItem {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  const _TabItem(this.label, this.activeIcon, this.inactiveIcon);
}

class MainTabPage extends StatelessWidget {
  const MainTabPage({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    ListPage(),
    SchedulePage(),
    _ComingSoonTab('Chat', Icons.chat_bubble_outline),
    ProfilePage(),
  ];

  static const List<_TabItem> _tabs = [
    _TabItem(AppStrings.tabHome, 'assets/images/home_active.svg',
        'assets/images/home_inactive.svg'),
    _TabItem(AppStrings.tabExplore, 'assets/images/list_active.svg',
        'assets/images/list_inactive.svg'),
    _TabItem(AppStrings.tabFavorites, 'assets/images/schedule_active.svg',
        'assets/images/schedule_inactive.svg'),
    _TabItem(AppStrings.tabChat, 'assets/images/chat_active.svg',
        'assets/images/chat_inactive.svg'),
    _TabItem(AppStrings.tabProfile, 'assets/images/profile_active.svg',
        'assets/images/profile-inactive.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = context.watch<MainTabController>();
    final currentIndex = tab.index;
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => context.read<MainTabController>().setIndex(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.backgroundWhite,
            elevation: 0,
            selectedItemColor: AppColors.bluePrimary,
            unselectedItemColor: AppColors.textDarkSecondary,
            selectedLabelStyle:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            unselectedLabelStyle:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            items: _tabs.map((tab) {
              Widget iconWidget(String asset) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      AppSvgIcon(assetPath: asset, width: 24, height: 24),
                      const SizedBox(height: 4),
                    ],
                  );
              return BottomNavigationBarItem(
                icon: iconWidget(tab.inactiveIcon),
                activeIcon: iconWidget(tab.activeIcon),
                label: tab.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ComingSoonTab(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.bluePrimary),
            const SizedBox(height: 12),
            Text(
              '$title — coming soon',
              style: const TextStyle(
                color: AppColors.textGrayLight,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
