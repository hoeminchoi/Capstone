import 'package:flutter/material.dart';
import 'testNotices.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩이 초기화되었는지 확인합니다.
  await Firebase.initializeApp();
  testNoticesMain();
  runApp(MyApp()); // MyApp 위젯을 실행하여 앱을 시작
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notice Board'),
        ),
        body: const Center(
          child: Text(
            '테스트 중...',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}