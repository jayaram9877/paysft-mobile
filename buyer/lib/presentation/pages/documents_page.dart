import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/document_model.dart';
import '../providers/documents_provider.dart';
import '../widgets/common/app_search_field.dart';
import '../widgets/common/app_svg_icon.dart';
import '../widgets/documents/document_card_widget.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/common/property_category_tab_bar.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return ChangeNotifierProvider(
      create: (_) => DocumentsProvider(),
      child: Consumer<DocumentsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundWhite,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: AppSvgIcon(assetPath: 'assets/images/profile_back.svg', width: 24, height: 24),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              leadingWidth: 40,
              title: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.documents,
                    style: themeManager.titleMediumStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                PropertyCategoryTabBar(
                  tabs: DocumentsProvider.tabs,
                  selectedIndex: provider.selectedTabIndex,
                  onTabChanged: provider.onTabChanged,
                  themeManager: themeManager,
                ),
                // Divider with shadow after tabs (no gap)
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: AppColors.borderDivider,
                    boxShadow: themeManager.appBarDividerShadowStyle,
                  ),
                ),
                _buildSearchBar(context, themeManager, provider),
                _buildDocumentCount(themeManager, provider),
                _buildDocumentList(context, themeManager, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeManager themeManager, DocumentsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: provider.searchController,
              hintText: 'Search documents…',
              onChanged: (_) {
                // Filtering is handled automatically by the provider's listener
              },
              showFilter: false,
              height: 48,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterOptions(context, themeManager, provider),
            child: Stack(
              children: [
                AppSvgIcon(assetPath: 'assets/images/filter.svg', width: 22, height: 22, color: AppColors.blueAccent),
                if (provider.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context, ThemeManager themeManager, DocumentsProvider provider) {
    // Initialize temporary filters to match current applied filters
    provider.resetToAppliedFilters();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite.withOpacity(0),
      isScrollControlled: true,
      builder: (bottomSheetContext) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<DocumentsProvider>(
          builder: (context, provider, _) {
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.borderDivider, borderRadius: BorderRadius.circular(2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filter Documents',
                              style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
                            ),
                          ),
                          if (provider.hasActiveFilters)
                            TextButton(
                              onPressed: () {
                                provider.clearAllFilters();
                              },
                              child: Text(
                                'Clear All',
                                style: themeManager.bodyStyle.copyWith(color: AppColors.bluePrimary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterSection(
                              context,
                              themeManager,
                              provider,
                              title: 'File Type',
                              children: [
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'All',
                                  isSelected: provider.selectedFileType == null,
                                  onTap: () => provider.setFileTypeFilter(null),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'PDF',
                                  isSelected: provider.selectedFileType == FileType.pdf,
                                  onTap: () => provider.setFileTypeFilter(FileType.pdf),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'DOC',
                                  isSelected: provider.selectedFileType == FileType.doc,
                                  onTap: () => provider.setFileTypeFilter(FileType.doc),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'XLS',
                                  isSelected: provider.selectedFileType == FileType.xls,
                                  onTap: () => provider.setFileTypeFilter(FileType.xls),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Image',
                                  isSelected: provider.selectedFileType == FileType.image,
                                  onTap: () => provider.setFileTypeFilter(FileType.image),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildFilterSection(
                              context,
                              themeManager,
                              provider,
                              title: 'Date Range',
                              children: [
                                _buildFilterOption(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'All Time',
                                  isSelected: provider.selectedDateRange == DateRangeFilter.all,
                                  onTap: () => provider.setDateRangeFilter(DateRangeFilter.all),
                                ),
                                _buildFilterOption(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Last Week',
                                  isSelected: provider.selectedDateRange == DateRangeFilter.lastWeek,
                                  onTap: () => provider.setDateRangeFilter(DateRangeFilter.lastWeek),
                                ),
                                _buildFilterOption(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Last Month',
                                  isSelected: provider.selectedDateRange == DateRangeFilter.lastMonth,
                                  onTap: () => provider.setDateRangeFilter(DateRangeFilter.lastMonth),
                                ),
                                _buildFilterOption(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Last 3 Months',
                                  isSelected: provider.selectedDateRange == DateRangeFilter.last3Months,
                                  onTap: () => provider.setDateRangeFilter(DateRangeFilter.last3Months),
                                ),
                                _buildFilterOption(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Last Year',
                                  isSelected: provider.selectedDateRange == DateRangeFilter.lastYear,
                                  onTap: () => provider.setDateRangeFilter(DateRangeFilter.lastYear),
                                ),
                              ],
                            ),
                            if (provider.availablePropertyNames.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildFilterSection(
                                context,
                                themeManager,
                                provider,
                                title: 'Property',
                                children: [
                                  _buildFilterOption(
                                    context,
                                    themeManager,
                                    provider,
                                    label: 'All Properties',
                                    isSelected: provider.selectedPropertyName == null,
                                    onTap: () => provider.setPropertyNameFilter(null),
                                  ),
                                  ...provider.availablePropertyNames.map(
                                    (propertyName) => _buildFilterOption(
                                      context,
                                      themeManager,
                                      provider,
                                      label: propertyName,
                                      isSelected: provider.selectedPropertyName == propertyName,
                                      onTap: () => provider.setPropertyNameFilter(propertyName),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    // Divider after all filter options
                    Container(height: 1, color: AppColors.borderDivider),
                    // Apply Filters Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: PrimaryGradientButton(
                        text: 'Apply Filters',
                        onTap: () {
                          provider.applyFilters();
                          Navigator.pop(context);
                        },
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    ThemeManager themeManager,
    DocumentsProvider provider, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: themeManager.filterSectionTitleStyle),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeManager themeManager,
    DocumentsProvider provider, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundBlueLight : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.blueInfo : AppColors.borderGrayLight, width: 1),
        ),
        child: Text(
          label,
          style: themeManager.categoryChipTextSelectedStyle.copyWith(
            color: isSelected ? AppColors.blueInfo : AppColors.textDarkSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    ThemeManager themeManager,
    DocumentsProvider provider, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: themeManager.sectionItemMainStyle.copyWith(
                  color: isSelected ? AppColors.bluePrimary : AppColors.textDark,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: AppColors.bluePrimary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCount(ThemeManager themeManager, DocumentsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('${provider.documentCount} ${AppStrings.documents}', style: themeManager.documentCountStyle),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context, ThemeManager themeManager, DocumentsProvider provider) {
    if (provider.documents.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('No documents found', style: themeManager.bodyStyle.copyWith(color: AppColors.textGray)),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: provider.documents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final document = provider.documents[index];
          return DocumentCardWidget(document: document, onDownload: () => provider.downloadDocument(document, context));
        },
      ),
    );
  }
}
