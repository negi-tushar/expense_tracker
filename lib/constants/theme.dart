// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color _offWhite = Color(0xFFF7F7F7);
  static const Color _white = Colors.white;

  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: _offWhite,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        primary: Colors.black,
        onPrimary: _white,
        background: _offWhite,
        surface: _white,
      ),

      // ADDED: Explicitly themeing dialogs, bottom sheets, and drawers

      // 1. Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 2. Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // 3. Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: _white,
      ),
      cardTheme: CardThemeData(
        color: _white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: _white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.black54),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: _white,
          extendedTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: Colors.black, textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600))));
}
