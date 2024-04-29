import 'package:flutter/material.dart';
import 'mju.dart';


void main() {
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
