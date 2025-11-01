import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Information
final String appName = "Myanmar Dictionary";
final String appVersion = "1.0.0";

// Primary brand colors - Optimized for reading comfort
final primaryLightColor = const Color(
  0xFF1A73E8,
); // Google Blue - better contrast
final primaryDarkColor = const Color(
  0xFF8AB4F8,
); // Light blue that works on dark
final accentColor = const Color(
  0xFF34A853,
); // Green accent for positive actions

// Secondary colors for dictionary-specific elements
final secondaryLightColor = const Color(0xFF5F6368); // Gray for secondary text
final secondaryDarkColor = const Color(0xFF9AA0A6); // Light gray for dark mode

// Background colors optimized for long reading sessions
final backgroundLightColor = const Color(
  0xFFF8F9FA,
); // Softer white for eye comfort
final backgroundDarkColor = const Color(
  0xFF202124,
); // Dark gray for reduced eye strain

// Surface colors (cards, sheets, etc.)
final surfaceLightColor = Colors.white;
final surfaceDarkColor = const Color(
  0xFF292A2D,
); // Slightly lighter than background

// Text colors optimized for readability
final textLightColor = const Color(
  0xFF202124,
); // Almost black for better contrast
final textLightSecondary = const Color(0xFF5F6368); // Secondary text
final textDarkColor = const Color(0xFFE8EAED); // Light gray for dark mode
final textDarkSecondary = const Color(0xFF9AA0A6); // Secondary dark text

// Semantic colors for dictionary content
final partOfSpeechNounColor = const Color(0xFF4285F4); // Blue for nouns
final partOfSpeechVerbColor = const Color(0xFFEA4335); // Red for verbs
final partOfSpeechAdjectiveColor = const Color(
  0xFFFBBC04,
); // Yellow for adjectives
final partOfSpeechAdverbColor = const Color(0xFF34A853); // Green for adverbs
final partOfSpeechOtherColor = const Color(0xFF8A2BE2); // Purple for other POS

// Success, warning, error colors
final successColor = const Color(0xFF34A853); // Google Green
final warningColor = const Color(0xFFFBBC04); // Google Yellow
final errorColor = const Color(0xFFEA4335); // Google Red

// Border and divider colors
final borderLightColor = const Color(0xFFDADCE0); // Light gray border
final borderDarkColor = const Color(0xFF3C4043); // Dark gray border

// Dictionary-specific text styles
class DictionaryTextStyles {
  static TextStyle wordTitleLight = GoogleFonts.merriweather(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textLightColor,
    height: 1.2,
  );

  static TextStyle wordTitleDark = GoogleFonts.merriweather(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textDarkColor,
    height: 1.2,
  );

  static TextStyle definitionLight = GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textLightColor,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle definitionDark = GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textDarkColor,
    height: 1.6,
    letterSpacing: 0.2,
  );

  static TextStyle phoneticLight = GoogleFonts.notoSans(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: textLightSecondary,
    height: 1.4,
  );

  static TextStyle phoneticDark = GoogleFonts.notoSans(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: textDarkSecondary,
    height: 1.4,
  );

  static TextStyle partOfSpeechLight = GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle partOfSpeechDark = GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: 0.5,
  );
}

// Theme configurations
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryLightColor,
  scaffoldBackgroundColor: backgroundLightColor,
  cardColor: surfaceLightColor,
  dividerColor: borderLightColor,
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceLightColor,
    foregroundColor: textLightColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  colorScheme: ColorScheme.light(
    primary: primaryLightColor,
    secondary: accentColor,
    background: backgroundLightColor,
    surface: surfaceLightColor,
    onSurface: textLightColor,
    onBackground: textLightColor,
    error: errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.merriweather(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textLightColor,
    ),
    displayMedium: GoogleFonts.merriweather(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textLightColor,
    ),
    titleLarge: GoogleFonts.notoSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textLightColor,
    ),
    titleMedium: GoogleFonts.notoSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textLightColor,
    ),
    bodyLarge: GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textLightColor,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textLightColor,
    ),
    bodySmall: GoogleFonts.notoSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textLightSecondary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: surfaceLightColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderLightColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderLightColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryLightColor, width: 2),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: surfaceLightColor,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryDarkColor,
  scaffoldBackgroundColor: backgroundDarkColor,
  cardColor: surfaceDarkColor,
  dividerColor: borderDarkColor,
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceDarkColor,
    foregroundColor: textDarkColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  colorScheme: ColorScheme.dark(
    primary: primaryDarkColor,
    secondary: accentColor,
    background: backgroundDarkColor,
    surface: surfaceDarkColor,
    onSurface: textDarkColor,
    onBackground: textDarkColor,
    error: errorColor,
    onPrimary: Colors.black87,
    onSecondary: Colors.black87,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.merriweather(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textDarkColor,
    ),
    displayMedium: GoogleFonts.merriweather(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textDarkColor,
    ),
    titleLarge: GoogleFonts.notoSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textDarkColor,
    ),
    titleMedium: GoogleFonts.notoSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textDarkColor,
    ),
    bodyLarge: GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textDarkColor,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textDarkColor,
    ),
    bodySmall: GoogleFonts.notoSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textDarkSecondary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: surfaceDarkColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderDarkColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderDarkColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryDarkColor, width: 2),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: surfaceDarkColor,
  ),
);

// Helper function to get part of speech color
Color getPartOfSpeechColor(String partOfSpeech, bool isDarkMode) {
  final pos = partOfSpeech.toLowerCase();

  if (pos.contains('noun')) return partOfSpeechNounColor;
  if (pos.contains('verb')) return partOfSpeechVerbColor;
  if (pos.contains('adjective') || pos.contains('adj.'))
    return partOfSpeechAdjectiveColor;
  if (pos.contains('adverb') || pos.contains('adv.'))
    return partOfSpeechAdverbColor;

  return partOfSpeechOtherColor;
}

// Helper function to get contrasting text color for part of speech badges
Color getPartOfSpeechTextColor(Color backgroundColor) {
  // Calculate the luminance of the background color
  final luminance = backgroundColor.computeLuminance();
  // Use white text for dark backgrounds, black for light backgrounds
  return luminance > 0.5 ? Colors.black87 : Colors.white;
}
