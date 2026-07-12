import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../../domain/entities/transaction_model.dart';
import '../providers/transactions_provider.dart';
import '../widgets/common/app_svg_icon.dart';
import '../widgets/transactions/transaction_card_widget.dart';
import '../widgets/primary_blue_button.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return ChangeNotifierProvider(
      create: (_) => TransactionsProvider(),
      child: Consumer<TransactionsProvider>(
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
                    AppStrings.transactions,
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
                _buildTabBar(context, themeManager, provider),
                // Divider with shadow after tabs (no gap)
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: AppColors.borderDivider,
                    boxShadow: themeManager.appBarDividerShadowStyle,
                  ),
                ),
                _buildSummaryCard(context, themeManager, provider),
                const SizedBox(height: 14),
                _buildTransactionHeader(context, themeManager, provider),
                _buildTransactionList(context, themeManager, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ThemeManager themeManager, TransactionsProvider provider) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(
            TransactionsProvider.tabs.length,
            (index) => Expanded(
              child: _buildTabItem(context, themeManager, provider, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, ThemeManager themeManager, TransactionsProvider provider, int index) {
    final isSelected = provider.selectedTabIndex == index;
    final tabName = TransactionsProvider.tabs[index];

    return GestureDetector(
      onTap: () => provider.onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tabName,
              style: isSelected ? themeManager.documentTabSelectedStyle : themeManager.documentTabUnselectedStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Container(
                      height: 2,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF006EFF), Color(0xFF8A00FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    )
                  : const SizedBox(height: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ThemeManager themeManager, TransactionsProvider provider) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.transactionGreen20, width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.transactionGreenStart, AppColors.transactionGreenEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.transactionGreenStart.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Amount Paid', style: themeManager.transactionTotalLabelStyle),
          const SizedBox(height: 8),
          Text(provider.formattedTotalAmount, style: themeManager.transactionTotalAmountStyle),
          //const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${provider.transactionCount} transactions', style: themeManager.transactionCardCountStyle),
              _buildStatementButton(context, themeManager),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatementButton(BuildContext context, ThemeManager themeManager) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement statement download
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.transactionGreen40, width: 1),
          color: AppColors.transactionGreen10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              assetPath: 'assets/images/tranactions_download.svg',
              width: 16,
              height: 16,
              color: AppColors.transactionGreenEnd,
            ),
            const SizedBox(width: 6),
            Text('Statement', style: themeManager.statementButtonTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(BuildContext context, ThemeManager themeManager, TransactionsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '${provider.transactionCount} ', style: themeManager.transactionCountNumberStyle),
                TextSpan(text: 'Transactions', style: themeManager.transactionCountLabelStyle),
              ],
            ),
          ),
              Row(
            children: [
              GestureDetector(
                onTap: () => _showFilterOptions(context, themeManager, provider),
                child: Stack(
                  children: [
                    AppSvgIcon(assetPath: 'assets/images/transactions_filter.svg', width: 36, height: 36),
                    if (provider.hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showCalendarPicker(context, themeManager, provider),
                child: AppSvgIcon(assetPath: 'assets/images/transactions_calendar.svg', width: 36, height: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, ThemeManager themeManager, TransactionsProvider provider) {
    if (provider.transactions.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('No transactions found', style: themeManager.bodyStyle.copyWith(color: AppColors.textGray)),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: provider.transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transaction = provider.transactions[index];
          return TransactionCardWidget(
            transaction: transaction,
            onReceiptTap: () {
              if (transaction.receiptUrl != null) {
                // Navigate to document viewer
                // TODO: Implement receipt viewing
              }
            },
          );
        },
      ),
    );
  }

  void _showCalendarPicker(BuildContext context, ThemeManager themeManager, TransactionsProvider provider) {
    provider.resetToAppliedFilters();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite.withOpacity(0),
      isScrollControlled: true,
      builder: (bottomSheetContext) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<TransactionsProvider>(
          builder: (context, provider, _) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
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
                              'Select Date Range',
                              style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
                            ),
                          ),
                          if (provider.tempStartDate != null || provider.tempEndDate != null)
                            TextButton(
                              onPressed: () {
                                provider.setStartDate(null);
                                provider.setEndDate(null);
                              },
                              child: Text(
                                'Clear',
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
                            _buildDatePickerField(
                              context,
                              themeManager,
                              provider,
                              label: 'Start Date',
                              date: provider.tempStartDate,
                              onTap: () => _selectDate(context, provider, isStartDate: true),
                            ),
                            const SizedBox(height: 16),
                            _buildDatePickerField(
                              context,
                              themeManager,
                              provider,
                              label: 'End Date',
                              date: provider.tempEndDate,
                              onTap: () => _selectDate(context, provider, isStartDate: false),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        border: Border(
                          top: BorderSide(color: AppColors.borderDivider, width: 1),
                        ),
                      ),
                      child: PrimaryGradientButton(
                        text: 'Apply',
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
    ).whenComplete(() {
      // Reset temporary filters if the bottom sheet is dismissed without applying
      provider.resetToAppliedFilters();
    });
  }

  Widget _buildDatePickerField(
    BuildContext context,
    ThemeManager themeManager,
    TransactionsProvider provider, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: themeManager.bodyStyle.copyWith(color: AppColors.textGray),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null ? _formatDate(date) : 'Select date',
                  style: themeManager.bodyMediumStyle.copyWith(
                    color: date != null ? AppColors.textDark : AppColors.textGray,
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_today, size: 20, color: AppColors.textGray),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TransactionsProvider provider, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (provider.tempStartDate ?? DateTime.now()) : (provider.tempEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.bluePrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStartDate) {
        provider.setStartDate(picked);
        // If end date is before start date, clear it
        if (provider.tempEndDate != null && provider.tempEndDate!.isBefore(picked)) {
          provider.setEndDate(null);
        }
      } else {
        // Validate that end date is after start date
        if (provider.tempStartDate != null && picked.isBefore(provider.tempStartDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End date must be after start date')),
          );
          return;
        }
        provider.setEndDate(picked);
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showFilterOptions(BuildContext context, ThemeManager themeManager, TransactionsProvider provider) {
    provider.resetToAppliedFilters();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWhite.withOpacity(0),
      isScrollControlled: true,
      builder: (bottomSheetContext) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<TransactionsProvider>(
          builder: (context, provider, _) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
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
                              'Filter Transactions',
                              style: themeManager.titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
                            ),
                          ),
                          if (provider.hasActiveFilters || provider.hasPendingFilters)
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
                              title: 'Payment Method',
                              children: [
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'All',
                                  isSelected: provider.tempPaymentMethod == null,
                                  onTap: () => provider.setPaymentMethodFilter(null),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'UPI',
                                  isSelected: provider.tempPaymentMethod == PaymentMethod.upi,
                                  onTap: () => provider.setPaymentMethodFilter(PaymentMethod.upi),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Card',
                                  isSelected: provider.tempPaymentMethod == PaymentMethod.card,
                                  onTap: () => provider.setPaymentMethodFilter(PaymentMethod.card),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Net Banking',
                                  isSelected: provider.tempPaymentMethod == PaymentMethod.netbanking,
                                  onTap: () => provider.setPaymentMethodFilter(PaymentMethod.netbanking),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Wallet',
                                  isSelected: provider.tempPaymentMethod == PaymentMethod.wallet,
                                  onTap: () => provider.setPaymentMethodFilter(PaymentMethod.wallet),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildFilterSection(
                              context,
                              themeManager,
                              provider,
                              title: 'Status',
                              children: [
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'All',
                                  isSelected: provider.tempStatus == null,
                                  onTap: () => provider.setStatusFilter(null),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Completed',
                                  isSelected: provider.tempStatus == TransactionStatus.completed,
                                  onTap: () => provider.setStatusFilter(TransactionStatus.completed),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Failed',
                                  isSelected: provider.tempStatus == TransactionStatus.failed,
                                  onTap: () => provider.setStatusFilter(TransactionStatus.failed),
                                ),
                                _buildFilterChip(
                                  context,
                                  themeManager,
                                  provider,
                                  label: 'Pending',
                                  isSelected: provider.tempStatus == TransactionStatus.pending,
                                  onTap: () => provider.setStatusFilter(TransactionStatus.pending),
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
                                  _buildFilterChip(
                                    context,
                                    themeManager,
                                    provider,
                                    label: 'All Properties',
                                    isSelected: provider.tempPropertyName == null,
                                    onTap: () => provider.setPropertyNameFilter(null),
                                  ),
                                  ...provider.availablePropertyNames.map((propertyName) => _buildFilterChip(
                                        context,
                                        themeManager,
                                        provider,
                                        label: propertyName,
                                        isSelected: provider.tempPropertyName == propertyName,
                                        onTap: () => provider.setPropertyNameFilter(propertyName),
                                      )),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    // Divider after all filter options
                    Container(
                      height: 1,
                      color: AppColors.borderDivider,
                    ),
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
    ).whenComplete(() {
      // Reset temporary filters if the bottom sheet is dismissed without applying
      provider.resetToAppliedFilters();
    });
  }

  Widget _buildFilterSection(
    BuildContext context,
    ThemeManager themeManager,
    TransactionsProvider provider, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: themeManager.filterSectionTitleStyle,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeManager themeManager,
    TransactionsProvider provider, {
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
          border: Border.all(
            color: isSelected ? AppColors.blueInfo : AppColors.borderGrayLight,
            width: 1,
          ),
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
}
