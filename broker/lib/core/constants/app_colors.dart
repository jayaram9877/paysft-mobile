import 'package:flutter/material.dart';

/// Application color constants
/// All colors used throughout the app should be defined here with meaningful names
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primaryBlue = Color(0xFF5B9FFF);
  static const Color snackbarColor = Color(0xFFF2F3FD);
  static const Color primaryPurple = Color(0xFF7B68EE);
  static const Color primaryCyan = Color(0xFF00B4EA);
  static const Color primaryPurpleDark = Color(0xFF6A0DAD);
  static const Color primaryPurpleBright = Color(0xFF8A00FF);
  static const Color primaryBlueIOS = Color(0xFF007AFF);
  static const Color primaryBlueLink = Color(0xFF0084FF);

  // Chat Colors
  static const Color chatBackground = Color(0xFFF0F2F5);
  static const Color chatSentMessageBubble = Color(0xFFCAD8EE);
  static const Color chatSentMessageText = Color(0xFF133365);
  static const Color chatSentMessageTimestamp = Color(0xFF5472A1);
  static const Color chatReceivedMessageBubble = Colors.white;
  static const Color chatReceivedMessageText = Color(0xFF111B21);
  static const Color chatReceivedMessageTimestamp = Color(0xFF111B21);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFF1A1C29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSecondaryGray = Color(0xFF667781);
  static const Color textTertiary = Color(0xFF797979);
  static const Color textTertiaryLight = Color(0xFF808089);
  static const Color textIconGray = Color(0xFF54656F);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundGray = Color(0xFFF8F8F8);
  static const Color backgroundCard = Colors.white;

  // Border Colors
  static const Color borderLight = Color(0xFFE4E6EB);
  static const Color borderGray = Color(0xFFD7D7D7);
  static const Color borderDivider = Color(0xFFDDDDE3);

  // Status Colors
  static const Color statusOnline = Color(0xFF53BDEB);
  static const Color statusError = Colors.red;

  // Avatar Colors
  static const Color avatarBackground = Color(0xFFE4E6EB);

  // Button Colors
  static const Color buttonTextDark = Color(0xFF1A1C29);
  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonBorderGray = Color(0xFFD7D7D7);
  static const Color buttonDisabledText = Color(0xFF3C3C43);

  // Icon Colors
  static const Color iconGray = Color(0xFFD7D7D7);
  static const Color iconDark = Color(0xFF1A1C29);

  // Error/Placeholder Colors
  static const Color errorBackground = Colors.grey;
  static const Color errorBackgroundLight = Color(0xFFF3F3F3);
  static const Color grey50 = Color(0xFFF9F9F9);
  static const Color grey200 = Color(0xFFE5E5E5);
  static const Color grey300 = Color(0xFFD1D1D1);
  static const Color grey600 = Color(0xFF666666);

  // Glass/Overlay Colors
  static const Color overlayBlack25 = Color(0x40000000); // 25% opacity
  static const Color overlayBlack50 = Color(0x80000000); // 50% opacity
  static const Color overlayBlack08 = Color(0x14000000); // 8% opacity
  static const Color overlayBlack06 = Color(0x0F000000); // 6% opacity
  static const Color overlayWhite90 = Color(0xE6FFFFFF); // 90% opacity
  static const Color overlayWhite25 = Color(0x40FFFFFF); // 25% opacity
  static const Color overlayWhite20 = Color(0x33FFFFFF); // 20% opacity
  static const Color overlayWhite05 = Color(0x0DFFFFFF); // 5% opacity
  static const Color overlayWhite30 = Color(0x4DFFFFFF); // 30% opacity
  static const Color overlayWhite40 = Color(0x66FFFFFF); // 40% opacity

  // Gradient Colors
  static const Color gradientGrey1 = Color(0xFFC0BFBF);
  static const Color gradientGrey2 = Color(0xFFD4D3D3);
  static const Color gradientCloseButton = Color(0xFFEAE9E9);
  static const Color gradientCloseIcon = Color(0xFF737373);

  // Button Disabled Colors
  static const Color buttonDisabledBackground = Color(0xFFD7D7D7);

  // Border Colors
  static const Color borderGrey = Color(0xFF737272);
  
  // Additional Colors from codebase analysis
  static const Color textDark = Color(0xFF1F2A37);
  static const Color textDarkSecondary = Color(0xFF38383D);
  static const Color textGray = Color(0xFF64646D);
  static const Color textGrayLight = Color(0xFF9E9E9E);
  static const Color textGrayMedium = Color(0xFF9DA4AE);
  static const Color textBlack = Color(0xFF000000);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Blue variants
  static const Color bluePrimary = Color(0xFF0A68FF);
  static const Color blueSecondary = Color(0xFF3B85FF);
  static const Color blueLight = Color(0xFFC9DEFF);
  static const Color blueAccent = Color(0xFF2F66F6);
  static const Color blueDark = Color(0xFF3B6EF6);
  static const Color blueGradientStart = Color(0xFF470AFF);
  static const Color blueGradientEnd = Color(0xFF0A68FF);
  static const Color blueProfileStart = Color(0xFF155DFC);
  static const Color blueProfileEnd = Color(0xFF1447E6);
  static const Color blueInfo = Color(0xFF007AFF);
  static const Color blueInfoLight = Color(0xFF70A6FF);
  
  // Purple variants
  static const Color purpleGradientEnd = Color(0xFF6A1BF0);
  static const Color purpleAccent = Color(0xFF3538CD);
  
  // Background variants
  static const Color backgroundGrayLight = Color(0xFFF7F7F7);
  static const Color backgroundBlueLight = Color(0xFFF2F7FF);
  static const Color backgroundBlueVeryLight = Color(0xFFEEF4FF);
  static const Color backgroundWhiteLight = Color(0xFFFAFCFF);
  static const Color backgroundGrayVeryLight = Color(0xFFF5F5FA);
  static const Color backgroundGrayMedium = Color(0xFFF2F2F7);
  static const Color backgroundDotted = Color(0xFFE4E4E7);
  
  // Border variants
  static const Color borderGrayLight = Color(0xFFE0E0E0);
  static const Color borderGrayMedium = Color(0xFFEBEBF0);
  static const Color borderGray40 = Color(0xFFC4C4CF); // Global/Gray 40
  static const Color borderBlueLight = Color(0xFFC9DEFF);
  static const Color borderGrayDark = Color(0xFFBDBDBD);
  static const Color borderDividerGray = Color(0xFFD9D9D9);
  
  // Status/Accent colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color errorRedDark = Color(0xFFE7000B);
  static const Color errorRedLight = Color(0xFFFFC9C9);
  static const Color successGreenLight = Color(0xFF34C759);
  
  // Neutral grays
  static const Color gray50 = Color(0xFFF9F9F9);
  static const Color gray100 = Color(0xFFF3F3F3);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD1D1D1);
  static const Color gray400 = Color(0xFF9DA4AE);
  static const Color gray500 = Color(0xFF757575);
  static const Color gray600 = Color(0xFF666666);
  static const Color gray700 = Color(0xFF52525B);
  static const Color gray800 = Color(0xFF333333);
  static const Color gray900 = Color(0xFF27272A);
  
  // Text specific
  static const Color textGray70 = Color(0xFF64646D);
  static const Color textGray80 = Color(0xFF4A5565);
  
  // Additional missing colors
  static const Color blueInfoSelected = Color(0xFF0157E0);
  static const Color backgroundBlueSelected = Color(0xFFEBF2FF);
  static const Color backgroundBlueSelectedLight = Color(0xFFBBDEFB);
  static const Color backgroundBlueSelectedVeryLight = Color(0xFFE3F2FD);
}
