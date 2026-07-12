import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_string_constants.dart';

/// Centralized theme manager for the entire application
/// All styling should come from this class - no inline styles or duplicate theme classes
class ThemeManager extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Color getters
  Color get primaryBlue => AppColors.primaryBlue;
  Color get primaryPurple => AppColors.primaryPurple;
  Color get backgroundLight => AppColors.backgroundLight;
  Color get cardLight => AppColors.backgroundWhite;
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textLinks => AppColors.primaryBlueIOS;

  LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // TEXT STYLES - Centralized text styles for the entire app
  // ============================================================================

  /// Helper method to create text styles with consistent parameters
  TextStyle _createTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    String? fontFamily,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? AppStrings.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    ).copyWith(height: height, letterSpacing: letterSpacing);
  }

  /// Helper method to create text styles with fontFamilyText
  TextStyle _createTextStyleWithTextFont({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return _createTextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: AppStrings.fontFamilyText,
      height: height,
    );
  }

  /// Heading styles (21px, 600 weight)
  TextStyle get headingStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.21,
  );

  /// Title styles (20px, 600 weight)
  TextStyle get titleStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  /// Title styles (18px, 600 weight)
  TextStyle get titleMediumStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  /// Body text styles (17px, 500 weight)
  TextStyle get bodyMediumStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 24 / 17,
  );

  /// Body text styles (16px, 400 weight)
  TextStyle get bodyStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Body text styles (15px, 400 weight)
  TextStyle get bodySmallStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Caption styles (14px, 400 weight)
  TextStyle get captionStyle => _createTextStyleWithTextFont(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// RERA ID Label style
  TextStyle get reraIdLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.gray900,
  );

  /// RERA ID Value style
  TextStyle get reraIdValueStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.gray900,
  );

  /// Caption styles (13px, 400 weight)
  TextStyle get captionSmallStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
    height: 20 / 13,
  );

  /// Image tag style
  TextStyle get imageTagStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  LinearGradient get greenGradient => const LinearGradient(
    colors: [AppColors.greenGradientStart, AppColors.greenGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Plot detail label style (white)
  TextStyle get plotDetailLabelStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
  );

  /// Plot detail value style (white, bold)
  TextStyle get plotDetailValueStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// Amenity chip text style (vibrant green)
  TextStyle get amenityChipTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.approvedTagTextColor,
  );

  /// Available tag text style (vibrant green)
  TextStyle get availableTagTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.approvedTagTextColor,
  );

  /// Connectivity label style
  TextStyle get connectivityLabelStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.gray800,
  );

  /// Connectivity value style
  TextStyle get connectivityValueStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
  );

  /// Small gallery count overlay style
  TextStyle get galleryCountOverlaySmallStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  /// Property ID style
  TextStyle get propertyIdStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
  );

  ///  Pricing cost row label style (white, semi-transparent)
  TextStyle get costRowLabelStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite.withOpacity(0.9),
  );

  /// Pricing cost row value style (white, bold)
  TextStyle get costRowValueStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// EMI result label style (soft gray)
  TextStyle get emiResultLabelStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray600,
  );

  /// EMI result value style (bold dark blue)
  TextStyle get emiResultValueStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkBlueTitle,
  );

  // ============================================================================
  // THEME DATA - Material Theme configuration
  // ============================================================================

  /// Verified tag style (green)
  TextStyle get verifiedTagStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.approvedTagTextColor,
  );

  /// Label styles (12px, 400 weight)
  TextStyle get labelStyle => _createTextStyleWithTextFont(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
  );

  /// Button text styles (16px, 500 weight)
  TextStyle get buttonTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.buttonTextLight,
  );

  /// Button text styles (17px, 600 weight)
  TextStyle get buttonTextLargeStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 20 / 17,
    color: AppColors.blueSecondary,
  );

  /// Total amount label style (white, semi-transparent)
  TextStyle get totalAmountLabelStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite.withOpacity(0.9),
  );

  /// Total amount value style (white, large, bold)
  TextStyle get totalAmountValueStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  /// Button text styles (14px, 500 weight) - SF Pro Display font
  TextStyle get buttonTextSmallStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.errorRedDark,
    fontFamily: AppStrings.fontFamily,
  );

  /// Error text style for logout/delete buttons (16px, 400 weight, error red)
  TextStyle get errorTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.errorRed,
  );

  /// Form label style (15px, 400 weight, #38383D, letterSpacing -0.15) - SF Pro Text
  TextStyle get formLabelStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray90,
    fontFamily: AppStrings.fontFamilyText,
    height: 14 / 15,
    letterSpacing: -0.15,
  );

  /// Form input text style (17px, 400 weight, #797979)
  TextStyle get formInputTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray79,
  );

  /// Review section title style (15px, 600 weight, #003EA1, height 24/15) - SF Pro Display
  TextStyle get reviewSectionTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ultramarine90,
    height: 24 / 15,
  );

  /// Validation error text style for form fields (12px, 400 weight, error red) - SF Pro Text
  TextStyle get validationErrorTextStyle => _createTextStyleWithTextFont(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.errorRed,
    height: 16 / 12,
  );

  /// Terms & Conditions title style (17px, 600 weight, #1F2A37, SF Pro Display, line-height: normal)
  TextStyle get termsAndConditionsTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: AppStrings.fontFamily,
  );

  /// Terms & Conditions description style (15px, 400 weight, #64646D, SF Pro Display, line-height: 18/15)
  TextStyle get termsAndConditionsDescriptionStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    fontFamily: AppStrings.fontFamily,
    height: 18 / 15,
  );

  /// Phone login page title style (20px, bold, #1A1C29, height: 1.5)
  TextStyle get phoneLoginTitleStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
    height: 1.5,
  );

  /// Phone login page description style (15px, 400 weight, #797979, height: 1.5)
  TextStyle get phoneLoginDescriptionStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );

  /// Phone login input text style (18px, 500 weight)
  TextStyle get phoneLoginInputTextStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryDark,
  );

  /// Phone login error text style (14px, 400 weight, error red)
  TextStyle get phoneLoginErrorTextStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.errorRed,
  );

  /// Phone login back button text style (17px, 500 weight, #007AFF)
  TextStyle get phoneLoginBackButtonTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlueIOS,
  );

  /// Phone login terms text style (15px, 400 weight, #797979, height: 20/15)
  TextStyle get phoneLoginTermsTextStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray79,
    height: 20 / 15,
  );

  /// Phone login terms link style (13px, 500 weight, primary blue, height: 1.4)
  TextStyle get phoneLoginTermsLinkStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlue,
    height: 1.4,
  );

  /// Phone login keypad text style (26px, 600 weight)
  TextStyle get phoneLoginKeypadTextStyle => _createTextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );

  /// Phone login keypad special text style (18px, 600 weight)
  TextStyle get phoneLoginKeypadSpecialTextStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );

  /// OTP page title style (20px, bold, #1A1C29, height: 1.5)
  TextStyle get otpPageTitleStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
    height: 1.5,
  );

  /// OTP page description style (15px, 400 weight, #797979, height: 1.5)
  TextStyle get otpPageDescriptionStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );

  /// OTP page phone number style (15px, 400 weight, #1A1C29, SF Pro Medium, height: 1.5)
  TextStyle get otpPagePhoneNumberStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryDark,
    fontFamily: AppStrings.fontFamilyMedium,
    height: 1.5,
  );

  /// OTP page resend text style (15px, 400 weight, #797979)
  TextStyle get otpPageResendTextStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// OTP page resend link style (14px, 600 weight, primary blue)
  TextStyle get otpPageResendLinkStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlueIOS,
  );

  /// OTP box text style (15px, 400 weight, #797979, height: 1.5)
  TextStyle get otpBoxTextStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );

  /// OTP keypad text style (26px, bold)
  TextStyle get otpKeypadTextStyle => _createTextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
  );

  /// OTP keypad special text style (16px, bold)
  TextStyle get otpKeypadSpecialTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
  );

  /// Verified account badge text style (12px, 500 weight, white)
  TextStyle get verifiedAccountBadgeStyle => _createTextStyleWithTextFont(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.textWhite,
  );

  /// Badge text style (11px, 600 weight, white)
  TextStyle get badgeTextStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// Badge text style for due items (11px, 600 weight, due selection color)
  TextStyle get badgeDueTextStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.dueSelection,
  );

  /// Logout button text style (14px, 500 weight, logout red)
  TextStyle get logoutButtonTextStyle => _createTextStyleWithTextFont(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.logoutRed,
  );

  /// Dialog title style (20px, 600 weight, dark)
  TextStyle get dialogTitleStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  /// Dialog content style (16px, 400 weight, dark)
  TextStyle get dialogContentStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  /// Button text style for dialogs (14px, 500 weight)
  TextStyle get dialogButtonTextStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  /// SnackBar text style (14px, 400 weight, white)
  TextStyle get snackBarTextStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
  );

  /// Destructive section item text style (17px, 500 weight, error red)
  TextStyle get destructiveSectionItemStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.errorRed,
  );

  /// Profile specific styles
  TextStyle get profileLabelStyle => _createTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// Profile label style for avatar initial (32px, 600 weight, white)
  TextStyle get profileAvatarInitialStyle => _createTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  TextStyle get profileNameStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  TextStyle get profilePhoneStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
  );

  TextStyle get summaryValueStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    color: AppColors.textDark,
  );

  TextStyle get summaryLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 26 / 13,
    color: AppColors.textGray,
  );

  /// Section header style (21px, 600 weight, height 30/21)
  TextStyle get sectionHeaderStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 30 / 21,
    color: AppColors.textDark,
  );

  TextStyle get sectionItemMainStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 24 / 17,
    color: AppColors.textDark,
  );

  TextStyle get sectionItemTagStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    color: AppColors.textGray,
  );

  TextStyle get versionStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    color: AppColors.textGray80,
  );

  // ============================================================================
  // INPUT FIELD STYLES - Centralized input decoration styles
  // ============================================================================

  /// Helper method to get default border colors for input fields
  ({Color borderColor, Color focusedColor}) _getInputBorderColors({
    Color? borderColor,
    Color? focusedBorderColor,
  }) {
    return (
      borderColor: borderColor ?? AppColors.borderGrayLight,
      focusedColor: focusedBorderColor ?? AppColors.primaryPurpleBright,
    );
  }

  /// Helper method to create common hint style
  TextStyle _createInputHintStyle({double fontSize = 16}) {
    return _createTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textGrayLight,
    );
  }

  /// Standard text field decoration
  InputDecoration textFieldDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? borderColor,
    Color? focusedBorderColor,
  }) {
    final colors = _getInputBorderColors(
      borderColor: borderColor,
      focusedBorderColor: focusedBorderColor,
    );
    const borderRadius = 12.0;

    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: colors.borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: colors.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: colors.focusedColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
      ),
      errorStyle: validationErrorTextStyle,
      hintStyle: _createInputHintStyle(),
      labelStyle: _createTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Search field decoration
  InputDecoration searchFieldDecoration({
    String? hintText,
    Color? borderColor,
    Color? focusedBorderColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
      hintStyle: _createInputHintStyle(),
    );
  }

  /// Chat input field decoration
  InputDecoration chatInputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText ?? AppStrings.chatTypeMessagePlaceholder,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      isDense: true,
      hintStyle: _createTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryGray,
      ),
    );
  }

  // ============================================================================
  // BUTTON STYLES - Centralized button styles
  // ============================================================================

  /// Primary gradient button style
  BoxDecoration primaryGradientButtonDecoration({double borderRadius = 14}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [AppColors.primaryCyan, AppColors.primaryPurpleBright],
      ),
      border: Border.all(
        color: AppColors.borderGrey.withOpacity(0.9),
        width: 1.2,
      ),
    );
  }

  /// Outlined button style
  ButtonStyle outlinedButtonStyle({
    double borderRadius = 12,
    Color? borderColor,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return OutlinedButton.styleFrom(
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: textColor ?? AppColors.buttonTextDark,
      side: BorderSide(color: borderColor ?? AppColors.blueLight, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.zero,
    );
  }

  /// Elevated button style
  ButtonStyle elevatedButtonStyle({
    double borderRadius = 8,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primaryBlue,
      foregroundColor: foregroundColor ?? AppColors.textWhite,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // ============================================================================
  // PROPERTY DETAILS PAGE STYLES
  // ============================================================================

  /// Property details title style (18px, bold)
  TextStyle get propertyDetailsTitleStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.gray800,
  );

  /// Property details subtitle style (14px)
  TextStyle get propertyDetailsSubtitleStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
  );

  /// Property details value style (16px, bold)
  TextStyle get propertyDetailsValueStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.gray800,
  );

  /// Property details label style (14px)
  TextStyle get propertyDetailsLabelStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
  );

  /// Tab bar text style helper (15px, 400 weight) - base style for tab bars
  TextStyle _tabBarBaseStyle(Color color) =>
      _createTextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: color);

  /// Tab bar selected text style
  TextStyle get tabBarSelectedStyle => _tabBarBaseStyle(AppColors.blueInfo);

  /// Tab bar unselected text style
  TextStyle get tabBarUnselectedStyle => _tabBarBaseStyle(AppColors.gray800);

  /// Info card value style
  TextStyle get infoCardValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );

  /// Info card label style
  TextStyle get infoCardLabelStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray,
  );

  /// Property Info section title style
  /// color: #1F2A37; font-family: SF Pro Display; font-size: 15px; font-weight: 500; line-height: 24px
  TextStyle get propertyInfoSectionTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    fontFamily: AppStrings.fontFamily,
    height: 24 / 15,
  );

  /// Property Info card value style (value on top)
  /// color: #27272A; font-family: SF Pro Display; font-size: 15px; font-weight: 700
  TextStyle get propertyInfoCardValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.gray900,
  );

  /// Property Info card label style (label on bottom)
  /// color: #64646D; font-family: SF Pro Display; font-size: 13px; font-weight: 500
  TextStyle get propertyInfoCardLabelStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray70,
  );

  /// Facility chip label style
  TextStyle get facilityChipLabelStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
  );

  /// Agent card name style
  /// Agent card name style (17px, 600, Gray-90, line-height 18px, SF Pro Display)
  TextStyle get agentCardNameStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 18 / 17,
  );

  /// Agent card role / Real Estate Agent style (13px, 400, Gray-90, line-height 18px, SF Pro Display)
  TextStyle get agentCardRoleStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray90,
    height: 18 / 13,
  );

  /// Agent card Make a call / Message button text (13px, 600, Ultramarine-90, line-height 20px, SF Pro Display)
  TextStyle get agentCardActionButtonTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ultramarine90,
    height: 20 / 13,
  );

  /// Agent profile stat value style (17px, semibold, #38383D, SF Pro Display)
  TextStyle get agentProfileStatValueStyle => _createTextStyle(
    fontSize: 17,
    // Flutter supports w100 increments; w600 is the nearest practical match for 590.
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    fontFamily: AppStrings.fontFamily,
  );

  /// Agent profile stat label style (12px, regular, #64646D, SF Pro Display)
  TextStyle get agentProfileStatLabelStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
    fontFamily: AppStrings.fontFamily,
  );

  /// Agent card top section box shadow (0 4px 14px rgba(0,0,0,0.06))
  List<BoxShadow> get agentCardSectionBoxShadow => [
    BoxShadow(
      color: AppColors.agentCardSectionShadow,
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  /// Agent profile avatar box shadow (0 14px 24px rgba(0,0,0,0.08))
  List<BoxShadow> get agentAvatarBoxShadow => [
    BoxShadow(
      color: AppColors.agentAvatarShadow,
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ];

  /// Description section style
  TextStyle get descriptionStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
  );

  /// Read more style
  TextStyle get readMoreStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.blueInfo,
  );

  /// Expandable section title style (15px, 500 weight, line-height 24px)
  TextStyle get expandableSectionTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 24 / 15,
  );

  /// Project name label style (13px, 400 weight, line-height 18px)
  TextStyle get projectNameLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
    height: 18 / 13,
  );

  /// Project name value style (21px, 600 weight, line-height 26px)
  TextStyle get projectNameValueStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 26 / 21,
  );

  /// RERA approved badge text style (13px, 500 weight)
  TextStyle get reraApprovedBadgeTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.approvedTagTextColor,
  );

  /// Unit Details label style (13px, 500 weight, #64646D)
  TextStyle get unitDetailsLabelStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray70,
  );

  /// Unit Details value style (15px, 700 weight, #27272A)
  TextStyle get unitDetailsValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.gray900,
  );

  /// Amenities chip label style (11px, 500 weight, #64646D, center aligned)
  TextStyle get amenitiesChipLabelStyle => _createTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray70,
  );

  /// Safety & Clearances label style (15px, 500 weight, #0A0A0A, text font)
  TextStyle get safetyClearanceLabelStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.pdfTextColor,
  );

  /// Safety & Clearances badge text style (13px, 500 weight, #008236, line-height 16/13)
  TextStyle get safetyClearanceBadgeTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.transactionGreenEnd,
    height: 16 / 13,
  );

  /// Nearby place category style (15px, 500 weight, #0A0A0A, line-height 20px)
  TextStyle get nearbyPlaceCategoryStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.pdfTextColor,
    height: 20 / 15,
  );

  /// Nearby place item style (13px, 400 weight, #4A5565, line-height 20px, letter-spacing -0.15px)
  TextStyle get nearbyPlaceItemStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray80,
    height: 20 / 13,
  ).copyWith(letterSpacing: -0.15);

  /// Download button text style (15px, 500 weight, #0A0A0A, line-height normal)
  TextStyle get downloadButtonTextStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.pdfTextColor,
  );

  /// Commercial Location & Connectivity row label style
  /// color: #38383D; font-family: "SF Pro Display"; font-size: 15px; font-weight: 600; line-height: 20px; letter-spacing: -0.15px;
  TextStyle get commercialConnectivityRowLabelStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 20 / 15,
  ).copyWith(letterSpacing: -0.15);

  /// Commercial Location & Connectivity row value style
  /// color: #38383D; font-family: "SF Pro Text"; font-size: 15px; font-weight: 400; line-height: normal;
  TextStyle get commercialConnectivityRowValueStyle =>
      _createTextStyleWithTextFont(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray90,
      );

  /// Expandable label-value section title style (Technical & Infrastructure, etc.)
  /// color: #2A2B3F; font-family: SF Pro Display; font-size: 15px; font-weight: 600; line-height: 96%
  TextStyle get expandableLabelValueSectionTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.commercialSectionTitle,
    fontFamily: AppStrings.fontFamily,
    height: 0.96,
  );

  /// Expandable label-value section label style
  /// color: #64646D; font-family: SF Pro Text; font-size: 15px; font-weight: 400
  TextStyle get expandableLabelValueSectionLabelStyle =>
      _createTextStyleWithTextFont(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray70,
      );

  /// Expandable label-value section value style
  /// color: #38383D; font-family: SF Pro Text; font-size: 15px; font-weight: 600; text-align: right
  TextStyle get expandableLabelValueSectionValueStyle =>
      _createTextStyleWithTextFont(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textGray90,
      );

  /// Expandable label-value section badge value style (e.g., "Ready to Move")
  /// color: #008236; font-family: SF Pro Display; font-size: 13px; font-weight: 500; line-height: 16px
  TextStyle get expandableLabelValueBadgeTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.approvedTagTextColor,
    fontFamily: AppStrings.fontFamily,
    height: 16 / 13,
  );

  // ============================================================================
  // HOME PAGE STYLES
  // ============================================================================

  /// Search bar theme values
  double get searchBarHeight => 52.0;
  EdgeInsets get searchBarPadding => const EdgeInsets.symmetric(horizontal: 14);
  double get searchBarBorderRadius => 14.0;

  /// Property card theme values
  double get propertyCardWidth => 256.0;
  double get propertyCardHeight => 240.0;
  double get propertyCardBorderRadius => 12.0;
  EdgeInsets get propertyCardPadding => const EdgeInsets.all(12.0);

  /// Property card title style
  TextStyle get propertyCardTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textBlack,
  );

  /// Property card location style
  TextStyle get propertyCardLocationStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textBlack,
  );

  /// Category item theme values
  double get categoryItemBorderRadius => 8.0;
  EdgeInsets get categoryItemPadding =>
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

  /// Category item text style
  TextStyle get categoryItemTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textBlack,
  );

  /// Section header title style
  TextStyle get sectionHeaderTitleStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textBlack,
  );

  /// Section header action style
  TextStyle get sectionHeaderActionStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.blueInfo,
  );

  /// Location chip theme values
  double get locationChipBorderRadius => 8.0;
  double get locationChipBorderWidth => 1.0;
  EdgeInsets get locationChipPadding =>
      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

  /// Location chip text style
  TextStyle get locationChipTextStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textBlack,
  );

  // ============================================================================
  // FILTER PAGE STYLES
  // ============================================================================

  /// Filter title style (bottom popup)
  TextStyle get filterTitleBottomPopupStyle => _createTextStyleWithTextFont(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textBlack,
  );

  /// Filter title style (full screen)
  TextStyle get filterTitleFullScreenStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    color: AppColors.textBlack,
  );

  /// Reset filters button text style
  TextStyle get resetFiltersButtonTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textDarkSecondary,
  );

  /// Section title style (Looking for, Category, etc.)
  TextStyle get filterSectionTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDarkSecondary,
  );

  /// Residential & Commercial text style
  TextStyle get residentialCommercialTextStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textDarkSecondary,
  );

  /// Category chip text style helper (15px, 500 weight) - base style for category chips
  TextStyle _categoryChipBaseStyle(Color color) =>
      _createTextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color);

  /// Category chip text style (selected)
  TextStyle get categoryChipTextSelectedStyle =>
      _categoryChipBaseStyle(AppColors.blueInfo);

  /// Category chip text style (unselected)
  TextStyle get categoryChipTextUnselectedStyle =>
      _categoryChipBaseStyle(AppColors.textDarkSecondary);

  /// Average price text style
  TextStyle get avgPriceTextStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiaryLight,
  );

  /// Price range label style
  TextStyle get priceRangeLabelStyle => _createTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray,
  );

  /// Bed rooms text style helper (13px, height 20/13) - base style for bed rooms
  TextStyle _bedRoomsBaseStyle({
    required FontWeight fontWeight,
    required Color color,
  }) => _createTextStyle(
    fontSize: 13,
    fontWeight: fontWeight,
    height: 20 / 13,
    color: color,
  );

  /// Bed rooms selected style
  TextStyle get bedRoomsSelectedStyle =>
      _bedRoomsBaseStyle(fontWeight: FontWeight.w600, color: AppColors.gray900);

  /// Bed rooms unselected style
  TextStyle get bedRoomsUnselectedStyle =>
      _bedRoomsBaseStyle(fontWeight: FontWeight.w500, color: AppColors.gray600);

  // ============================================================================
  // SEARCH PAGE STYLES
  // ============================================================================

  /// Filter chip selected color
  Color get filterChipSelectedColor => AppColors.backgroundBlueLight;

  /// Filter chip selected text color
  Color get filterChipSelectedTextColor => AppColors.blueInfo;

  /// Filter chip unselected color
  Color get filterChipUnselectedColor => AppColors.backgroundWhite;

  /// Filter chip unselected text color
  Color get filterChipUnselectedTextColor => AppColors.textBlack;

  /// Search property card title style
  TextStyle get searchPropertyCardTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  /// Search property card location style
  TextStyle get searchPropertyCardLocationStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
  );

  // ============================================================================
  // BOOKING SLOT PAGE STYLES
  // ============================================================================

  /// Select date title style (21px, 600 weight, height 30/21) - same as sectionHeaderStyle
  TextStyle get selectDateTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 30 / 21,
    color: AppColors.textBlack,
  );

  /// Calendar text style
  TextStyle get calendarTextStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 18 / 15,
    color: AppColors.textDark,
  );

  /// Calendar subtitle style
  TextStyle get calendarSubtitleStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.gray400,
  );

  /// Month year text style
  TextStyle get monthYearTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 27 / 17,
    color: AppColors.textDark,
  );

  /// Booking slot section title style (15px, 600 weight)
  TextStyle get bookingSlotSectionTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 24 / 15,
    color: AppColors.textDark,
  );

  /// Booking slot date label style (13px, 400 weight)
  TextStyle get bookingSlotDateLabelStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.gray400,
  );

  /// Booking slot date value style (15px, 600 weight)
  TextStyle get bookingSlotDateValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 18 / 15,
    color: AppColors.textDark,
  );

  /// Booking slot time category style (14px, 600 weight)
  TextStyle get bookingSlotTimeCategoryStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  /// Booking slot time chip style (14px, 500 weight)
  TextStyle get bookingSlotTimeChipStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  /// Booking success title style (21px, 600 weight)
  TextStyle get bookingSuccessTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.0,
    color: AppColors.textDark,
  );

  /// Booking success description style (15px, 400 weight)
  TextStyle get bookingSuccessDescriptionStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 18 / 15,
    color: AppColors.gray400,
  );

  /// Booking details link style (15px, 500 weight)
  TextStyle get bookingDetailsLinkStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 18 / 15,
    color: AppColors.bluePrimary,
  );

  // ============================================================================
  // PROPERTY DETAILS PAGE ADDITIONAL STYLES
  // ============================================================================

  /// Property title style (22px, bold)
  TextStyle get propertyTitleStyle => _createTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  /// Property subtitle style (uses purple accent color)
  TextStyle get propertySubtitleStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.purpleAccent,
  );

  /// Map overlay text style (14px, 600 weight, white)
  TextStyle get mapOverlayTextStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// Gallery see all link style (17px, 600 weight)
  TextStyle get gallerySeeAllStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.blueInfo,
  );

  /// Gallery overlay text style (white, bold)
  TextStyle get galleryOverlayTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  /// Gallery overlay large text style (20px, bold, white)
  TextStyle get galleryOverlayLargeTextStyle => _createTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  /// Property location style (14px, 400 weight)
  TextStyle get propertyLocationStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
  );

  /// Calendar day header style (15px, 500 weight)
  TextStyle get calendarDayHeaderStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  /// Calendar day number style base (15px)
  TextStyle _calendarDayNumberBaseStyle({
    required FontWeight fontWeight,
    required Color color,
  }) => _createTextStyle(fontSize: 15, fontWeight: fontWeight, color: color);

  /// Calendar day number selected style
  TextStyle get calendarDayNumberSelectedStyle => _calendarDayNumberBaseStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// Calendar day number unselected style
  TextStyle get calendarDayNumberUnselectedStyle => _calendarDayNumberBaseStyle(
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  /// Calendar day number disabled style
  TextStyle get calendarDayNumberDisabledStyle => _calendarDayNumberBaseStyle(
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
  );

  /// Map error placeholder text style
  TextStyle get mapErrorTextStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
  );

  // ============================================================================
  // DOCUMENTS PAGE STYLES
  // ============================================================================

  /// Document tab selected style (15px, 500 weight, #006EFF)
  TextStyle get documentTabSelectedStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF006EFF),
  );

  /// Document tab unselected style (15px, 500 weight, #303131)
  TextStyle get documentTabUnselectedStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF303131),
  );

  /// Document title style (15px, 500 weight, #38383D)
  TextStyle get documentTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF38383D),
  );

  /// Document subtitle style (13px, 400 weight, #64646D) - SF Pro Text
  TextStyle get documentSubtitleStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF64646D),
  );

  /// Document metadata style (11px, 400 weight, #64646D, height 16/11) - SF Pro Text
  TextStyle get documentMetadataStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF64646D),
    height: 16 / 11,
  );

  /// Document count style
  TextStyle get documentCountStyle => _createTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  /// PDF badge text style (10px, 500 weight, #0A0A0A)
  TextStyle get pdfBadgeTextStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.pdfTextColor,
  );

  // ============================================================================
  // TRANSACTION STYLES
  // ============================================================================

  /// Total Amount Paid label style (13px, 400 weight, #EFFFF4) - SF Pro Text
  TextStyle get transactionTotalLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.transactionGreen10,
  );

  /// Total Amount value style (17px, 600 weight, white, height 24/17) - SF Pro Display
  TextStyle get transactionTotalAmountStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    color: AppColors.textWhite,
  );

  /// Transaction count in card style (13px, 400 weight, #EFFFF4, height 20/13) - SF Pro Text
  TextStyle get transactionCardCountStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    color: AppColors.transactionGreen10,
  );

  /// Statement button text style (13px, 500 weight, #008236) - SF Pro Text
  TextStyle get statementButtonTextStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.transactionGreenEnd,
  );

  /// Transaction count number style (13px, 500 weight, #38383D) - SF Pro Display
  TextStyle get transactionCountNumberStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF38383D),
  );

  /// Transaction count label style (13px, 400 weight, #64646D) - SF Pro Text
  TextStyle get transactionCountLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF64646D),
  );

  /// Transaction title style (15px, 500 weight, #38383D, height 20/15) - SF Pro Display
  TextStyle get transactionTitleStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
    color: const Color(0xFF38383D),
  );

  /// Transaction property name style (15px, 400 weight, #64646D, height 20/15) - SF Pro Text
  TextStyle get transactionPropertyStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 20 / 15,
    color: const Color(0xFF64646D),
  );

  /// Transaction amount style (17px, 600 weight, #38383D, height 24/17) - SF Pro Display
  TextStyle get transactionAmountStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 24 / 17,
    color: const Color(0xFF38383D),
  );

  /// Transaction status style (13px, 500 weight, #008236) - SF Pro Text
  TextStyle get transactionStatusStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.transactionGreenEnd,
  );

  /// Transaction status failed style (13px, 500 weight, red) - SF Pro Text
  TextStyle get transactionStatusFailedStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.errorRed,
  );

  /// Transaction payment method style (11px, 400 weight, #64646D, height 16/11) - SF Pro Text
  TextStyle get transactionPaymentMethodStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: const Color(0xFF64646D),
  );

  /// Transaction date style (11px, 400 weight, #64646D, height 16/11) - SF Pro Text
  TextStyle get transactionDateStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: const Color(0xFF64646D),
  );

  /// Transaction ID style (13px, 400 weight, #64646D, height 16/13) - SF Pro Text
  TextStyle get transactionIdStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 16 / 13,
    color: const Color(0xFF64646D),
  );

  // ============================================================================
  // THEME DATA - Material Theme configuration
  // ============================================================================

  ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        primary: primaryPurple,
        secondary: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: cardLight,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      fontFamily: AppStrings.fontFamily,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      fontFamily: AppStrings.fontFamily,
    );
    return base.copyWith(textTheme: _buildTextTheme(base.textTheme));
  }

  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontFamily: AppStrings.fontFamily,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontFamily: AppStrings.fontFamily,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontFamily: AppStrings.fontFamily,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontFamily: AppStrings.fontFamily,
      ),
      bodySmall: base.bodySmall?.copyWith(fontFamily: AppStrings.fontFamily),
      labelLarge: base.labelLarge?.copyWith(fontFamily: AppStrings.fontFamily),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: AppStrings.fontFamily,
      ),
      labelSmall: base.labelSmall?.copyWith(fontFamily: AppStrings.fontFamily),
    );
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ============================================================================
  // EDIT PROFILE STYLES
  // ============================================================================

  /// Edit Profile app bar title style (18px, bold, black)
  TextStyle get editProfileTitleStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textBlack,
  );

  /// Edit Profile section title style (21px, 600 weight, #38383D)
  TextStyle get editProfileSectionTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
  );

  /// Edit Profile input label style (15px, 400 weight, #38383D, line-height: 14px, letter-spacing: -0.15px)
  TextStyle get editProfileInputLabelStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray90,
    height: 14 / 15,
  ).copyWith(letterSpacing: -0.15);

  /// Edit Profile input field text style (16px, 400 weight, dark)
  TextStyle get editProfileInputTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  /// Edit Profile secondary text style (16px, 400 weight, gray) - for "Tap to change photo"
  TextStyle get editProfileSecondaryTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray,
  );

  /// Edit Profile dropdown icon color
  Color get editProfileDropdownIconColor => AppColors.textGray;

  /// Edit Profile shadow style
  List<BoxShadow> get editProfileShadowStyle => [
    BoxShadow(
      color: AppColors.textBlack.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, -2),
    ),
  ];

  /// Edit Profile section container shadow (shadow on all sides)
  List<BoxShadow> get editProfileSectionShadowStyle => [
    BoxShadow(
      color: AppColors.textBlack.withOpacity(0.05),
      blurRadius: 8,
      spreadRadius: 1,
      offset: const Offset(0, 0),
    ),
  ];

  /// App bar divider shadow style
  List<BoxShadow> get appBarDividerShadowStyle => [
    BoxShadow(
      color: AppColors.textBlack.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// Edit Profile input field decoration
  InputDecoration editProfileInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.backgroundWhite,
      hintStyle: _createInputHintStyle(fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderGray40, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderGray40, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryPurpleBright,
          width: 2,
        ),
      ),
    );
  }

  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }

  // ============================================================================
  // NOTIFICATION SETTINGS STYLES
  // ============================================================================

  /// Notification section title style (21px, 600 weight, #38383D, line-height: 30px)
  TextStyle get notificationSectionTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 30 / 21,
  );

  /// Notification option primary label style (15px, 500 weight, #38383D, line-height: 14px)
  TextStyle get notificationOptionPrimaryStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
    height: 14 / 15,
  );

  /// Notification option secondary label style (13px, 400 weight, #64646D, line-height: 20px)
  TextStyle get notificationOptionSecondaryStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray70,
        height: 20 / 13,
      );

  // ============================================================================
  // SECURITY & PRIVACY STYLES
  // ============================================================================

  /// Account Secure title style (17px, 500 weight, #04592C, line-height: 24px)
  TextStyle get accountSecureTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.securityGreen90,
    height: 24 / 17,
  );

  /// Account Secure subtitle style (13px, 400 weight, #079449, line-height: 20px)
  TextStyle get accountSecureSubtitleStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.securityGreen70,
    height: 20 / 13,
  );

  /// Enabled status style (13px, 500 weight, #00AB56, line-height: 20px)
  TextStyle get enabledStatusStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.securityGreen60,
    height: 20 / 13,
  );

  /// Delete Account text style (17px, 500 weight, #E7000B, line-height: 24px, letter-spacing: -0.312px)
  TextStyle get deleteAccountTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.errorRed,
    height: 24 / 17,
  ).copyWith(letterSpacing: -0.312);

  /// Security Tip container shadow style
  List<BoxShadow> get securityTipShadowStyle => [
    BoxShadow(
      color: AppColors.securityTipYellowShadow.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ];

  /// Account Secure container shadow style
  List<BoxShadow> get accountSecureShadowStyle => [
    BoxShadow(
      color: AppColors.securityGreenShadow.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ];

  /// Security Tip title style (17px, 500 weight, #7B3306, line-height: 24px)
  TextStyle get securityTipTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.securityTipTitle,
    height: 24 / 17,
  );

  /// Security Tip description style (13px, 400 weight, #973C00, line-height: 20px, letter-spacing: -0.15px)
  TextStyle get securityTipDescriptionStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.securityTipDescription,
    height: 20 / 13,
  ).copyWith(letterSpacing: -0.15);

  // ============================================================================
  // CONTACT SUPPORT STYLES
  // ============================================================================

  /// Contact Support section title style (21px, 600 weight, #38383D, line-height: 30px)
  TextStyle get contactSupportSectionTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 30 / 21,
  );

  /// Contact Support primary text style (17px, 500 weight, #0A0A0A)
  TextStyle get contactSupportPrimaryTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.pdfTextColor,
  );

  /// Contact Support secondary text style (15px, 400 weight, #4A5565)
  TextStyle get contactSupportSecondaryTextStyle =>
      _createTextStyleWithTextFont(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray80,
      );

  /// Contact Support description text style (13px, 400 weight, #64646D)
  TextStyle get contactSupportDescriptionTextStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray70,
      );

  /// Contact Support time text style (13px, 400 weight, #64646D)
  TextStyle get contactSupportTimeTextStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
  );

  /// Contact Support badge text style (13px, 400 weight, #00A63E)
  TextStyle get contactSupportBadgeTextStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.transactionGreenStart,
  );

  /// Contact Support office hours day style (13px, 400 weight, #64646D, line-height: 20px)
  TextStyle get contactSupportOfficeHoursDayStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray70,
        height: 20 / 13,
      );

  /// Contact Support office hours time style (15px, 500 weight, #38383D, line-height: 20px)
  TextStyle get contactSupportOfficeHoursTimeStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
    height: 20 / 15,
  );

  /// Contact Support Quick Help title style (17px, 500 weight, #003EA1, line-height: 24px)
  TextStyle get contactSupportQuickHelpTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.ultramarine90,
    height: 24 / 17,
  );

  /// Contact Support Quick Help description style (13px, 400 weight, #003EA1, line-height: 20px, letter-spacing: -0.15px)
  TextStyle get contactSupportQuickHelpDescriptionStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.ultramarine90,
        height: 20 / 13,
      ).copyWith(letterSpacing: -0.15);

  /// Contact Support Quick Help button style (15px, 500 weight, #0A0A0A, line-height: 20px)
  TextStyle get contactSupportQuickHelpButtonStyle =>
      _createTextStyleWithTextFont(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.pdfTextColor,
        height: 20 / 15,
      );

  /// Contact Support section container shadow style (0 14px 24px 0 rgba(0, 0, 0, 0.06))
  List<BoxShadow> get contactSupportSectionShadowStyle => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 14),
    ),
  ];

  // ============================================================================
  // HELP CENTER STYLES
  // ============================================================================

  /// Help Center section title style (21px, 600 weight, #0A0A0A, line-height: 30px)
  TextStyle get helpCenterSectionTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.pdfTextColor,
    height: 30 / 21,
  );

  /// Help Center quick link text style (15px, 500 weight, #0A0A0A, line-height: 20px)
  TextStyle get helpCenterQuickLinkTextStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.pdfTextColor,
    height: 20 / 15,
  );

  /// Help Center item text style (15px, 500 weight, #38383D, line-height: 20px)
  TextStyle get helpCenterItemTextStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
    height: 20 / 15,
  );

  /// Help Center Contact Support title style (17px, 500 weight, #003EA1, line-height: 24px)
  TextStyle get helpCenterContactSupportTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.ultramarine90,
    height: 24 / 17,
  );

  /// Help Center Contact Support subtitle style (13px, 400 weight, #003EA1, line-height: 20px, letter-spacing: -0.15px)
  TextStyle get helpCenterContactSupportSubtitleStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.ultramarine90,
        height: 20 / 13,
      ).copyWith(letterSpacing: -0.15);

  /// Help Center Contact Support button text style (15px, 500 weight, #FFF, line-height: 20px)
  TextStyle get helpCenterContactSupportButtonTextStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
    height: 20 / 15,
  );

  /// Help Center email address style (17px, 500 weight, #38383D)
  TextStyle get helpCenterEmailAddressStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
  );

  /// Help Center reply time style (13px, 400 weight, #64646D)
  TextStyle get helpCenterReplyTimeStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
  );

  /// Help Center form label style (15px, 400 weight, #38383D, line-height: 14px, letter-spacing: -0.15px)
  TextStyle get helpCenterFormLabelStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray90,
    height: 14 / 15,
  ).copyWith(letterSpacing: -0.15);

  /// Help Center input text style (17px, 400 weight, #797979)
  TextStyle get helpCenterInputTextStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// Help Center Send Message button text style (15px, 500 weight, #FFF, line-height: 20px)
  TextStyle get helpCenterSendMessageButtonStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
    height: 20 / 15,
  );

  /// Help Center Need Help title style (17px, 500 weight, #7B3306, line-height: 24px)
  TextStyle get helpCenterNeedHelpTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.securityTipTitle,
    height: 24 / 17,
  );

  /// Help Center Call Us button text style (15px, 500 weight, #FFF, line-height: 20px)
  TextStyle get helpCenterCallUsButtonStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
    height: 20 / 15,
  );

  /// Help Center immediate assistance style (13px, 400 weight, #973C00, line-height: 20px, letter-spacing: -0.15px)
  TextStyle get helpCenterImmediateAssistanceStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.securityTipDescription,
        height: 20 / 13,
      ).copyWith(letterSpacing: -0.15);

  // ============================================================================
  // ABOUT PAYSFT STYLES
  // ============================================================================

  /// About PaySFT title style (21px, 600 weight, #FFF)
  TextStyle get aboutPaySFTTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// About PaySFT subtitle style (15px, 400 weight, #FFF, line-height: 20px)
  TextStyle get aboutPaySFTSubtitleStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 20 / 15,
  );

  /// About PaySFT version style (13px, 400 weight, #FFF, line-height: 16px)
  TextStyle get aboutPaySFTVersionStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 16 / 13,
  );

  /// About PaySFT section title style (21px, 600 weight, #38383D)
  TextStyle get aboutPaySFTSectionTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
  );

  /// About PaySFT mission text style (15px, 400 weight, #64646D, line-height: 24px)
  TextStyle get aboutPaySFTMissionTextStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 24 / 15,
  );

  /// About PaySFT feature title style (17px, 500 weight, #38383D, line-height: 24px)
  TextStyle get aboutPaySFTFeatureTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
    height: 24 / 17,
  );

  /// About PaySFT feature description style (15px, 400 weight, #64646D, line-height: 20px)
  TextStyle get aboutPaySFTFeatureDescriptionStyle =>
      _createTextStyleWithTextFont(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray70,
        height: 20 / 15,
      );

  /// About PaySFT impact value style (17px, 600 weight, line-height: 24px) - color will be set dynamically
  TextStyle get aboutPaySFTImpactValueStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 24 / 17,
  ).copyWith(fontFamily: 'Inter');

  /// About PaySFT impact label style (11px, 400 weight, #4A5565, line-height: 16px)
  TextStyle get aboutPaySFTImpactLabelStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray80,
    height: 16 / 11,
  );

  /// About PaySFT company label style (13px, 400 weight, #64646D, line-height: 20px)
  TextStyle get aboutPaySFTCompanyLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 20 / 13,
  );

  /// About PaySFT company value style (15px, 500 weight, #38383D, line-height: 20px)
  TextStyle get aboutPaySFTCompanyValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
    height: 20 / 15,
  );

  /// About PaySFT contact label style (15px, 400 weight, #64646D, line-height: 20px)
  TextStyle get aboutPaySFTContactLabelStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 20 / 15,
  );

  /// About PaySFT contact value style (15px, 400 weight, #0A68FF, line-height: 20px)
  TextStyle get aboutPaySFTContactValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.bluePrimary,
    height: 20 / 15,
  );

  /// About PaySFT commitment title style (17px, 500 weight, #04592C, line-height: 24px)
  TextStyle get aboutPaySFTCommitmentTitleStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.green90,
    height: 24 / 17,
  );

  /// About PaySFT commitment description style (13px, 400 weight, #04592C, line-height: 20px)
  TextStyle get aboutPaySFTCommitmentDescriptionStyle =>
      _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.green90,
        height: 20 / 13,
      );

  // ============================================================================
  // HOME PAGE NEW SECTIONS STYLES
  // ============================================================================

  /// Total Properties label style (13px, 400 weight, #64646D, line-height: 20px)
  TextStyle get totalPropertiesLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 20 / 13,
  );

  /// Property count style (17px, 600 weight, #38383D, line-height: 24px)
  TextStyle get propertyCountStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 24 / 17,
  );

  /// Pending Payments label style (13px, 400 weight, #64646D, line-height: 20px)
  TextStyle get pendingPaymentsLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 20 / 13,
  );

  /// Payment value style (17px, 600 weight, #F54900, line-height: 24px)
  TextStyle get paymentValueStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.paymentOrange,
    height: 24 / 17,
  );

  /// My Properties title style (21px, 600 weight, #38383D, letter-spacing: -0.449px)
  TextStyle get myPropertiesTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    letterSpacing: -0.449,
  );

  /// View All style (15px, 500 weight, #0A68FF, line-height: 20px)
  TextStyle get viewAllStyle => _createTextStyleWithTextFont(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.ultramarine70,
    height: 20 / 15,
  );

  /// Featured property name style (17px, 600 weight, #FFF)
  TextStyle get featuredPropertyNameStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  /// Featured property location style (13px, 400 weight, #FFF, line-height: 18px)
  TextStyle get featuredPropertyLocationStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    height: 18 / 13,
  );

  /// Next Payment label style (13px, 400 weight, #F2F7FF, line-height: 18px)
  TextStyle get nextPaymentLabelStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.ultramarine10,
    height: 18 / 13,
  );

  /// Next Payment value style (17px, 600 weight, #F2F7FF, line-height: 24px)
  TextStyle get nextPaymentValueStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.ultramarine10,
    height: 24 / 17,
  );

  /// Due Date label style (13px, 400 weight, #F2F7FF, line-height: 18px, right aligned)
  TextStyle get dueDateLabelStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.ultramarine10,
    height: 18 / 13,
  );

  /// Due Date value style (17px, 600 weight, #F2F7FF, line-height: 24px, right aligned)
  TextStyle get dueDateValueStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.ultramarine10,
    height: 24 / 17,
  );

  /// Property type count style (21px, 600 weight, #38383D, line-height: 20px)
  TextStyle get propertyTypeCountStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 20 / 21,
  );

  /// Property type label style (13px, 400 weight, #64646D, line-height: 16px)
  TextStyle get propertyTypeLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 16 / 13,
  );

  /// Quick Actions title style (21px, 600 weight, #38383D, line-height: 30px)
  TextStyle get quickActionsTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 30 / 21,
  );

  /// Quick action name style (15px, 600 weight, #38383D, line-height: 20px, letter-spacing: -0.15px)
  TextStyle get quickActionNameStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
    height: 20 / 15,
    letterSpacing: -0.15,
  );

  /// Quick action tag style (13px, 400 weight, #64646D, line-height: 16px)
  TextStyle get quickActionTagStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
    height: 16 / 13,
  );

  // ============================================================================
  // EXPLORE PAGE STYLES
  // ============================================================================

  /// Explore page header title style (24px, 700 weight, #38383D)
  TextStyle get explorePageTitleStyle => _createTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textGray90,
  );

  /// Property count number style (13px, 500 weight, #38383D)
  TextStyle get propertyCountNumberStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
  );

  /// Property count label style (13px, 400 weight, #64646D) - SF Pro Text
  TextStyle get propertyCountLabelStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
  );

  /// Empty state text style (16px, 400 weight, #64646D)
  TextStyle get emptyStateTextStyle => _createTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
  );

  /// Favorites empty title style
  /// color: #0A68FF; font-size: 21px; font-weight: 600; SF Pro Display
  TextStyle get favoritesEmptyTitleStyle => _createTextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: AppColors.bluePrimary,
  );

  /// Rera number style (13px, 400 weight, #9DA4AE, line-height: 18px) - SF Pro
  TextStyle get reraNumberStyle => _createTextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.reraNumberGray,
    height: 18 / 13,
  );

  /// Property card title style for explore (18px, 600 weight, #38383D)
  TextStyle get explorePropertyCardTitleStyle => _createTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textGray90,
  );

  /// Trilight badge text style (12px, 500 weight, purple accent)
  TextStyle get trilightBadgeStyle => _createTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.purpleAccent,
  );

  /// Property info label style (11px, 400 weight, #64646D) - SF Pro Text
  TextStyle get propertyInfoLabelStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textGray70,
  );

  /// Property info value style (15px, 500 weight, #38383D) - SF Pro Display
  TextStyle get propertyInfoValueStyle => _createTextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textGray90,
  );

  /// Payment container label style (11px, 500 weight, #B64F00) - SF Pro Text
  TextStyle get paymentContainerLabelStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.orange80,
  );

  /// Payment container amount style (17px, 600 weight, #903F00) - SF Pro Display
  TextStyle get paymentContainerAmountStyle => _createTextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.orange90,
  );

  /// Payment container date style (13px, 500 weight, #FFF5EB) - SF Pro Text
  TextStyle get paymentContainerDateStyle => _createTextStyleWithTextFont(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.orange10,
  );

  /// Property badge label style (11px, 500 weight, white) - SF Pro Text
  TextStyle get propertyBadgeLabelStyle => _createTextStyleWithTextFont(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  // ============================================================================
  // DECORATION STYLES - Box decorations for containers
  // ============================================================================

  /// Bottom request bar decoration (glassmorphism)
  /// background: rgba(255, 255, 255, 0.60);
  /// box-shadow: 0 -10px 24px 0 rgba(0, 0, 0, 0.08);
  BoxDecoration get bottomRequestBarDecoration => BoxDecoration(
    color: AppColors.overlayWhite60,
    boxShadow: const [
      BoxShadow(
        color: AppColors.overlayBlack08,
        offset: Offset(0, -10),
        blurRadius: 24,
      ),
    ],
  );

  /// Request visit button gradient
  /// border-radius: 28px; background: linear-gradient(90deg, #0A68FF 0%, #700AFF 100%);
  LinearGradient get requestVisitGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.bluePrimary, // #0A68FF
      Color(
        0xFF700AFF,
      ), // #700AFF (use constant via AppColors if reused elsewhere)
    ],
  );

  /// Pay Token section container decoration for Residential properties
  /// border-radius: 10px; border: 1px solid var(--Global-Ultramarine-30, #C9DEFF);
  /// background: var(--Global-Ultramarine-10, #F2F7FF);
  /// box-shadow: 0 14px 24px 0 rgba(105, 189, 238, 0.06);
  BoxDecoration get payTokenSectionDecorationResidential => BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.ultramarine30, width: 1),
    color: AppColors.ultramarine10,
    boxShadow: [
      BoxShadow(
        color: AppColors.ultramarineShadow,
        offset: const Offset(0, 14),
        blurRadius: 24,
        spreadRadius: 0,
      ),
    ],
  );

  /// Pay Token section container decoration for Commercial properties
  /// border-radius: 10px; border: 1px solid var(--Global-Purple-30, #DED0FE);
  /// background: var(--Global-Purple-10, #F5F1FD);
  /// box-shadow: 0 14px 24px 0 rgba(164, 125, 242, 0.08);
  BoxDecoration get payTokenSectionDecorationCommercial => BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.purple30, width: 1),
    color: AppColors.purple10,
    boxShadow: [
      BoxShadow(
        color: AppColors.purpleShadow,
        offset: const Offset(0, 14),
        blurRadius: 24,
        spreadRadius: 0,
      ),
    ],
  );
}
