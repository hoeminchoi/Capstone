import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mju1.dart';
import 'saveNotices.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  testNoticesMain();
  runApp(MyApp());
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