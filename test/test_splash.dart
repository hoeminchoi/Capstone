import 'package:flutter/material.dart';
import 'main.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLogin = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: _isLogin ? MyApp() : Login()));
  }
}