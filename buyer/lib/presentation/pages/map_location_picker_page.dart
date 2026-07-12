import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/services/location_service.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/location_suggestion.dart';
import '../providers/location_provider.dart';
import 'main_tab_page.dart';

/// Interactive OpenStreetMap location picker: pan the map under the fixed pin,
/// search for a city, or use the current GPS location. The centre of the map is
/// reverse-geocoded (OSM Nominatim) into a city label, which is resolved to a
/// backend city id when confirmed.
class MapLocationPickerPage extends StatefulWidget {
  const MapLocationPickerPage({super.key});

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Default to Hyderabad (the backend catalog is India-centric).
  static const LatLng _defaultCenter = LatLng(17.385044, 78.486671);

  late LatLng _center;
  late double _initialZoom;
  String? _label;
  String? _resolveCity; // city name used to resolve the backend city id
  bool _resolving = false;
  bool _locating = false;

  Timer? _reverseDebounce;
  Timer? _searchDebounce;
  List<LocationSuggestion> _results = const [];

  @override
  void initState() {
    super.initState();
    // Reopen at the last picked pin, if any.
    final loc = context.read<LocationProvider>();
    final lat = loc.selectedLatitude;
    final lng = loc.selectedLongitude;
    final hasSaved = lat != null && lng != null;
    _center = hasSaved ? LatLng(lat, lng) : _defaultCenter;
    _initialZoom = hasSaved ? 13 : 11;
    if (hasSaved) _label = loc.selectedLocation;

    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reverseGeocode(_center));
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    if (!hasGesture) return;
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocode(_center);
    });
  }

  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() => _resolving = true);
    final label = await context
        .read<LocationProvider>()
        .cityNameForCoordinates(point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      _label = label;
      // Reverse geocode returns "City, State" — the city is the first component.
      _resolveCity = label?.split(',').first.trim();
      _resolving = false;
    });
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _results = const []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await context.read<LocationProvider>().searchCities(query);
      if (mounted) setState(() => _results = results);
    });
  }

  void _onResultTap(LocationSuggestion s) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() {
      _results = const [];
      _label = s.fullName;
      _resolveCity = s.resolveCity;
    });
    final target = LatLng(s.latitude, s.longitude);
    _center = target;
    _mapController.move(target, 12);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final position = await di.sl<LocationService>().getCurrentPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get your current location.')),
          );
        }
        return;
      }
      final target = LatLng(position.latitude, position.longitude);
      _center = target;
      _mapController.move(target, 13);
      await _reverseGeocode(target);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirm() async {
    final display = (_label != null && _label!.isNotEmpty) ? _label! : 'Selected location';
    final cityName = (_resolveCity != null && _resolveCity!.isNotEmpty)
        ? _resolveCity!
        : display.split(',').first.trim();

    setState(() => _resolving = true);
    await context.read<LocationProvider>().updateLocation(
          display,
          cityName: cityName,
          latitude: _center.latitude,
          longitude: _center.longitude,
        );
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainTabPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager();

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
          'Choose location',
          style: theme.titleMediumStyle.copyWith(color: AppColors.textDark),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // The map fills the screen; the pin is a fixed screen-centre overlay.
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _initialZoom,
              minZoom: 3,
              maxZoom: 18,
              onPositionChanged: _onPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.buyer',
                maxZoom: 19,
              ),
            ],
          ),

          // Fixed centre pin (offset up by half its height so the tip marks the point).
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: const Icon(Icons.location_on, size: 44, color: AppColors.bluePrimary),
              ),
            ),
          ),

          // Search bar + results overlaying the top of the map.
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: _buildSearch(theme),
          ),

          // Use-current-location button.
          Positioned(
            right: 16,
            bottom: 168,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              backgroundColor: AppColors.backgroundWhite,
              foregroundColor: AppColors.bluePrimary,
              onPressed: _locating ? null : _useCurrentLocation,
              child: _locating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bluePrimary),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Bottom confirmation card.
          Positioned(left: 16, right: 16, bottom: 24, child: _buildConfirmCard(theme)),
        ],
      ),
    );
  }

  Widget _buildSearch(ThemeManager theme) {
    return Column(
      children: [
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.gray400, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search city',
                      border: InputBorder.none,
                      isDense: true,
                      hintStyle: theme.bodyStyle.copyWith(color: AppColors.textGrayLight),
                    ),
                    style: theme.bodyStyle.copyWith(color: AppColors.textDark),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _results = const []);
                    },
                    child: const Icon(Icons.close, color: AppColors.gray400, size: 20),
                  ),
              ],
            ),
          ),
        ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 260),
            child: Material(
              elevation: 4,
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEBEBF0)),
              itemBuilder: (context, i) {
                final s = _results[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.bluePrimary, size: 22),
                  title: Text(s.title, style: theme.bodyMediumStyle.copyWith(color: AppColors.textDark)),
                  subtitle: s.subtitle.isNotEmpty
                      ? Text(
                          s.subtitle,
                          style: theme.captionSmallStyle.copyWith(color: AppColors.textGrayLight),
                        )
                      : null,
                  onTap: () => _onResultTap(s),
                );
              },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmCard(ThemeManager theme) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: AppColors.bluePrimary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: _resolving
                      ? Text('Locating…', style: theme.bodyMediumStyle.copyWith(color: AppColors.textGrayLight))
                      : Text(
                          _label ?? 'Move the map to pick a spot',
                          style: theme.bodyMediumStyle.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_resolving || _label == null) ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Confirm location',
                  style: theme.bodyMediumStyle.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
