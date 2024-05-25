import 'package:flutter/material.dart';
import 'package:newcap/firebase_options.dart';
import 'package:newcap/splash.dart';
import 'mju2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'saveNotices.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩이 초기화되었는지 확인합니다.
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  testNoticesMain();
  runApp(const SplashScreen()); // MyApp 위젯을 실행하여 앱을 시작
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notice Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoticeBoard(),
    );
  }
}