import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../widgets/common/app_svg_icon.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/gradient_border_input.dart';
import '../widgets/primary_blue_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _pincodeFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _stateFocusNode = FocusNode();

  String? _selectedCity;
  String? _selectedState;
  File? _selectedProfileImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Mock data for dropdowns
  final List<String> _cities = ['Bangalore', 'Mumbai', 'Delhi', 'Chennai', 'Hyderabad', 'Pune', 'Kolkata'];
  final List<String> _states = [
    'Karnataka',
    'Maharashtra',
    'Delhi',
    'Tamil Nadu',
    'Telangana',
    'Gujarat',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    // Prefill from the loaded buyer profile.
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _nameController.text = profile.fullName;
      _phoneController.text = profile.mobile ?? '';
      _emailController.text = profile.email;
      _addressController.text = profile.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    _pincodeFocusNode.dispose();
    _cityFocusNode.dispose();
    _stateFocusNode.dispose();
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
            child: Text(AppStrings.editProfile, style: themeManager.editProfileTitleStyle),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              color: AppColors.borderDivider,
              boxShadow: themeManager.appBarDividerShadowStyle,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildProfilePictureSection(themeManager),
                    const SizedBox(height: 24),
                    _buildPersonalDetailsSection(themeManager),
                    const SizedBox(height: 24),
                    _buildAddressInfoSection(themeManager),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                boxShadow: themeManager.editProfileShadowStyle,
              ),
              child: PrimaryGradientButton(text: 'Save Changes', onTap: _handleSaveChanges, borderRadius: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(ThemeManager themeManager) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImagePickerOptions(context),
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundGray),
                  child: ClipOval(
                    child: _selectedProfileImage != null
                        ? Image.file(_selectedProfileImage!, width: 96, height: 96, fit: BoxFit.cover)
                        : AppSvgIcon(assetPath: 'assets/images/edit_profile_picture.svg', width: 96, height: 96),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bluePrimary,
                      border: Border.all(color: AppColors.backgroundWhite, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: AppColors.textWhite),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Tap to change photo', style: themeManager.editProfileSecondaryTextStyle),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.attachmentChooseFromGallery),
              onTap: () async {
                Navigator.pop(modalContext);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text(AppStrings.attachmentTakePhoto),
              onTap: () async {
                Navigator.pop(modalContext);
                await _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) {
        setState(() {
          _selectedProfileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? '${AppStrings.messageErrorTakingPhoto} ${e.toString()}'
                  : '${AppStrings.messageErrorSelectingImage} ${e.toString()}',
              style: ThemeManager().snackBarTextStyle,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildPersonalDetailsSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Details', style: themeManager.editProfileSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray40, width: 1),
            boxShadow: themeManager.editProfileSectionShadowStyle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                themeManager,
                controller: _nameController,
                focusNode: _nameFocusNode,
                label: 'Full Name',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                themeManager,
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                themeManager,
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInfoSection(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address Information', style: themeManager.editProfileSectionTitleStyle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray40, width: 1),
            boxShadow: themeManager.editProfileSectionShadowStyle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressInputField(themeManager, controller: _addressController, focusNode: _addressFocusNode, label: 'Residential Address *'),
              const SizedBox(height: 16),
              _buildDropdownField(
                themeManager,
                focusNode: _cityFocusNode,
                label: 'City',
                value: _selectedCity,
                items: _cities,
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                themeManager,
                focusNode: _stateFocusNode,
                label: 'State',
                value: _selectedState,
                items: _states,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                themeManager,
                controller: _pincodeController,
                focusNode: _pincodeFocusNode,
                label: 'PIN Code *',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    ThemeManager themeManager, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: themeManager.editProfileInputLabelStyle),
        const SizedBox(height: 8),
        GradientBorderInput(
          focusNode: focusNode,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: themeManager.editProfileInputTextStyle,
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
    );
  }

  Widget _buildAddressInputField(
    ThemeManager themeManager, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: themeManager.editProfileInputLabelStyle),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: GradientBorderInput(
            focusNode: focusNode,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              style: themeManager.editProfileInputTextStyle,
              decoration: themeManager
                  .editProfileInputDecoration(hintText: 'Enter your complete address')
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
    );
  }

  Widget _buildDropdownField(
    ThemeManager themeManager, {
    required FocusNode focusNode,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: themeManager.editProfileInputLabelStyle),
        const SizedBox(height: 8),
        GradientBorderInput(
          // Use internal focus handling for the border to avoid
          // conflicts with the dropdown's own focus/overlay logic.
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: themeManager.editProfileInputTextStyle),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: themeManager.editProfileInputDecoration().copyWith(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: themeManager.editProfileDropdownIconColor),
            style: themeManager.editProfileInputTextStyle,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final address = _addressController.text.trim();
    final error = await provider.updateProfile(
      fullName: _nameController.text.trim(),
      address: address.isEmpty ? null : address,
    );

    if (!mounted) return;
    final themeManager = ThemeManager();
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully', style: themeManager.bodyStyle)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error, style: themeManager.bodyStyle)),
      );
    }
  }
}
