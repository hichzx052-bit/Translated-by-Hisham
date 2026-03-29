import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'theme/admin_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const UpdateManagerApp());
}

class UpdateManagerApp extends StatelessWidget {
  const UpdateManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Manager',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
