import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/broker_kyc_provider.dart';
import 'congratulations_page.dart';

class LiveSelfiePage extends StatefulWidget {
  const LiveSelfiePage({super.key});

  @override
  State<LiveSelfiePage> createState() => _LiveSelfiePageState();
}

class _LiveSelfiePageState extends State<LiveSelfiePage> {
  final _picker = ImagePicker();
  String? _selfiePath;
  String? _selfieName;

  Future<void> _capture() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70,
    );
    if (file == null || !mounted) return;
    setState(() {
      _selfiePath = file.path;
      _selfieName = file.name;
    });
  }

  Future<void> _continue() async {
    final kyc = context.read<BrokerKycProvider>();
    final path = _selfiePath;
    if (path == null) {
      await _capture();
      return;
    }

    final sizeKb = await BrokerKycProvider.fileSizeKb(path);
    kyc.setDoc(
      'photo_id',
      DocDraft(filePath: path, fileName: _selfieName ?? 'selfie.jpg', fileSizeKb: sizeKb),
    );

    final ok = await kyc.submitAll();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CongratulationsPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(kyc.errorMessage ?? 'Submission failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<BrokerKycProvider>().isLoading;
    final hasSelfie = _selfiePath != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        foregroundColor: AppColors.primaryBlueIOS,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                isLoading ? 'Verifying' : 'Live Selfie',
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isLoading
                    ? 'We are verifying, it will take a few seconds.'
                    : 'Ensure the person onboarding is the actual\nAadhaar / PAN holder.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              _targetCircle(hasSelfie, isLoading),
              if (isLoading) ...[
                const SizedBox(height: 28),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _continue,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Text(
                    hasSelfie ? 'Continue' : 'Capture Selfie',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetCircle(bool hasSelfie, bool loading) {
    return GestureDetector(
      onTap: loading ? null : _capture,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryBlue.withOpacity(0.08),
        ),
        child: Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.15),
            ),
            child: Center(
              child: hasSelfie
                  ? ClipOval(
                      child: Image.file(
                        File(_selfiePath!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue,
                      ),
                      child: const Icon(
                        Icons.center_focus_strong,
                        color: AppColors.backgroundWhite,
                        size: 48,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
