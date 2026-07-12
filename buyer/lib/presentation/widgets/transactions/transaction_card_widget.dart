import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/transaction_model.dart';
import '../../pages/document_viewer_page.dart';
import '../common/app_svg_icon.dart';

class TransactionCardWidget extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onReceiptTap;

  const TransactionCardWidget({super.key, required this.transaction, required this.onReceiptTap});

  Future<void> _handleReceiptTap(BuildContext context) async {
    if (transaction.receiptUrl == null || transaction.receiptUrl!.isEmpty) {
      onReceiptTap();
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Show downloading snackbar
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Downloading receipt...'), duration: Duration(seconds: 30)),
      );

      // Request storage permission (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          final manageStorageStatus = await Permission.manageExternalStorage.request();
          if (!manageStorageStatus.isGranted) {
            scaffoldMessenger.hideCurrentSnackBar();
            scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Storage permission denied')));
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

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Download file
      final response = await http.get(Uri.parse(transaction.receiptUrl!));
      if (response.statusCode != 200) {
        throw Exception('Failed to download receipt: ${response.statusCode}');
      }

      // Create file name
      final sanitizedTitle = transaction.title.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
      final fileName = '${sanitizedTitle}_receipt.pdf';
      final filePath = '${directory.path}/$fileName';

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Hide downloading snackbar and show success
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(child: Text('Receipt downloaded and stored in Files app')),
                GestureDetector(
                  onTap: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DocumentViewerPage(filePath: filePath, documentTitle: 'Receipt - ${transaction.title}'),
                      ),
                    );
                  },
                  child: Text(
                    'View',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to download receipt: ${e.toString()}'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderGrayMedium, // choose required color
          width: 1, // border thickness
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title row - icon at 16px from left, 18px from top
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 0),
                child: AppSvgIcon(assetPath: 'assets/images/transaction_export.svg', width: 36, height: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title, style: themeManager.transactionTitleStyle),
                    //const SizedBox(height: 4),
                    Text(transaction.propertyName, style: themeManager.transactionPropertyStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Amount and Status row container - 16px gap from main container left/right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrayMedium, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_formatAmount(transaction.amount), style: themeManager.transactionAmountStyle),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: transaction.status == TransactionStatus.completed
                            ? AppColors.transactionGreen40
                            : AppColors.errorRed,
                        width: 1,
                      ),
                      color: transaction.status == TransactionStatus.completed
                          ? AppColors.transactionStatusBg
                          : AppColors.errorRedLight,
                    ),
                    child: Text(
                      transaction.statusLabel,
                      style: transaction.status == TransactionStatus.completed
                          ? themeManager.transactionStatusStyle
                          : themeManager.transactionStatusFailedStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          Divider(height: 1, thickness: 1, color: AppColors.borderGrayMedium),
          const SizedBox(height: 8),
          // Payment method, Date, and Transaction ID row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(transaction.paymentMethodLabel, style: themeManager.transactionPaymentMethodStyle),
                  const SizedBox(width: 8),
                  Text('•', style: themeManager.transactionPaymentMethodStyle),
                  const SizedBox(width: 8),
                  Text(_formatDate(transaction.date), style: themeManager.transactionDateStyle),
                ],
              ),
              Text(transaction.transactionNumber, style: themeManager.transactionIdStyle),
            ],
          ),
          const SizedBox(height: 8),
          // Divider
          const SizedBox(height: 8),
          // Receipt button
          SizedBox(
            height: 36,
            child: GestureDetector(
              onTap: () => _handleReceiptTap(context),
              child: Container(
                alignment: Alignment.center, // 👈 centers content
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGrayMedium, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 👈 prevents full width
                  mainAxisAlignment: MainAxisAlignment.center, // 👈 horizontal center
                  crossAxisAlignment: CrossAxisAlignment.center, // 👈 vertical center
                  children: [
                    AppSvgIcon(assetPath: 'assets/images/tranactions_download.svg', width: 16, height: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Receipt',
                      style: themeManager.transactionPaymentMethodStyle.copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
