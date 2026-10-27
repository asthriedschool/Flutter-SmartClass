import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF12305B);
    const primary = Color(0xFF0866F5);
    const background = Color(0xFF050607);
    const card = Color(0xFF242628);

    return MaterialApp(
      title: 'Smart Class',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: card,
          onSurface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Color(0xFFFFFFFF),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
