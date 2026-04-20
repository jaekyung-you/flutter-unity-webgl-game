import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const KalToeWangApp());
}

class KalToeWangApp extends StatelessWidget {
  const KalToeWangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '칼퇴왕',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFCC00)),
        scaffoldBackgroundColor: const Color(0xFF0A0A1E),
      ),
      home: const SplashScreen(),
    );
  }
}
