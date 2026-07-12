import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_details_model.dart';
import '../common/app_svg_icon.dart';
import 'document_card.dart';
import 'description_section.dart';
import 'dotted_vertical_divider.dart';
import '../../pages/gallery_page.dart';
import '../../pages/document_viewer_page.dart';
import '../../pages/agent_profile_page.dart';
import '../../pages/web_view_page.dart';
import 'full_screen_media_viewer.dart';
import '../../providers/property_details_provider.dart';
import 'related_properties_section.dart';

/// Land details view widget for land properties
/// Follows the existing architecture pattern with theme-aware design
class LandDetailsView extends StatefulWidget {
  final PropertyDetailsModel property;
  final PropertyDetailsProvider provider;
  final ThemeManager themeManager;

  const LandDetailsView({super.key, required this.property, required this.provider, required this.themeManager});

  @override
  State<LandDetailsView> createState() => _LandDetailsViewState();
}

class _LandDetailsViewState extends State<LandDetailsView> {
  late PageController _pageController;
  int _currentPage = 0;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageAndGallerySection(context),
        _buildContentContainer(context),
        const SizedBox(height: 40), // Bottom spacing
      ],
    );
  }

  Widget _buildImageAndGallerySection(BuildContext context) {
    return Container(
      color: AppColors.backgroundGrayLight,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [_buildImageCarouselWithTags(context), const SizedBox(height: 16), _buildThumbnailGallery(context)],
      ),
    );
  }

  Widget _buildImageCarouselWithTags(BuildContext context) {
    final images = [widget.property.mainImageUrl, ...widget.property.galleryImages];
    final tags = widget.property.imageTags ?? [];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 232,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenMediaViewer(
                          mediaUrls: images,
                          initialIndex: index,
                          categoryName: widget.property.title,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.gray300,
                        child: const Icon(Icons.image_not_supported, size: 64),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        // Tags overlay
        if (tags.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [if (tags.isNotEmpty) _buildTag(tags[0]), if (tags.length > 1) _buildTag(tags[1])],
            ),
          ),
        // Page indicator dots
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage ? AppColors.bluePrimary : AppColors.textWhite,
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
                  builder: (_) => const WebViewPage(
                    title: AppStrings.termsConditions,
                    url: 'https://paysfttest.neusix.ai/',
                  ),
                ),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundWhite,
              ),
              padding: const EdgeInsets.all(2),
              child: const AppSvgIcon(
                assetPath: 'assets/images/arvr.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(PropertyTagModel tag) {
    final backgroundColor = tag.color == 'green' ? AppColors.successGreenLight : AppColors.gray800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: Text(tag.text, style: widget.themeManager.imageTagStyle),
    );
  }

  Widget _buildThumbnailGallery(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.property.galleryImages.length > 4 ? 4 : widget.property.galleryImages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isLast = index == 3 && widget.property.galleryImages.length > 4;
          final remainingCount = widget.property.galleryImages.length - 4;
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryPage(property: widget.property)));
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: Image.network(
                      widget.property.galleryImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: AppColors.gray300, child: const Icon(Icons.image, size: 24));
                      },
                    ),
                  ),
                ),
                if (isLast)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.4],
                          colors: [AppColors.overlayBlack60, Colors.transparent],
                        ),
                      ),
                      child: Center(
                        child: Text('$remainingCount+', style: widget.themeManager.galleryCountOverlaySmallStyle),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyHeader(context),
          _buildAgentCard(context),
          _buildTabBar(),
          _buildTabContent(context),
          RelatedPropertiesSection(properties: widget.property.relatedProperties ?? []),
        ],
      ),
    );
  }

  Widget _buildPropertyHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property ID
          Text('#${widget.property.id}', style: widget.themeManager.propertyIdStyle),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.property.title, style: widget.themeManager.propertyTitleStyle),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlueVeryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.property.subtitle, style: widget.themeManager.propertySubtitleStyle),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.gray700),
                        const SizedBox(width: 4),
                        Text(
                          widget.property.location,
                          style: widget.themeManager.propertyDetailsSubtitleStyle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    if (widget.property.reraId != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          border: Border.all(color: AppColors.borderGrayMedium),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: AppStrings.reraId, style: widget.themeManager.reraIdLabelStyle),
                              TextSpan(text: widget.property.reraId!, style: widget.themeManager.reraIdValueStyle),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.successGreenLight.withOpacity(0.1), shape: BoxShape.circle),
                child: AppSvgIcon(assetPath: 'assets/images/badge.svg', width: 24, height: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(BuildContext context) {
    const double borderWidth = 1;
    const double borderRadius = 16;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundGrayLight,
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          ),
          padding: const EdgeInsets.all(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius - borderWidth),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgentProfilePage(agent: widget.property.agent)),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(widget.property.agent.imageUrl)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.property.agent.name, style: widget.themeManager.agentCardNameStyle),
                        const SizedBox(height: 4),
                        Text(widget.property.agent.role, style: widget.themeManager.agentCardRoleStyle),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.backgroundBlueLight, shape: BoxShape.circle),
                    child: IconButton(
                      icon: AppSvgIcon(assetPath: 'assets/images/agent_call.svg', width: 36, height: 36),
                      onPressed: widget.provider.onCallAgent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.backgroundBlueLight, shape: BoxShape.circle),
                    child: IconButton(
                      icon: AppSvgIcon(assetPath: 'assets/images/agent_message.svg', width: 36, height: 36),
                      onPressed: widget.provider.onMessageAgent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem(AppStrings.overview, 0),
          _buildTabItem(AppStrings.pricing, 1),
          _buildTabItem(AppStrings.documents, 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = widget.provider.selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.provider.onTabChanged(index),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: isSelected ? widget.themeManager.tabBarSelectedStyle : widget.themeManager.tabBarUnselectedStyle,
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blueGradientStart, AppColors.blueGradientEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (widget.provider.selectedTabIndex) {
      case 0:
        return _buildOverviewTab(context);
      case 1:
        return _buildPricingTab(context);
      case 2:
        return _buildDocumentsTab(context);
      default:
        return _buildOverviewTab(context);
    }
  }

  Widget _buildOverviewTab(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DescriptionSection(description: widget.property.description),
          if (widget.property.landLayoutInfo != null) _buildLayoutInformationSection(context),
          if (widget.property.plotDetails != null) _buildPlotDetailsSection(context),
          if (widget.property.layoutAmenities != null && widget.property.layoutAmenities!.isNotEmpty)
            _buildLayoutAmenitiesSection(context),
          if (widget.property.connectivity != null) _buildLocationConnectivitySection(context),
          _buildDownloadsSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAreaDetailsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.areaDetails, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhiteLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderBlueLight, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.areaDetails.indoorArea,
                        style: widget.themeManager.propertyDetailsValueStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.property.areaDetails.indoorAreaLabel,
                        style: widget.themeManager.propertyDetailsLabelStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DottedVerticalDivider(height: 48, color: AppColors.blueInfoLight),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.areaDetails.openSkyArea,
                        style: widget.themeManager.propertyDetailsValueStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.property.areaDetails.openSkyAreaLabel,
                        style: widget.themeManager.propertyDetailsLabelStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandInfoSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.landInformation, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderGrayMedium, thickness: 1, height: 1),
          const SizedBox(height: 16),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            children: [
              _buildInfoCard('assets/images/sfts_image.svg', widget.property.propertyInfo.sqft, 'Plot Area'),
              _buildInfoCard(
                'assets/images/rera_certified_layout_icon.svg',
                widget.property.reraId ?? 'N/A',
                'RERA ID',
                isReraId: true,
              ),
              _buildInfoCard('assets/images/land_secure_badge.svg', 'Approved', 'HDMA Status'),
              _buildInfoCard('assets/images/safety_rank.svg', widget.property.propertyInfo.safetyRank, 'Safety Rank'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String iconName, String value, String label, {bool isReraId = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        color: AppColors.backgroundWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppSvgIcon(assetPath: iconName, width: 32, height: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: widget.themeManager.infoCardValueStyle.copyWith(
                    fontSize: isReraId ? 13 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: isReraId ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: widget.themeManager.infoCardLabelStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutInformationSection(BuildContext context) {
    final layoutInfo = widget.property.landLayoutInfo!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(AppStrings.layoutInformation, style: widget.themeManager.sectionHeaderStyle),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGrayMedium, width: 1),
            boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _buildInfoRow(AppStrings.approvalType, layoutInfo.approvalType, isTag: true, tagColor: 'green'),
              const SizedBox(height: 12),
              Divider(color: AppColors.borderGrayMedium, thickness: 1, height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(AppStrings.totalArea, layoutInfo.totalArea),
              const SizedBox(height: 12),
              Divider(color: AppColors.borderGrayMedium, thickness: 1, height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(AppStrings.totalPlots, layoutInfo.totalPlots),
              const SizedBox(height: 12),
              Divider(color: AppColors.borderGrayMedium, thickness: 1, height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(AppStrings.numberOfBlocks, layoutInfo.numberOfBlocks),
              const SizedBox(height: 12),
              Divider(color: AppColors.borderGrayMedium, thickness: 1, height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(AppStrings.roadWidths, layoutInfo.roadWidths),
              if (layoutInfo.isReraCertified) ...[
                const SizedBox(height: 12),
                Divider(color: AppColors.borderGrayMedium, thickness: 1, height: 1),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.approvedTagBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(assetPath: 'assets/images/rera_certified_layout_icon.svg', width: 16, height: 16),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.reraCertifiedLayout,
                        style: TextStyle(
                          color: AppColors.approvedTagTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppStrings.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTag = false, String? tagColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: widget.themeManager.propertyDetailsLabelStyle)),
        const SizedBox(width: 16),
        if (isTag)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor == 'green' ? AppColors.approvedTagBgColor : AppColors.gray800,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.approvedTagTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: AppStrings.fontFamily,
              ),
            ),
          )
        else
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: widget.themeManager.propertyDetailsValueStyle),
          ),
      ],
    );
  }

  Widget _buildPlotDetailsSection(BuildContext context) {
    final plotDetails = widget.property.plotDetails!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(AppStrings.yourPlotDetails, style: widget.themeManager.sectionHeaderStyle),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: widget.themeManager.greenGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.overlayBlack08, blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlotDetailRow(AppStrings.plotNumber, plotDetails.plotNumber),
              Divider(color: AppColors.overlayWhite20, height: 1),
              _buildPlotDetailRow(AppStrings.block, plotDetails.block),
              Divider(color: AppColors.overlayWhite20, height: 1),
              _buildPlotDetailRow(AppStrings.plotSize, plotDetails.plotSize),
              Divider(color: AppColors.overlayWhite20, height: 1),
              _buildPlotDetailRow(AppStrings.facing, plotDetails.facing),
              Divider(color: AppColors.overlayWhite20, height: 1),
              _buildPlotDetailRow(AppStrings.roadWidth, plotDetails.roadWidth),
              if (plotDetails.tags.isNotEmpty) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: plotDetails.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.overlayWhite15,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.overlayWhite40, width: 1),
                      ),
                      child: Text(
                        tag,
                        style: widget.themeManager.imageTagStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlotDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: widget.themeManager.plotDetailLabelStyle),
          Text(value, style: widget.themeManager.plotDetailValueStyle),
        ],
      ),
    );
  }

  Widget _buildLayoutAmenitiesSection(BuildContext context) {
    final amenities = widget.property.layoutAmenities!;
    final chipAmenities = amenities.where((a) => a.iconName != null).toList();
    final statusAmenities = amenities.where((a) => a.iconName == null).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.layoutAmenities, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          if (chipAmenities.isNotEmpty) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: chipAmenities.map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.approvedTagBgColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(
                        assetPath: amenity.iconName!,
                        width: 16,
                        height: 16,
                        color: AppColors.approvedTagTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(amenity.name, style: widget.themeManager.amenityChipTextStyle),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), height: 1),
            const SizedBox(height: 12),
          ],
          ...statusAmenities.asMap().entries.map((entry) {
            final index = entry.key;
            final amenity = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        amenity.name,
                        style: widget.themeManager.propertyDetailsLabelStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray700,
                        ),
                      ),
                      if (amenity.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.approvedTagBgColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(AppStrings.available, style: widget.themeManager.availableTagTextStyle),
                        ),
                    ],
                  ),
                ),
                if (index < statusAmenities.length - 1)
                  Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLocationConnectivitySection(BuildContext context) {
    final connectivity = widget.property.connectivity!;
    final lat = widget.property.mapLocation.latitude;
    final lng = widget.property.mapLocation.longitude;
    final mapImageUrl = widget.property.mapLocation.mapImageUrl.isNotEmpty
        ? widget.property.mapLocation.mapImageUrl
        : 'https://maps.googleapis.com/maps/api/staticmap?zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$lat,$lng&key=AIzaSyAmb2FYgNJA5x7JCTRq86SLXCr-5x--B8Y';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.locationConnectivity, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final lat = widget.property.mapLocation.latitude;
              final lng = widget.property.mapLocation.longitude;
              final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
              final uri = Uri.parse(googleMapsUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  mapImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.gray300,
                      child: Icon(Icons.map, size: 64, color: AppColors.gray600),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildConnectivityRow(AppStrings.airport, connectivity.airport),
          const SizedBox(height: 12),
          _buildConnectivityRow(AppStrings.orr, connectivity.orr),
          const SizedBox(height: 12),
          _buildConnectivityRow(AppStrings.schools, connectivity.schools),
          const SizedBox(height: 12),
          _buildConnectivityRow(AppStrings.hospitals, connectivity.hospitals),
          const SizedBox(height: 12),
          _buildConnectivityRow(AppStrings.techParks, connectivity.techParks),
        ],
      ),
    );
  }

  Widget _buildConnectivityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: widget.themeManager.connectivityLabelStyle),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: widget.themeManager.connectivityValueStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.downloads, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // Handle download
            },
            child: Row(
              children: [
                AppSvgIcon(
                  assetPath: 'assets/images/land_details_download.svg',
                  width: 20,
                  height: 20,
                  color: AppColors.blueInfo,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.downloadMasterLayoutPlan,
                  style: widget.themeManager.readMoreStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(BuildContext context) {
    if (widget.property.facilities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.facilities, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderGrayMedium, thickness: 1),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: widget.property.facilities.length,
            itemBuilder: (context, index) {
              final facility = widget.property.facilities[index];
              return _buildFacilityChip(facility);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(FacilityModel facility) {
    String iconName;
    switch (facility.iconName) {
      case 'car_parking':
        iconName = 'assets/images/fac_car.svg';
        break;
      case 'swimming_pool':
        iconName = 'assets/images/fac_swimming.svg';
        break;
      case 'gym':
        iconName = 'assets/images/fac_gym.svg';
        break;
      case 'restaurant':
        iconName = 'assets/images/fac_restaurant.svg';
        break;
      case 'wifi':
        iconName = 'assets/images/fac_wifi.svg';
        break;
      case 'pet_center':
        iconName = 'assets/images/fac_pet.svg';
        break;
      case 'sports_club':
        iconName = 'assets/images/fac_sports.svg';
        break;
      case 'laundry':
        iconName = 'assets/images/fac_laundry.svg';
        break;
      default:
        iconName = 'assets/images/bath_rooms.svg';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          AppSvgIcon(assetPath: iconName, width: 24, height: 24),
          const SizedBox(height: 8),
          SizedBox(
            height: 18,
            child: Text(
              facility.name,
              style: widget.themeManager.facilityChipLabelStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    const double imageSize = 88;
    const double spacing = 8;
    const double horizontalMargin = 16 * 2;
    const double containerPadding = 16 * 2;

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - horizontalMargin - containerPadding;
    final visibleCount = ((availableWidth + spacing) / (imageSize + spacing)).floor();
    final totalImages = widget.property.galleryImages.length;
    final overlayIndex = totalImages > visibleCount ? visibleCount - 1 : -1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.gallery, style: widget.themeManager.sectionHeaderStyle),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryPage(property: widget.property)));
                },
                child: Row(
                  children: [
                    Text(AppStrings.seeAll, style: widget.themeManager.gallerySeeAllStyle),
                    const SizedBox(width: 4),
                    AppSvgIcon(assetPath: 'assets/images/arrow_right.svg', width: 24, height: 24),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: imageSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalImages,
              separatorBuilder: (_, __) => const SizedBox(width: spacing),
              itemBuilder: (context, index) {
                final isOverlayItem = index == overlayIndex;
                final remainingCount = totalImages - visibleCount;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.property.galleryImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.gray300, child: const Icon(Icons.image, size: 32)),
                        ),
                        if (isOverlayItem) ...[
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AppColors.overlayBlack60, Colors.transparent],
                              ),
                            ),
                          ),
                          Center(
                            child: Text('+$remainingCount', style: widget.themeManager.galleryOverlayLargeTextStyle),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final lat = widget.property.mapLocation.latitude;
    final lng = widget.property.mapLocation.longitude;
    final mapImageUrl = widget.property.mapLocation.mapImageUrl.isNotEmpty
        ? widget.property.mapLocation.mapImageUrl
        : 'https://maps.googleapis.com/maps/api/staticmap?zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$lat,$lng&key=AIzaSyAmb2FYgNJA5x7JCTRq86SLXCr-5x--B8Y';

    Future<void> openMaps() async {
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.locationAndPublicFacilities, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderGrayMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.property.publicFacilities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final facility = widget.property.publicFacilities[index];
                String iconName;
                switch (facility.iconName) {
                  case 'hospital':
                    iconName = 'assets/images/loc_hospital.svg';
                    break;
                  case 'gas_station':
                    iconName = 'assets/images/loc_gas_station.svg';
                    break;
                  case 'mall':
                    iconName = 'assets/images/loc_mosque.svg';
                    break;
                  case 'market':
                    iconName = 'assets/images/loc_mall.svg';
                    break;
                  default:
                    iconName = 'assets/images/loc_mall.svg';
                }

                return Chip(
                  side: const BorderSide(color: Colors.transparent),
                  avatar: AppSvgIcon(assetPath: iconName, width: 18, height: 18),
                  label: Text(facility.name, style: widget.themeManager.propertyDetailsLabelStyle),
                  backgroundColor: AppColors.backgroundBlueLight,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    mapImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.gray200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.gray300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, size: 64, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(widget.property.location, style: widget.themeManager.mapErrorTextStyle),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.overlayBlack70, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.property.location, style: widget.themeManager.mapOverlayTextStyle),
                        GestureDetector(
                          onTap: openMaps,
                          child: Row(
                            children: [
                              Text(AppStrings.openInMaps, style: widget.themeManager.mapOverlayTextStyle),
                              const SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 16, color: AppColors.textWhite),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab(BuildContext context) {
    if (widget.property.pricing == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(AppStrings.pricingInformationNotAvailable, style: widget.themeManager.propertyDetailsLabelStyle),
        ),
      );
    }

    final pricing = widget.property.pricing!;
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalPlotCostSection(pricing),
          _buildPriceBreakdownSection(pricing),
          _buildPaymentMilestonesSection(pricing),
          _buildEmiCalculatorSection(pricing),
          _buildRelationshipManagerSection(pricing),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTotalPlotCostSection(PricingModel pricing) {
    final totalAmount = double.tryParse(pricing.totalAmount.replaceAll(RegExp(r'[₹,\s]'), '')) ?? 0;
    final amountPaid = double.tryParse(pricing.amountPaid.replaceAll(RegExp(r'[₹,\s]'), '')) ?? 0;
    final progress = totalAmount > 0 ? amountPaid / totalAmount : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.themeManager.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.greenGradientStart.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.totalAmount, style: widget.themeManager.totalAmountLabelStyle),
          const SizedBox(height: 4),
          Text(pricing.totalAmount, style: widget.themeManager.totalAmountValueStyle),
          const SizedBox(height: 16),
          Divider(color: AppColors.textWhite.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),
          _buildCostRow(AppStrings.amountPaid, pricing.amountPaid),
          const SizedBox(height: 12),
          _buildCostRow(AppStrings.balance, pricing.balance),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.progressTrackGreen, borderRadius: BorderRadius.circular(10)),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: AppColors.vibrantGreen,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: AppColors.vibrantGreen.withOpacity(0.6), blurRadius: 8, spreadRadius: 1),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: widget.themeManager.costRowLabelStyle),
        Text(value, style: widget.themeManager.costRowValueStyle),
      ],
    );
  }

  Widget _buildPriceBreakdownSection(PricingModel pricing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.priceBreakdown, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          ...pricing.breakdown.asMap().entries.expand((entry) {
            final item = entry.value;
            return [
              if (item.isSubtotal) ...[
                const SizedBox(height: 8),
                Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), thickness: 1, height: 1),
                const SizedBox(height: 12),
              ],
              Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildBreakdownRow(item)),
              if (item.isSubtotal) ...[
                const SizedBox(height: 4),
                Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), thickness: 1, height: 1),
                const SizedBox(height: 12),
              ],
            ];
          }).toList(),
          const SizedBox(height: 4),
          Divider(color: AppColors.borderGrayMedium.withOpacity(0.5), thickness: 1, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.grandTotal,
                style: widget.themeManager.propertyDetailsTitleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                pricing.grandTotal,
                style: widget.themeManager.propertyDetailsValueStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(PriceBreakdownItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.label,
            style: widget.themeManager.propertyDetailsLabelStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: item.isSubtotal ? AppColors.textDark : AppColors.gray700,
            ),
          ),
        ),
        Text(
          item.amount,
          style: widget.themeManager.propertyDetailsValueStyle.copyWith(
            fontSize: 14,
            fontWeight: item.isSubtotal ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMilestonesSection(PricingModel pricing) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.paymentMilestones, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildTimelineMilestones(pricing.milestones),
        ],
      ),
    );
  }

  Widget _buildTimelineMilestones(List<PaymentMilestone> milestones) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;
        return _buildTimelineMilestoneItem(milestone, isLast);
      },
    );
  }

  Widget _buildTimelineMilestoneItem(PaymentMilestone milestone, bool isLast) {
    final circleColor = _getMilestoneColor(milestone.status);
    final textColor = _getMilestoneTextColor(milestone.status);
    final showTag = milestone.status == 'paid' || milestone.status == 'due';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column with circle and connecting line
        Column(
          children: [
            // Circle
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle, // Perfect circle
              ),
              child: Center(
                child: Text(
                  '${milestone.number}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontFamily: AppStrings.fontFamilyText,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            // Connecting line (except for last item)
            if (!isLast) Container(width: 2, height: 50, color: AppColors.gray300),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                milestone.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF38383D), // Global-Gray-90
                  fontFamily: AppStrings.fontFamilyText,
                  height: 20 / 13, // 153.846%
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                milestone.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64646D), // Global-Gray-70
                  fontFamily: AppStrings.fontFamilyText,
                  height: 20 / 13, // 153.846%
                  letterSpacing: -0.25,
                ),
              ),
            ],
          ),
        ),
        // Amount and status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              milestone.amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF38383D), // Global-Gray-90
                fontFamily: AppStrings.fontFamily,
                height: 24 / 17, // 141.176%
              ),
            ),
            if (showTag) ...[const SizedBox(height: 6), _buildStatusBadge(milestone.status)],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'paid') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4), // background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB9F8CF), width: 1), // border
        ),
        child: Text(
          AppStrings.paid,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF008236),
            fontFamily: AppStrings.fontFamilyText,
            height: 16 / 13, // 123.077%
          ),
        ),
      );
    } else if (status == 'due') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED), // background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFD6A7), width: 1), // border
        ),
        child: Text(
          AppStrings.due,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFCA3500),
            fontFamily: AppStrings.fontFamilyText,
            height: 16 / 13, // 123.077%
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getMilestoneColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.successGreenLight;
      case 'due':
        return const Color(0xFFF54900); // #F54900 for due status
      case 'pending':
      default:
        return AppColors.gray400;
    }
  }

  Color _getMilestoneTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'due':
        return AppColors.textWhite; // White text for paid and due
      case 'pending':
      default:
        return AppColors.textDark;
    }
  }

  Widget _buildEmiCalculatorSection(PricingModel pricing) {
    final emi = pricing.emiCalculator;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        boxShadow: [BoxShadow(color: AppColors.overlayBlack04, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.landLoanEmiCalculator, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          _buildEmiInputField(AppStrings.loanAmount, emi.loanAmount),
          const SizedBox(height: 12),
          _buildEmiInputField(AppStrings.tenureYears, emi.tenure),
          const SizedBox(height: 12),
          _buildEmiInputField(AppStrings.interestRate, emi.interestRate),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.approvedTagBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.successGreenLight.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmiResultRow(AppStrings.monthlyEmi, emi.monthlyEmi),
                const SizedBox(height: 20),
                _buildEmiResultRow(AppStrings.totalInterest, emi.totalInterest),
                const SizedBox(height: 20),
                _buildEmiResultRow(AppStrings.totalAmount, emi.totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: widget.themeManager.propertyDetailsLabelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrayMedium),
          ),
          child: Row(
            children: [Expanded(child: Text(value, style: widget.themeManager.propertyDetailsValueStyle))],
          ),
        ),
      ],
    );
  }

  Widget _buildEmiResultRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: widget.themeManager.emiResultLabelStyle),
        const SizedBox(height: 4),
        Text(value, style: widget.themeManager.emiResultValueStyle),
      ],
    );
  }

  Widget _buildRelationshipManagerSection(PricingModel pricing) {
    final rm = pricing.relationshipManager;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.yourRelationshipManager, style: widget.themeManager.sectionHeaderStyle),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bluePrimary.withOpacity(0.8), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(rm.imageUrl)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rm.name, style: widget.themeManager.agentCardNameStyle),
                        const SizedBox(height: 2),
                        Text(rm.role, style: widget.themeManager.agentCardRoleStyle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.reraId,
                      style: widget.themeManager.propertyDetailsLabelStyle.copyWith(
                        fontSize: 13,
                        color: AppColors.gray700,
                      ),
                    ),
                    TextSpan(
                      text: rm.reraId,
                      style: widget.themeManager.propertyDetailsValueStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (rm.isVerified) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.approvedTagBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.successGreenLight.withOpacity(0.3)),
                  ),
                  child: Text(AppStrings.verifiedChannelPartner, style: widget.themeManager.verifiedTagStyle),
                ),
              ],
              const SizedBox(height: 16),
              Divider(color: AppColors.borderGrayLight.withOpacity(0.5), thickness: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildContactButton('assets/images/land_details_call.svg', () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _buildContactButton('assets/images/land_details_message.svg', () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _buildContactButton('assets/images/land_details_chat.svg', () {})),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bluePrimary.withOpacity(0.6)),
        ),
        child: Center(
          child: AppSvgIcon(assetPath: iconPath, width: 22, height: 22, color: AppColors.bluePrimary),
        ),
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    final documents = widget.property.documents ?? [];
    if (documents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(AppStrings.noDocumentsAvailable, style: widget.themeManager.propertyDetailsLabelStyle),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.availableDocuments, style: widget.themeManager.sectionHeaderStyle),
          const SizedBox(height: 20),
          ...documents.map((doc) => DocumentCard(document: doc, onTap: () => _downloadAndViewDocument(context, doc))),
        ],
      ),
    );
  }

  Future<void> _downloadAndViewDocument(BuildContext context, DocumentModel document) async {
    if (document.downloadUrl == null || document.downloadUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.downloadUrlNotAvailable), backgroundColor: AppColors.errorRed));
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Show downloading snackbar
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppStrings.downloading),
          duration: const Duration(seconds: 30),
          backgroundColor: AppColors.bluePrimary,
        ),
      );

      // Request storage permission (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          final manageStorageStatus = await Permission.manageExternalStorage.request();
          if (!manageStorageStatus.isGranted) {
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(AppStrings.storagePermissionDenied), backgroundColor: AppColors.errorRed),
            );
            return;
          }
        }
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadsPath = '${directory.path.split('Android')[0]}Download';
          final downloadsDir = Directory(downloadsPath);
          if (await downloadsDir.exists()) {
            directory = downloadsDir;
          }
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access download directory');
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Download file
      final response = await http.get(Uri.parse(document.downloadUrl!));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      // Get file extension from URL or default to pdf
      String extension = 'pdf';
      final urlPath = Uri.parse(document.downloadUrl!).path.toLowerCase();
      if (urlPath.endsWith('.pdf')) {
        extension = 'pdf';
      } else if (urlPath.endsWith('.doc') || urlPath.endsWith('.docx')) {
        extension = 'doc';
      } else if (urlPath.endsWith('.xls') || urlPath.endsWith('.xlsx')) {
        extension = 'xls';
      } else if (urlPath.endsWith('.jpg') || urlPath.endsWith('.jpeg')) {
        extension = 'jpg';
      } else if (urlPath.endsWith('.png')) {
        extension = 'png';
      }

      // Create file name (sanitize for file system)
      final sanitizedTitle = document.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
      final fileName = '$sanitizedTitle.$extension';
      final filePath = '${directory.path}/$fileName';

      // Save file (overwrite if exists)
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Show success snackbar with View option
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(child: Text(AppStrings.downloadedAndStored)),
                GestureDetector(
                  onTap: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentViewerPage(filePath: filePath, documentTitle: document.title),
                      ),
                    );
                  },
                  child: Text(
                    AppStrings.view,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.downloadFailed}: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
