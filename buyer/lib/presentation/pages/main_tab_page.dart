import 'package:buyer/presentation/pages/location_selection_page.dart';
import 'package:buyer/presentation/pages/select_location_type_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'favorites_page.dart';
import 'chat_list_page.dart';
import 'profile_page.dart';
import '../providers/location_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../widgets/common/app_svg_icon.dart';
import '../providers/saved_units_provider.dart';
import '../providers/lead_provider.dart';

class MainTabPage extends StatefulWidget {
  final int? initialIndex;

  /// When navigating to the Explore tab from a home category, pre-filter it by
  /// this `project_subtype` (e.g. 'apartment').
  final String? initialCategorySubtype;
  final String? initialCategoryLabel;

  const MainTabPage({
    super.key,
    this.initialIndex,
    this.initialCategorySubtype,
    this.initialCategoryLabel,
  });

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;
  bool _hasInitializedLocation = false;

  late final List<Widget> _pages = [
    const HomePage(),
    ExplorePage(
      initialSubtype: widget.initialCategorySubtype,
      initialCategoryLabel: widget.initialCategoryLabel,
    ),
    const FavoritesPage(),
    const ChatListPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    _currentIndex = widget.initialIndex ?? 0;
    super.initState();
    // Trigger location detection when MainTabPage is first shown (after OTP verification)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitializedLocation) {
        final locationProvider = context.read<LocationProvider>();

        Future.delayed(Duration(milliseconds: 200), () {
          /*if (locationProvider.selectedLocation == AppStrings.selectLocation ||
              locationProvider.selectedLocation.isEmpty) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectLocatioTypePage()));
          }*/

          _hasInitializedLocation = true;

          // Check if we need to detect location
          if (locationProvider.selectedLocation == AppStrings.selectLocation ||
              locationProvider.selectedLocation.isEmpty) {
            locationProvider.detectCurrentLocation();
          }
        });
      }
    });
  }

  final List<_TabItem> _tabs = [
    _TabItem(
      label: AppStrings.tabHome,
      activeIcon: 'assets/images/home_active.svg',
      inactiveIcon: 'assets/images/home_inactive.svg',
    ),
    _TabItem(
      label: AppStrings.tabExplore,
      activeIcon: 'assets/images/explore_active.svg',
      inactiveIcon: 'assets/images/explore_inactive.svg',
    ),
    _TabItem(
      label: AppStrings.tabFavorites,
      activeIcon: 'assets/images/favorites_active.svg',
      inactiveIcon: 'assets/images/favorites_inactive.svg',
    ),
    _TabItem(
      label: AppStrings.tabChat,
      activeIcon: 'assets/images/chat_active.svg',
      inactiveIcon: 'assets/images/chat_inactive.svg',
    ),
    _TabItem(
      label: AppStrings.tabProfile,
      activeIcon: 'assets/images/profile_active.svg',
      inactiveIcon: 'assets/images/profile-inactive.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Refresh favorites (saved + interested) each time it's opened.
              if (index == 2) {
                context.read<SavedUnitsProvider>().reload();
                context.read<LeadProvider>().reload();
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.backgroundWhite,
            elevation: 0,
            selectedItemColor: AppColors.bluePrimary,
            unselectedItemColor: AppColors.textDarkSecondary,
            selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
            items: _tabs.map((tab) {
              final index = _tabs.indexOf(tab);
              final isSelected = _currentIndex == index;

              Widget iconWidget(String asset) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    AppSvgIcon(assetPath: asset, width: 24, height: 24),
                    const SizedBox(height: 4),
                  ],
                );
              }

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

class _TabItem {
  final String label;
  final String activeIcon;
  final String inactiveIcon;

  _TabItem({required this.label, required this.activeIcon, required this.inactiveIcon});
}
