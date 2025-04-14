import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isDyslexiaMode = false;
  
  ThemeProvider() {
    _loadFromPrefs();
  }
  
  bool get isDarkMode => _isDarkMode;
  bool get isDyslexiaMode => _isDyslexiaMode;
  
  // Carregar preferências salvas
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _isDyslexiaMode = prefs.getBool('dyslexia_mode') ?? false;
    notifyListeners();
  }
  
  // Salvar preferências
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_mode', _isDarkMode);
    prefs.setBool('dyslexia_mode', _isDyslexiaMode);
  }
  
  // Alternar tema escuro
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }
  
  // Alternar modo dislexia
  void toggleDyslexiaMode() {
    _isDyslexiaMode = !_isDyslexiaMode;
    _saveToPrefs();
    notifyListeners();
  }
  
  // Obter a fonte atual baseada no modo de dislexia
  TextTheme get textTheme {
    if (_isDyslexiaMode) {
      return const TextTheme(
        displayLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        displayMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        displaySmall: TextStyle(fontFamily: 'OpenDyslexic'),
        headlineLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        headlineMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        headlineSmall: TextStyle(fontFamily: 'OpenDyslexic'),
        titleLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        titleMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        titleSmall: TextStyle(fontFamily: 'OpenDyslexic'),
        bodyLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        bodyMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        bodySmall: TextStyle(fontFamily: 'OpenDyslexic'),
        labelLarge: TextStyle(fontFamily: 'OpenDyslexic'),
        labelMedium: TextStyle(fontFamily: 'OpenDyslexic'),
        labelSmall: TextStyle(fontFamily: 'OpenDyslexic'),
      );
    }
    
    // Usar Google Fonts para o modo normal
    return GoogleFonts.nunitoTextTheme();
  }
  
  // Definir o tema principal baseado no modo escuro ou claro
  ThemeData get themeData {
    final baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    // Cor primária azul suave - #89CFF0
    final primaryColor = const Color(0xFF89CFF0);
    final primaryColorDark = const Color(0xFF5A9CBC);
    
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        primaryContainer: primaryColorDark,
        secondary: _isDarkMode ? const Color(0xFFA5D8E6) : const Color(0xFF5A9CBC),
        background: _isDarkMode ? const Color(0xFF121212) : Colors.white,
        surface: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        onSurface: _isDarkMode ? Colors.white : Colors.black87,
      ),
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      textTheme: textTheme,
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: _isDarkMode ? Colors.white60 : Colors.black45,
      ),
    );
  }
} 