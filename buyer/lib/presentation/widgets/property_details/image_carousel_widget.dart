import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';
import '../common/app_svg_icon.dart';
import '../../pages/web_view_page.dart';

class ImageCarouselWidget extends StatefulWidget {
  final List<String> images;

  const ImageCarouselWidget({super.key, required this.images});

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  final themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 232,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.gray300,
                      child: Icon(Icons.image_not_supported, size: 64, color: AppColors.gray600),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Linear gradient overlay at the bottom for page indicator visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.overlayBlack40],
              ),
            ),
          ),
        ),
        // Page indicator dots positioned at the bottom
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (dotIndex) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotIndex == _currentPage ? AppColors.bluePrimary : AppColors.textWhite,
                ),
              ),
            ),
          ),
        ),
        // AR/VR button positioned at the bottom-right of the big image
        Positioned(
          right: 12,
          bottom: 10,
          child: InkWell(
            key: const Key('arvr_button'),
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const WebViewPage(title: AppStrings.termsConditions, url: 'https://paysfttest.neusix.ai/'),
                ),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(2),
              child: const AppSvgIcon(assetPath: 'assets/images/arvr.svg', width: 32, height: 32),
            ),
          ),
        ),
      ],
    );
  }
}
