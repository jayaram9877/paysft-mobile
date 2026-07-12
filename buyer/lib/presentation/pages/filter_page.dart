import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../providers/filter_provider.dart';
import '../widgets/filter/segmented_control.dart';
import '../widgets/common/app_svg_icon.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double _currentSize = 0.65;
  final DraggableScrollableController _draggableController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(() {
      setState(() {
        _currentSize = _draggableController.size;
      });
    });
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  bool get _isFullScreen => _currentSize >= 0.95;

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final filterProvider = context.watch<FilterProvider>();
    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;

    // Calculate max size accounting for safe area - prevents overlap with status bar
    final availableHeight = screenHeight - safeAreaTop;
    final maxSize = availableHeight / screenHeight;

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: maxSize.clamp(0.5, 0.99),
      builder: (context, scrollController) {
        return Padding(
          padding: _isFullScreen
              ? EdgeInsets.only(top: safeAreaTop)
              : const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ClipRRect(
            borderRadius: _isFullScreen ? BorderRadius.zero : const BorderRadius.all(Radius.circular(24)),
            child: Container(
              color: AppColors.backgroundWhite,
              child: Column(
                children: [
                  _buildHeader(context, themeManager, filterProvider, scrollController),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        _buildLookingForSection(themeManager, filterProvider),
                        const SizedBox(height: 24),
                        _buildCategorySection(themeManager, filterProvider),
                        const SizedBox(height: 24),
                        _buildPriceRangeSection(themeManager, filterProvider),
                        const SizedBox(height: 24),
                        _buildBedRoomsSection(themeManager, filterProvider),
                        const SizedBox(height: 24),
                        _buildAreaSection(themeManager, filterProvider),
                        const SizedBox(height: 24),
                        _buildPlotAreaSection(themeManager, filterProvider),
                      ],
                    ),
                  ),
                  _buildFooter(context, themeManager, filterProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeManager themeManager,
    FilterProvider filterProvider,
    ScrollController scrollController,
  ) {
    if (_isFullScreen) {
      // Full screen mode: App bar with "< Filters" on left and "Reset Filters" on right
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          // Allow dragging down to collapse
          if (details.delta.dy > 0) {
            final delta = details.delta.dy / MediaQuery.of(context).size.height;
            final newSize = (_currentSize - delta).clamp(0.5, 1.0);
            _draggableController.jumpTo(newSize);
          }
        },
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _draggableController.animateTo(
                      0.65,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textBlack),
                        const SizedBox(width: 4),
                        Text(AppStrings.filters, style: themeManager.filterTitleFullScreenStyle),
                      ],
                    ),
                  ),
                  _buildResetFiltersButton(themeManager, filterProvider),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Bottom popup mode: Drag handle, title, and reset button - all draggable
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          // Allow dragging from anywhere in the header area
          final delta = -details.delta.dy / MediaQuery.of(context).size.height;
          final newSize = (_currentSize + delta).clamp(0.5, 1.0);
          _draggableController.jumpTo(newSize);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
              ),
              // Title and Reset button - both in draggable area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(AppStrings.filters, style: themeManager.filterTitleBottomPopupStyle)),
                  _buildResetFiltersButton(themeManager, filterProvider),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildResetFiltersButton(ThemeManager themeManager, FilterProvider filterProvider) {
    return GestureDetector(
      onTap: filterProvider.resetFilters,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 115,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrayMedium, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Text(AppStrings.resetFilters, style: themeManager.resetFiltersButtonTextStyle)),
      ),
    );
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Widget _buildLookingForSection(ThemeManager themeManager, FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.lookingFor, style: themeManager.filterSectionTitleStyle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCheckboxOption(
                themeManager,
                AppStrings.residential,
                filterProvider.filterModel.isResidential,
                () => filterProvider.setResidential(!filterProvider.filterModel.isResidential),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCheckboxOption(
                themeManager,
                AppStrings.commercial,
                filterProvider.filterModel.isCommercial,
                () => filterProvider.setCommercial(!filterProvider.filterModel.isCommercial),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(ThemeManager themeManager, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueInfoLight : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.blueInfo : AppColors.borderGrayLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blueInfo : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isSelected ? AppColors.blueInfo : AppColors.borderGrayMedium, width: 2),
              ),
              child: isSelected ? Icon(Icons.check, color: AppColors.textWhite, size: 14) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_capitalizeWords(label), style: themeManager.residentialCommercialTextStyle)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(ThemeManager themeManager, FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.category, style: themeManager.filterSectionTitleStyle),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.2,
          children: [
            _buildCategoryChip(themeManager, AppStrings.categoryHouse, filterProvider),
            _buildCategoryChip(themeManager, AppStrings.categoryApartment, filterProvider),
            _buildCategoryChip(themeManager, AppStrings.categoryVilla, filterProvider),
            _buildCategoryChip(themeManager, AppStrings.studioApartment, filterProvider),
            _buildCategoryChip(themeManager, AppStrings.duplexHomes, filterProvider),
            _buildCategoryChip(themeManager, AppStrings.penthouse, filterProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(ThemeManager themeManager, String label, FilterProvider filterProvider) {
    final isSelected = filterProvider.filterModel.selectedCategory == label;
    final iconPath = _getCategoryIconPath(label);

    return GestureDetector(
      onTap: () => filterProvider.setCategory(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.blueInfoSelected : AppColors.borderGrayLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 12), // Left spacing
            AppSvgIcon(
              assetPath: iconPath,
              width: 24,
              height: 24,
              color: isSelected ? AppColors.blueInfoSelected : AppColors.textDarkSecondary,
            ),
            const SizedBox(width: 8), // Gap to label
            Expanded(
              child: Text(
                _capitalizeWords(label),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isSelected ? themeManager.categoryChipTextSelectedStyle : themeManager.categoryChipTextUnselectedStyle,
              ),
            ),
            const SizedBox(width: 12), // Right spacing to balance
          ],
        ),
      ),
    );
  }

  String _getCategoryIconPath(String category) {
    // Normalize category name for matching
    final normalizedCategory = category.toLowerCase().trim();

    if (normalizedCategory == 'house') {
      return 'assets/images/filter_cat_house.svg';
    } else if (normalizedCategory == 'apartment') {
      return 'assets/images/filter_cat_apartment.svg';
    } else if (normalizedCategory == 'villa') {
      return 'assets/images/filter_cat_villa.svg';
    } else if (normalizedCategory.contains('studio')) {
      return 'assets/images/filter_cat_studio_apartment.svg';
    } else if (normalizedCategory.contains('duplex')) {
      return 'assets/images/filter_cat_duplex.svg';
    } else if (normalizedCategory == 'penthouse') {
      return 'assets/images/fliter_cat_penthouse.svg';
    } else {
      return 'assets/images/filter_cat_house.svg'; // Default fallback
    }
  }

  Widget _buildPriceRangeSection(ThemeManager themeManager, FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.priceRange, style: themeManager.filterSectionTitleStyle),
            Text(AppStrings.avgPriceIs20L, style: themeManager.avgPriceTextStyle),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            SizedBox(
              height: 60,
              width: double.infinity,
              child: CustomPaint(painter: _PriceChartPainter(rangeValues: filterProvider.filterModel.priceRange)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: const EdgeInsets.all(4),
              child: SfRangeSliderTheme(
                data: SfRangeSliderThemeData(
                  activeTrackHeight: 20,
                  inactiveTrackHeight: 20,
                  activeTrackColor: AppColors.backgroundWhite,
                  inactiveTrackColor: AppColors.backgroundGrayLight,
                  overlayRadius: 0,
                  thumbColor: AppColors.blueInfo,
                  tooltipBackgroundColor: AppColors.blueInfo,
                ),
                child: SfRangeSlider(
                  min: 0.2,
                  max: 100.0,
                  values: filterProvider.filterModel.priceRange,
                  onChanged: (values) {
                    filterProvider.setPriceRange(values);
                  },
                  thumbShape: _SfThumbShape(),
                  enableTooltip: true,
                  edgeLabelPlacement: EdgeLabelPlacement.inside,
                  shouldAlwaysShowTooltip: false,
                  labelPlacement: LabelPlacement.betweenTicks,
                  labelFormatterCallback: (actualValue, formattedText) {
                    if (actualValue < 1.0) {
                      return '${(actualValue * 10).round()}L';
                    }
                    return '${actualValue.round()} Cr';
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.price20L, style: themeManager.priceRangeLabelStyle, textAlign: TextAlign.right),
                  Text(AppStrings.price100Cr, style: themeManager.priceRangeLabelStyle, textAlign: TextAlign.right),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBedRoomsSection(ThemeManager themeManager, FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.bedRooms, style: themeManager.filterSectionTitleStyle),
        const SizedBox(height: 12),
        SegmentedControl(
          tabs: [AppStrings.any, '1', '2', '3', '4', '5'],
          selectedTab: filterProvider.filterModel.selectedBedrooms,
          onTabChanged: filterProvider.setBedrooms,
        ),
      ],
    );
  }

  Widget _buildAreaSection(ThemeManager themeManager, FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.areaSqft, style: themeManager.filterSectionTitleStyle),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDropdown(themeManager, [AppStrings.min, '1000', '2000'], AppStrings.min)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('-', style: TextStyle(color: AppColors.gray500)),
            ),
            Expanded(child: _buildDropdown(themeManager, [AppStrings.max, '3000', '4000'], AppStrings.max)),
          ],
        ),
      ],
    );
  }

  Widget _buildPlotAreaSection(ThemeManager themeManager, FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.plotAreaSqft, style: themeManager.filterSectionTitleStyle),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDropdown(themeManager, [AppStrings.min, '1000', '2000'], AppStrings.min)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('-', style: TextStyle(color: AppColors.gray500)),
            ),
            Expanded(child: _buildDropdown(themeManager, [AppStrings.max, '3000', '4000'], AppStrings.max)),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(ThemeManager themeManager, List<String> items, String initialValue) {
    return DropdownButtonFormField<String>(
      value: initialValue,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: themeManager.bodyStyle),
        );
      }).toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundGrayMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeManager themeManager, FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => filterProvider.cancel(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
                side: BorderSide(color: AppColors.blueInfo, width: 1),
              ),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.blueInfo, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryGradientButton(text: AppStrings.apply, onTap: () => filterProvider.applyFilters(context)),
          ),
        ],
      ),
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  final SfRangeValues rangeValues;

  const _PriceChartPainter({required this.rangeValues});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final double barWidth = size.width / 45;
    final double maxBarHeight = size.height;

    for (int i = 0; i < 45; i++) {
      final barHeight = (math.sin(i * 0.5) + 1.5) * maxBarHeight / 3;
      final startX = i * barWidth;
      final startY = size.height - barHeight;

      final bool isInRange = (i / 45 * 100) >= rangeValues.start && (i / 45 * 100) <= rangeValues.end;
      paint.color = isInRange ? AppColors.backgroundBlueSelectedLight : AppColors.backgroundBlueSelectedVeryLight;

      final rect = Rect.fromLTWH(startX, startY, barWidth - 4, barHeight);
      final rRect = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular((barWidth - 4) / 2),
        topRight: Radius.circular((barWidth - 4) / 2),
      );
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PriceChartPainter oldDelegate) {
    return oldDelegate.rangeValues != rangeValues;
  }
}

class _SfThumbShape extends SfThumbShape {
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox? child,
    dynamic currentValue,
    SfRangeValues? currentValues,
    required Animation<double> enableAnimation,
    required Paint? paint,
    required RenderBox parentBox,
    required TextDirection textDirection,
    required SfSliderThemeData themeData,
    required SfThumb? thumb,
  }) {
    final Canvas canvas = context.canvas;

    final outerCirclePaint = Paint()
      ..color = AppColors.backgroundWhite
      ..style = PaintingStyle.fill;

    final innerCirclePaint = Paint()
      ..color = themeData.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 10, outerCirclePaint);
    canvas.drawCircle(center, 6, innerCirclePaint);
  }
}
