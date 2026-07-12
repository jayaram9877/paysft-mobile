import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';
import '../widgets/common/gradient_border_input.dart';
import 'contact_support_page.dart';

class EmailUsPage extends StatefulWidget {
  const EmailUsPage({super.key});

  @override
  State<EmailUsPage> createState() => _EmailUsPageState();
}

class _EmailUsPageState extends State<EmailUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isFormValid = false;
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _subjectTouched = false;
  bool _messageTouched = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _subjectController.addListener(_validateForm);
    _messageController.addListener(_validateForm);
  }

  bool _isNameValid() => _nameController.text.trim().isNotEmpty;
  bool _isEmailValid() {
    final email = _emailController.text.trim();
    return email.isNotEmpty && _isValidEmail(email);
  }
  bool _isSubjectValid() => _subjectController.text.trim().isNotEmpty;
  bool _isMessageValid() => _messageController.text.trim().isNotEmpty;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final isValid =
        _nameController.text.trim().isNotEmpty &&
        email.isNotEmpty &&
        _isValidEmail(email) &&
        _subjectController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _subjectController.removeListener(_validateForm);
    _messageController.removeListener(_validateForm);
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _subjectFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

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
            child: Text('Email Us', style: themeManager.editProfileTitleStyle),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(color: AppColors.borderDivider, boxShadow: themeManager.appBarDividerShadowStyle),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildEmailAddressSection(themeManager),
            const SizedBox(height: 24),
            _buildEmailFormSection(themeManager),
            const SizedBox(height: 24),
            _buildNeedHelpSection(context, themeManager),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailAddressSection(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGray20, width: 1),
        boxShadow: themeManager.contactSupportSectionShadowStyle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSvgIcon(assetPath: 'assets/images/emailus_email.svg', width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('support@paysft.com', style: themeManager.helpCenterEmailAddressStyle),
                const SizedBox(height: 4),
                Text('We typically reply within 24 hours', style: themeManager.helpCenterReplyTimeStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailFormSection(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGray20, width: 1),
        boxShadow: themeManager.contactSupportSectionShadowStyle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Name', style: themeManager.editProfileInputLabelStyle),
              const SizedBox(height: 8),
              GradientBorderInput(
                hasError: _nameTouched && !_isNameValid(),
                focusNode: _nameFocusNode,
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  style: themeManager.editProfileInputTextStyle,
                  onChanged: (_) {
                    if (!_nameTouched) {
                      setState(() => _nameTouched = true);
                    }
                    _validateForm();
                  },
                  decoration: themeManager.editProfileInputDecoration().copyWith(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Email', style: themeManager.editProfileInputLabelStyle),
              const SizedBox(height: 8),
              GradientBorderInput(
                hasError: _emailTouched && !_isEmailValid(),
                focusNode: _emailFocusNode,
                child: TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: themeManager.editProfileInputTextStyle,
                  onChanged: (_) {
                    if (!_emailTouched) {
                      setState(() => _emailTouched = true);
                    }
                    _validateForm();
                  },
                  decoration: themeManager.editProfileInputDecoration().copyWith(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subject *', style: themeManager.editProfileInputLabelStyle),
              const SizedBox(height: 8),
              GradientBorderInput(
                hasError: _subjectTouched && !_isSubjectValid(),
                child: TextFormField(
                  controller: _subjectController,
                  style: themeManager.editProfileInputTextStyle,
                  onChanged: (_) {
                    if (!_subjectTouched) {
                      setState(() => _subjectTouched = true);
                    }
                    _validateForm();
                  },
                  decoration: themeManager.editProfileInputDecoration(hintText: 'What is this about?').copyWith(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Message *', style: themeManager.editProfileInputLabelStyle),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: GradientBorderInput(
                  hasError: _messageTouched && !_isMessageValid(),
                  focusNode: _messageFocusNode,
                  child: TextFormField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    style: themeManager.editProfileInputTextStyle,
                    onChanged: (_) {
                      if (!_messageTouched) {
                        setState(() => _messageTouched = true);
                      }
                      _validateForm();
                    },
                    decoration: themeManager
                        .editProfileInputDecoration(hintText: 'Describe your issue or question...')
                        .copyWith(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isFormValid
                  ? () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Message sent successfully')));
                      _nameController.clear();
                      _emailController.clear();
                      _subjectController.clear();
                      _messageController.clear();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid ? AppColors.blueProfileStart : AppColors.ultramarine50,
                disabledBackgroundColor: AppColors.ultramarine50,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Send Message', style: themeManager.helpCenterSendMessageButtonStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpSection(BuildContext context, ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.helpYellowBorder, width: 1),
        color: AppColors.helpYellowBg,
        boxShadow: [
          BoxShadow(color: AppColors.helpYellowShadow.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        children: [
          Text('Need urgent help?', style: themeManager.helpCenterNeedHelpTitleStyle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'for immediate assistance',
            style: themeManager.helpCenterImmediateAssistanceStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse('tel:18001234567');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange70,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('Call us', style: themeManager.helpCenterCallUsButtonStyle),
            ),
          ),
        ],
      ),
    );
  }
}
