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
    ).copyWith(
      height: height,
      letterSpacing: letterSpacing,
    );
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

  /// Caption styles (13px, 400 weight)
  TextStyle get captionSmallStyle => _createTextStyleWithTextFont(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray,
        height: 20 / 13,
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

  /// Button text styles (14px, 500 weight) - SF Pro Display font
  TextStyle get buttonTextSmallStyle => _createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: AppColors.errorRedDark,
        fontFamily: AppStrings.fontFamily,
      );

  /// Profile specific styles
  TextStyle get profileLabelStyle => _createTextStyle(
        fontSize: 24,
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
      focusedColor: focusedBorderColor ?? AppColors.blueAccent,
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
  InputDecoration chatInputDecoration({
    String? hintText,
  }) {
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
  BoxDecoration primaryGradientButtonDecoration({
    double borderRadius = 14,
  }) {
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
      side: BorderSide(
        color: borderColor ?? AppColors.blueLight,
        width: 1,
      ),
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
  TextStyle _tabBarBaseStyle(Color color) => _createTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
      );

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

  /// Facility chip label style
  TextStyle get facilityChipLabelStyle => _createTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray,
      );

  /// Agent card name style
  TextStyle get agentCardNameStyle => _createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      );

  /// Agent card role style
  TextStyle get agentCardRoleStyle => _createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray400,
      );

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
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textBlack,
      );

  /// Property card location style
  TextStyle get propertyCardLocationStyle => _createTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray500,
      );

  /// Category item theme values
  double get categoryItemBorderRadius => 8.0;
  EdgeInsets get categoryItemPadding => const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

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
  EdgeInsets get locationChipPadding => const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

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
  TextStyle _categoryChipBaseStyle(Color color) => _createTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
      );

  /// Category chip text style (selected)
  TextStyle get categoryChipTextSelectedStyle => _categoryChipBaseStyle(AppColors.blueInfo);

  /// Category chip text style (unselected)
  TextStyle get categoryChipTextUnselectedStyle => _categoryChipBaseStyle(AppColors.textDarkSecondary);

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
  }) =>
      _createTextStyle(
        fontSize: 13,
        fontWeight: fontWeight,
        height: 20 / 13,
        color: color,
      );

  /// Bed rooms selected style
  TextStyle get bedRoomsSelectedStyle => _bedRoomsBaseStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      );

  /// Bed rooms unselected style
  TextStyle get bedRoomsUnselectedStyle => _bedRoomsBaseStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.gray600,
      );

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
  TextStyle _calendarDayNumberBaseStyle({required FontWeight fontWeight, required Color color}) => _createTextStyle(
        fontSize: 15,
        fontWeight: fontWeight,
        color: color,
      );

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
    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
    );
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
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: AppStrings.fontFamily,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: AppStrings.fontFamily,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: AppStrings.fontFamily,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: AppStrings.fontFamily,
      ),
    );
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }
}
