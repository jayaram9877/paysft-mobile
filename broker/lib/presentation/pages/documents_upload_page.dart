import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/broker_kyc_provider.dart';
import '../widgets/primary_blue_button.dart';
import 'live_selfie_page.dart';

enum _NumFmt { aadhaar, pan, generic }

class _DocItem {
  final int step;
  final String name;
  final String apiType; // valid broker document_type for the API upload
  final String numberHint;
  final _NumFmt fmt;
  final TextEditingController controller = TextEditingController();
  bool expanded = false;

  _DocItem({
    required this.step,
    required this.name,
    required this.apiType,
    required this.numberHint,
    required this.fmt,
  });
}

class DocumentsUploadPage extends StatefulWidget {
  const DocumentsUploadPage({super.key});

  @override
  State<DocumentsUploadPage> createState() => _DocumentsUploadPageState();
}

class _DocumentsUploadPageState extends State<DocumentsUploadPage> {
  final _picker = ImagePicker();

  // Matches the UI design (Aadhaar / PAN / DPDP). The API has no Aadhaar/DPDP
  // broker doc types, so files map to accepted types on submit.
  late final List<_DocItem> _docs = [
    _DocItem(
      step: 1,
      name: 'Aadhaar Card',
      apiType: 'address_proof',
      numberHint: '0000 0000 0000 0000',
      fmt: _NumFmt.aadhaar,
    ),
    _DocItem(
      step: 2,
      name: 'PAN Card',
      apiType: 'pan_card',
      numberHint: '0000000000',
      fmt: _NumFmt.pan,
    ),
    _DocItem(
      step: 3,
      name: 'DPDP Compliant',
      apiType: 'cancelled_cheque',
      numberHint: 'Enter Document Number',
      fmt: _NumFmt.generic,
    ),
    _DocItem(
      step: 4,
      name: 'RERA Certificate',
      // Verified accepted broker document_type via the live API (the broker
      // document_type is a free string with a server-side whitelist).
      apiType: 'rera_agent_certificate',
      numberHint: 'RERA Registration Number',
      fmt: _NumFmt.generic,
    ),
  ];

  @override
  void dispose() {
    for (final d in _docs) {
      d.controller.dispose();
    }
    super.dispose();
  }

  void _toggle(_DocItem d) => setState(() => d.expanded = !d.expanded);

  Future<void> _showPicker(_DocItem doc) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A Short Title is Best',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A message should be a short, complete sentence.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerTile(ctx, Icons.photo_library_outlined, 'Gallery',
                    ImageSource.gallery),
                _pickerTile(ctx, Icons.camera_alt_outlined, 'Camera',
                    ImageSource.camera),
                _pickerTile(ctx, Icons.location_on_outlined, 'Location',
                    ImageSource.gallery),
                _pickerTile(ctx, Icons.description_outlined, 'Document',
                    ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundLight,
                  foregroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _select(doc, source);
  }

  Widget _pickerTile(
      BuildContext ctx, IconData icon, String label, ImageSource source) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx, source),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
      ],
    );
  }

  /// Selects a file and holds it LOCALLY (no upload — that happens on submit).
  Future<void> _select(_DocItem doc, ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file == null || !mounted) return;
    final sizeKb = await BrokerKycProvider.fileSizeKb(file.path);
    context.read<BrokerKycProvider>().setDoc(
          doc.apiType,
          DocDraft(filePath: file.path, fileName: file.name, fileSizeKb: sizeKb),
        );
  }

  void _continue() {
    // Documents are held locally; proceed to the Live Selfie step, which
    // captures the required photo_id and then submits everything at once.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LiveSelfiePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    final kyc = context.watch<BrokerKycProvider>();
    final allSelected = _docs.every((d) => kyc.hasDoc(d.apiType));

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
        title: Text('Documents Upload', style: theme.titleStyle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildProgress(theme),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ..._docs.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCard(theme, d, kyc),
                        )),
                    const SizedBox(height: 8),
                    if (!allSelected)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          '* All documents are mandatory to continue.',
                          style: theme.captionSmallStyle.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (allSelected)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFF2BA84A), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All documents added',
                        style: TextStyle(
                          color: Color(0xFF1E7A37),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: allSelected
                  ? PrimaryGradientButton(
                      text: 'Continue', onTap: _continue, borderRadius: 27)
                  : _disabledContinue(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disabledContinue() => Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.buttonDisabledBackground,
          borderRadius: BorderRadius.circular(27),
        ),
        alignment: Alignment.center,
        child: Text('Continue',
            style: TextStyle(
                color: AppColors.buttonDisabledText,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      );

  Widget _buildProgress(ThemeManager theme) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return SizedBox(
          height: 12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                width: w / 3,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Positioned(
                  left: (2 / 3) * w - 4,
                  top: 0,
                  child: _dot(AppColors.textSecondary)),
              Positioned(
                  left: w - 8, top: 0, child: _dot(AppColors.textSecondary)),
              Positioned(
                left: w / 3 - 6,
                top: -3,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.backgroundWhite,
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(Color color) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _buildCard(ThemeManager theme, _DocItem d, BrokerKycProvider kyc) {
    final draft = kyc.docOf(d.apiType);
    final selected = draft != null;
    return GestureDetector(
      onTap: () => _toggle(d),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: d.expanded ? AppColors.primaryBlue : AppColors.borderLight),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.backgroundLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: selected
                          ? const Icon(Icons.check,
                              color: AppColors.backgroundWhite, size: 20)
                          : Text('${d.step}',
                              style: theme.bodyMediumStyle.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(d.name, style: theme.bodyMediumStyle)),
                  if (selected)
                    const Icon(Icons.check_circle,
                        color: AppColors.primaryBlue, size: 24)
                  else
                    Icon(d.expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textPrimary),
                ],
              ),
            ),
            if (d.expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: 8),
                    Text('Enter ${d.name} Number',
                        style: theme.captionStyle
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: d.controller,
                      keyboardType: d.fmt == _NumFmt.generic
                          ? TextInputType.text
                          : TextInputType.number,
                      inputFormatters: _formattersFor(d.fmt),
                      style: theme.bodySmallStyle,
                      onChanged: (v) =>
                          kyc.setDocNumber(d.apiType, v),
                      decoration: InputDecoration(
                        hintText: d.numberHint,
                        hintStyle: theme.bodySmallStyle
                            .copyWith(color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.primaryBlue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    selected
                        ? _fileChip(theme, d, draft)
                        : _uploadButton(theme, d),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _uploadButton(ThemeManager theme, _DocItem d) {
    return GestureDetector(
      onTap: () => _showPicker(d),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined,
                color: AppColors.primaryBlue, size: 26),
            const SizedBox(height: 4),
            Text('Upload ${d.name}',
                style: theme.captionStyle
                    .copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('JPEG, PNG, PDF',
                style: theme.captionSmallStyle
                    .copyWith(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _fileChip(ThemeManager theme, _DocItem d, DocDraft draft) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmallStyle
                        .copyWith(fontWeight: FontWeight.w500)),
                if (draft.fileSizeKb != null)
                  Text('${draft.fileSizeKb} KB',
                      style: theme.captionSmallStyle
                          .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.read<BrokerKycProvider>().removeDoc(d.apiType),
            child: const Icon(Icons.close,
                color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  List<TextInputFormatter> _formattersFor(_NumFmt fmt) {
    switch (fmt) {
      case _NumFmt.aadhaar:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
          _AadhaarSpaceFormatter(),
        ];
      case _NumFmt.pan:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(10),
          _UpperCaseFormatter(),
        ];
      case _NumFmt.generic:
        return [];
    }
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.toUpperCase());
}

class _AadhaarSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final digits = n.text.replaceAll(' ', '');
    final b = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(digits[i]);
    }
    return TextEditingValue(
      text: b.toString(),
      selection: TextSelection.collapsed(offset: b.length),
    );
  }
}
