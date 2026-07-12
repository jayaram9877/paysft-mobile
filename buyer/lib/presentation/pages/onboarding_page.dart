import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../domain/entities/onboarding_content.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/common/app_loader_widget.dart';
import 'phone_login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPage extends StatefulWidget {
  final bool forceUpdate;

  const OnboardingPage({super.key, this.forceUpdate = false});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _fallbackPages = const [
    OnboardingContent(
      fullText: 'Find best place to stay in good price',
      highlightedText: ' good price',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed.',
      imageUrl:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    ),
    OnboardingContent(
      fullText: 'Fast sell your property in just one click',
      highlightedText: ' one click',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed.',
      imageUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
    ),
    OnboardingContent(
      fullText: 'Find perfect choice for your future',
      highlightedText: ' perfect choice',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed.',
      imageUrl:
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OnboardingProvider>().fetchOnboardingContent();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(List<OnboardingContent> pages) {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() => _navigateToLogin();

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PhoneLoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final hasApiContent = onboardingProvider.items.isNotEmpty;
    final pages = hasApiContent ? onboardingProvider.items : _fallbackPages;

    if (_currentPage >= pages.length && pages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentPage = pages.length - 1);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Mini Logo (SVG)
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/color_logo.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),

                  // ),
                  if (!widget.forceUpdate)
                    TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        backgroundColor: themeManager.cardLight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: AppColors.borderDivider,
                          ),
                        ),
                      ),
                      child: Text(
                        AppStrings.skip,
                        style: themeManager.labelStyle.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 56),
                ],
              ),
            ),

            // 🔹 Page view with overlay components
            Expanded(
              child:
                  onboardingProvider.status == OnboardingStatus.loading &&
                      !hasApiContent
                  ? const Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: AppLoaderWidget(),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemCount: pages.length,
                          itemBuilder: (context, index) =>
                              _buildPage(themeManager, pages[index]),
                        ),

                        // 🔹 Dot Indicator Overlay
                        Positioned(
                          bottom: 140,
                          child: Row(
                            children: List.generate(
                              pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentPage == index ? 10 : 6,
                                height: _currentPage == index ? 10 : 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.backgroundWhite
                                      : AppColors.overlayWhite40,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Floating Glass Buttons (Separated + Next with > icon)
                        Positioned(
                          bottom: 40,
                          child: Row(
                            children: [
                              // 🔹 Previous Button (Circle Glass)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: GestureDetector(
                                    onTap: _currentPage > 0
                                        ? () => _pageController.previousPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          )
                                        : null,
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.overlayWhite25,
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                          color: AppColors.overlayWhite30,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 18,
                                        color: _currentPage > 0
                                            ? AppColors.backgroundWhite
                                            : AppColors.overlayWhite30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // 🔹 Next Button (Rounded Rectangle + Arrow Icon)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _nextPage(pages),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.overlayWhite20,
                                            AppColors.overlayWhite05,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                      ),

                                      child: Row(
                                        children: [
                                          Text(
                                            _currentPage == pages.length - 1
                                                ? AppStrings.finish
                                                : AppStrings.next,
                                            style: themeManager.titleMediumStyle
                                                .copyWith(
                                                  color:
                                                      AppColors.backgroundWhite,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.backgroundWhite,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(ThemeManager themeManager, OnboardingContent item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          buildRichText(themeManager, item.fullText, item.highlightedText),

          const SizedBox(height: 12),

          Text(
            item.description,
            style: themeManager.bodyStyle.copyWith(
              color: AppColors.textTertiaryLight,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildOnboardingImage(item.imageUrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingImage(String imageUrl) {
    final isRemote =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isRemote) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    final normalized = imageUrl.trim();
    final hasExtension = normalized.contains('.');
    final assetPath = hasExtension
        ? 'assets/images/$normalized'
        : 'assets/images/$normalized.png';
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.backgroundGrayLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 34,
        color: AppColors.textGrayMedium,
      ),
    );
  }

  Widget buildRichText(
    ThemeManager themeManager,
    String fullText,
    String highlight,
  ) {
    final index = fullText.toLowerCase().indexOf(highlight.toLowerCase());

    if (index == -1) {
      return Text(
        fullText,
        style: themeManager.headingStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: AppColors.textPrimaryDark,
        ),
      );
    }

    final before = fullText.substring(0, index).trimRight();
    final highlighted = fullText.substring(index, index + highlight.length);
    final after = fullText.substring(index + highlight.length).trimLeft();

    return RichText(
      text: TextSpan(
        style: themeManager.headingStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: AppColors.textPrimaryDark,
        ),
        children: [
          TextSpan(text: before),

          /// Highlight with richer purple gradient
          WidgetSpan(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primaryCyan,
                  AppColors.primaryCyan,
                  AppColors.primaryPurpleBright,
                  AppColors.primaryPurpleBright,
                  AppColors.primaryPurpleDark,
                ],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                highlighted,
                style: themeManager.headingStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.backgroundWhite, // Needed for ShaderMask
                ),
              ),
            ),
          ),

          if (after.isNotEmpty) TextSpan(text: " $after"),
        ],
      ),
    );
  }
}
