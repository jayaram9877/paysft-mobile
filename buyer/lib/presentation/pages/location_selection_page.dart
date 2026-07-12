import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../../domain/entities/location_suggestion.dart';
import '../widgets/common/app_loader_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import 'main_tab_page.dart';
import 'map_location_picker_page.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounceTimer;
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final locationProvider = context.read<LocationProvider>();
    final results = await locationProvider.searchCities(query);

    if (mounted) {
      setState(() {
        _suggestions = results;
      });
    }
  }

  void _onLocationSelected(LocationSuggestion suggestion) async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.updateLocation(
      suggestion.fullName,
      cityName: suggestion.resolveCity,
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
    );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainTabPage()),
        (route) => false,
      );
    }
  }

  Future<void> _onCurrentLocationTap() async {
    final locationProvider = context.read<LocationProvider>();

    // Detect current location (this will request permission if needed)
    await locationProvider.detectCurrentLocation();

    if (!mounted) return;

    // Wait a bit for the location to be detected
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if location was successfully detected
    if (locationProvider.selectedLocation != AppStrings.selectLocation &&
        locationProvider.selectedLocation.isNotEmpty &&
        locationProvider.errorMessage == null &&
        !locationProvider.isDetectingLocation) {
      // Location detected successfully, navigate to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainTabPage()),
        (route) => false,
      );
    } else if (locationProvider.errorMessage != null && !locationProvider.isDetectingLocation) {
      // Show error message with option to open settings if permanently denied
      final snackBar = SnackBar(
        content: Text(locationProvider.errorMessage!),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 4),
        action: locationProvider.errorMessage!.contains('permanently denied')
            ? SnackBarAction(
                label: AppStrings.settings,
                textColor: AppColors.textWhite,
                onPressed: () async {
                  await locationProvider.openLocationSettings();
                },
              )
            : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.selectLocation,
          style: themeManager.titleMediumStyle.copyWith(color: AppColors.textDark),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isFocused ? AppColors.bluePrimary : AppColors.borderGrayLight, width: 1.5),
                color: AppColors.backgroundWhite,
              ),
              child: Row(
                children: [
                  /// Search SVG Icon
                  SvgPicture.asset(
                    'assets/images/search.svg',
                    height: 22,
                    width: 22,
                    colorFilter: ColorFilter.mode(isFocused ? AppColors.bluePrimary : AppColors.gray400, BlendMode.srcIn),
                  ),

                  const SizedBox(width: 10),

                  /// TextField
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        // 🔍 Call city search API here
                      },
                      decoration: InputDecoration(
                        hintText: AppStrings.searchCity,
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: themeManager.bodyStyle.copyWith(color: AppColors.textGrayLight),
                      ),
                      style: themeManager.bodyStyle.copyWith(color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Current Location option
          if (_searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: locationProvider.isDetectingLocation ? null : _onCurrentLocationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  decoration: BoxDecoration(
                    color: locationProvider.isDetectingLocation ? AppColors.gray100 : AppColors.backgroundGrayLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: locationProvider.isDetectingLocation ? AppColors.borderGrayLight : AppColors.borderGrayMedium,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (locationProvider.isDetectingLocation)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
                          ),
                        )
                      else
                        const Icon(Icons.my_location, color: AppColors.bluePrimary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          locationProvider.isDetectingLocation ? AppStrings.detectingLocation : AppStrings.useCurrentLocation,
                          style: themeManager.bodyMediumStyle.copyWith(
                            color: locationProvider.isDetectingLocation ? AppColors.gray600 : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Choose on an interactive OpenStreetMap map
          if (_searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MapLocationPickerPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrayLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGrayMedium, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: AppColors.bluePrimary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Choose on map',
                          style: themeManager.bodyMediumStyle.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
                    ],
                  ),
                ),
              ),
            ),

          if (_searchController.text.isEmpty) const SizedBox(height: 16),

          // Loading indicator or results
          Expanded(
            child: locationProvider.isLoading
                ? const Center(child: AppLoaderWidget())
                : _suggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined, size: 64, color: AppColors.gray300),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty ? AppStrings.startTypingToSearch : AppStrings.noResultsFound,
                          style: themeManager.bodyStyle.copyWith(color: AppColors.gray600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return _buildLocationItem(suggestion);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(LocationSuggestion suggestion) {
    return InkWell(
      onTap: () => _onLocationSelected(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEBEBF0), width: 1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Color(0xFF0A68FF), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: const TextStyle(color: Color(0xFF1F2A37), fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (suggestion.subtitle.isNotEmpty) const SizedBox(height: 4),
                  if (suggestion.subtitle.isNotEmpty)
                    Text(
                      suggestion.subtitle,
                      style: const TextStyle(color: Color(0xFF9DA4AE), fontSize: 14),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9DA4AE), size: 20),
          ],
        ),
      ),
    );
  }
}
