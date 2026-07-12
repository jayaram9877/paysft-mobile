import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../data/models/broker_document_model.dart';
import '../providers/broker_documents_provider.dart';

const Color _green = Color(0xFF12B76A);
const Color _greenBg = Color(0xFFE7F8F0);
const Color _amber = Color(0xFFB54708);
const Color _amberBg = Color(0xFFFFF4E5);
const Color _red = Color(0xFFD92D20);
const Color _redBg = Color(0xFFFEE4E2);

class MyDocumentsPage extends StatelessWidget {
  const MyDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<BrokerDocumentsProvider>()..load(),
      child: const _MyDocumentsView(),
    );
  }
}

class _MyDocumentsView extends StatelessWidget {
  const _MyDocumentsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrokerDocumentsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1D2939)),
        title: const Text(
          'My Documents',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, BrokerDocumentsProvider provider) {
    if (provider.isLoading && provider.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && provider.documents.isEmpty) {
      return _stateMessage(
        icon: Icons.cloud_off_outlined,
        message: provider.errorMessage!,
        actionLabel: 'Retry',
        onAction: () => provider.load(),
      );
    }
    if (provider.documents.isEmpty) {
      return _stateMessage(
        icon: Icons.folder_open_outlined,
        message: 'No documents uploaded yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray70,
              ),
              children: [
                TextSpan(
                  text: '${provider.documents.length} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkSecondary,
                  ),
                ),
                TextSpan(
                  text: provider.documents.length == 1
                      ? 'document'
                      : 'documents',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...provider.documents.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DocCard(doc: d),
              )),
        ],
      ),
    );
  }

  Widget _stateMessage({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textGrayMedium),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray70, fontSize: 14),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  final BrokerDocumentModel doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.backgroundBlueSelectedVeryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: AppColors.bluePrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.typeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  doc.originalFileName ?? '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (doc.uploadedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded ${_date(doc.uploadedAt!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrayMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusBadge(),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    Color fg = _amber, bg = _amberBg;
    if (doc.isApproved) {
      fg = _green;
      bg = _greenBg;
    } else if (doc.isRejected) {
      fg = _red;
      bg = _redBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        doc.statusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  IconData get _icon {
    if ((doc.mimeType ?? '').contains('pdf')) return Icons.picture_as_pdf_outlined;
    if ((doc.mimeType ?? '').startsWith('image')) return Icons.image_outlined;
    return Icons.insert_drive_file_outlined;
  }

  static String _date(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final l = dt.toLocal();
    return '${l.day} ${months[l.month - 1]} ${l.year}';
  }
}
