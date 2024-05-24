import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'test_mju1.dart'; // 공지사항 화면 파일을 import 해야 합니다.

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로그인 상태 확인 중에 로딩 표시
        }

        if (snapshot.hasData && snapshot.data != null) {
          // 이미 로그인된 사용자가 있는 경우 메인 화면으로 이동
          return MyApp();
        }

        // 익명 로그인 버튼 표시
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이미지 추가
                Image.asset(
                  'images/로고.png',
                  width: 500, // 이미지의 가로 너비 조정
                  height: 600, // 이미지의 세로 높이 조정
                ),
                SizedBox(height: 20), // 이미지와 버튼 사이 간격 조정
                // 익명 로그인 버튼 추가
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // 익명 로그인
                      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
                      // 로그인이 성공했을 때 처리
                      print('Signed in anonymously: ${userCredential.user!.uid}');
                      String userId = userCredential.user!.uid;

                      // Firestore에 데이터 저장
                      await FirebaseFirestore.instance.collection('users').doc(userId).set({
                        'created_at': DateTime.now(),
                        'userID': userId,
                        // 다른 사용자 정보 추가 가능
                      });

                      // 로그인이 성공했을 때 처리
                      print('Signed in anonymously: $userId');

                      // 공지사항 화면으로 이동
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ));
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case "operation-not-allowed":
                          print("Anonymous auth hasn't been enabled for this project.");
                          break;
                        default:
                          print("Unknown error.");
                      }
                    }
                  },
                  child: Text('공지사항 보러 가기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}