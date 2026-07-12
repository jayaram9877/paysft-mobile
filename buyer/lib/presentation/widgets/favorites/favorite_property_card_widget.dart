import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/property_model.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../widgets/common/app_svg_icon.dart';

class FavoritePropertyCardWidget extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMenuTap;
  final List<String> imageUrls; // Multiple images for carousel
  final bool hideFavIcon;

  /// When false, card content is not wrapped in SingleChildScrollView (e.g. when inside a ListView).
  final bool scrollableContent;

  FavoritePropertyCardWidget({
    super.key,
    required this.property,
    this.onTap,
    this.onFavoriteTap,
    this.onMenuTap,
    this.hideFavIcon = false,
    this.scrollableContent = true,
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [property.imageUrl];

  @override
  State<FavoritePropertyCardWidget> createState() => _FavoritePropertyCardWidgetState();
}

class _FavoritePropertyCardWidgetState extends State<FavoritePropertyCardWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40; // 20px padding on each side

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: cardWidth,
        height: widget.scrollableContent ? 362 : null,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: _buildCardContent(themeManager, cardWidth),
      ),
    );
  }

  Widget _buildCardContent(ThemeManager themeManager, double cardWidth) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image carousel with favorite icon and menu (16px padding left, right, top)
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: cardWidth - 32,
                  height: 232,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrls[index],
                          width: cardWidth - 32,
                          height: 232,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Icons overlay (stacked vertically in the top right)
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.hideFavIcon)
                    GestureDetector(
                      onTap: widget.onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                      ),
                    ),
                  if (widget.onMenuTap != null) const SizedBox(height: 8),
                  if (widget.onMenuTap != null)
                    GestureDetector(
                      onTap: widget.onMenuTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                      ),
                    ),
                ],
              ),
            ), // Positioned
            // Page indicator (only show if multiple images)
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.bluePrimary : Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ), // Stack
        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.property.title,
                      style: themeManager.headingStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppSvgIcon(assetPath: 'assets/images/badge.svg', width: 24, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlueVeryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.propertyTagTrilight,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bluePrimary),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  AppSvgIcon(assetPath: 'assets/images/location.svg', width: 18, height: 18, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.property.location,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    if (widget.scrollableContent) {
      return SingleChildScrollView(child: column);
    }
    return column;
  }
}
