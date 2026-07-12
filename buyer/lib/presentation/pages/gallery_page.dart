import 'package:flutter/material.dart';
import '../../domain/entities/property_details_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/property_details/full_screen_media_viewer.dart';

class GalleryPage extends StatefulWidget {
  final PropertyDetailsModel property;

  const GalleryPage({super.key, required this.property});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(
          AppStrings.gallery,
          style: themeManager.titleMediumStyle.copyWith(color: AppColors.textBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.tabSelectionColor,
          unselectedLabelColor: AppColors.gray400,
          indicatorColor: AppColors.primaryPurple,
          indicatorWeight: 2,
          tabs: [
            Tab(text: AppStrings.all),
            Tab(text: AppStrings.floorPlans),
            Tab(text: AppStrings.videos),
            Tab(text: AppStrings.arvr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAllTab(), _buildFloorPlansTab(), _buildVideosTab(), _buildArVrTab()],
      ),
    );
  }

  Widget _buildAllTab() {
    final categories = [
      _GalleryCategory(name: AppStrings.livingRoom, count: 10, images: widget.property.galleryFullImages),
      _GalleryCategory(name: AppStrings.kitchen, count: 10, images: widget.property.galleryFullImages),
      _GalleryCategory(name: AppStrings.bedroom, count: 10, images: widget.property.galleryFullImages),
      _GalleryCategory(name: AppStrings.parking, count: 10, images: widget.property.galleryFullImages),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategorySection(category);
      },
    );
  }

  Widget _buildFloorPlansTab() {
    final themeManager = ThemeManager();
    return Center(
      child: Text(AppStrings.floorPlans, style: themeManager.bodyStyle.copyWith(color: AppColors.gray600)),
    );
  }

  Widget _buildVideosTab() {
    final themeManager = ThemeManager();
    return Center(
      child: Text(AppStrings.videos, style: themeManager.bodyStyle.copyWith(color: AppColors.gray600)),
    );
  }

  Widget _buildArVrTab() {
    final themeManager = ThemeManager();
    return Center(
      child: Text(
        AppStrings.arvr,
        key: const Key('arvr_empty_label'),
        style: themeManager.bodyStyle.copyWith(color: AppColors.gray600),
      ),
    );
  }

  Widget _buildCategorySection(_GalleryCategory category) {
    final themeManager = ThemeManager();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                style: themeManager.titleMediumStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text('${category.count}', style: themeManager.bodySmallStyle.copyWith(color: AppColors.gray600)),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: category.images.length > 4 ? 4 : category.images.length,
          itemBuilder: (context, index) {
            final isLast = index == 3 && category.images.length > 4;
            final remainingCount = category.images.length - 4;
            return GestureDetector(
              key: ValueKey('gallery_thumbnail_${category.name}_$index'),
              onTap: () {
                // Open full-screen viewer
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullScreenMediaViewer(
                      mediaUrls: category.images,
                      initialIndex: index,
                      categoryName: category.name,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      category.images[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: AppColors.grey300, child: const Icon(Icons.image, size: 24));
                      },
                    ),
                  ),
                  if (isLast)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          // Open full-screen viewer showing all images
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FullScreenMediaViewer(
                                mediaUrls: category.images,
                                initialIndex: 4, // Start from the 5th item (index 4)
                                categoryName: category.name,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.textBlack.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+$remainingCount',
                              style: ThemeManager().labelStyle.copyWith(
                                color: AppColors.textWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _GalleryCategory {
  final String name;
  final int count;
  final List<String> images;

  _GalleryCategory({required this.name, required this.count, required this.images});
}
