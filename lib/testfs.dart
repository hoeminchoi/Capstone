import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩이 초기화되었는지 확인합니다.
  await Firebase.initializeApp(); // Firebase 초기화를 기다립니다.
  runApp(MyApp()); // 앱을 실행합니다.
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  int count =0;
  CollectionReference votes= FirebaseFirestore.instance.collection('votes');

  @override
  Widget build(BuildContext context) {
    DocumentReference vote = votes.doc('vote');
    return MaterialApp(
        home:Scaffold(
            body: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Count: $count'),
                  ElevatedButton(
                    onPressed: () {
                      vote.set({'value':FieldValue.increment(1)});
                    },
                    child: Text('CONTAINED BUTTON'),
                  )
                ],
              )
          )
        ));
  }
}