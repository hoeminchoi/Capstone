import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KeywordPage extends StatefulWidget {
  final String userId;

  KeywordPage({required this.userId});

  @override
  _KeywordPageState createState() => _KeywordPageState();
}

class _KeywordPageState extends State<KeywordPage> {
  TextEditingController keywordController = TextEditingController();
  List<String> keywords = [];

  @override
  void initState() {
    super.initState();
    loadKeywords(); // 앱 시작 시 키워드 불러오기
  }

  Future<void> loadKeywords() async {
    var box = await Hive.openBox('keywords');
    setState(() {
      keywords = List<String>.from(box.get('userKeywords', defaultValue: []));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('키워드 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: keywordController,
              maxLines: null, // 여러 줄 입력 가능하도록 설정
              decoration: InputDecoration(
                labelText: '키워드 입력 (여러 개 가능)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  String input = keywordController.text.trim();
                  if (input.isNotEmpty) {
                    List<String> newKeywords = input.split(','); // 쉼표를 기준으로 키워드를 분리하여 리스트로 저장
                    keywords.addAll(newKeywords);
                    _saveKeywordsToLocalStorage(keywords); // 키워드를 로컬에 저장
                    _saveKeywordsToFirestore(keywords); // 키워드를 Firestore에 저장
                    keywordController.clear(); // 입력 필드 초기화
                  }
                });
              },
              child: Text('키워드 추가'),
            ),
            SizedBox(height: 20.0),
            Wrap(
              children: keywords
                  .map(
                    (keyword) => Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    setState(() {
                      keywords.remove(keyword);
                      _removeKeyword(keyword);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$keyword 키워드가 삭제되었습니다.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                            backgroundColor: Colors.indigo[100], // 배경색
                            duration: Duration(seconds: 2), // 표시 시간
                            behavior: SnackBarBehavior.floating, // 타원 모양으로 표시
                            margin: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 60.0), // 좌우 및 하단 여백 조정
                          )

                      );
                    });
                  },
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveKeywordsToFirestore(List<String> keywords) async {
    try {
      // Firestore에 키워드 목록을 저장합니다.
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'keywords': keywords,
      });
    } catch (e) {
      print('Error saving keywords: $e');
    }
  }

  Future<void> _removeKeyword(String keyword) async {
    try {
      // Firestore에서 해당 사용자의 키워드를 가져옵니다.
      var document = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (document.exists) {
        // 키워드 목록에서 제거합니다.
        List<String> updatedKeywords = List<String>.from(document.data()!['keywords']);
        updatedKeywords.remove(keyword);

        // Firestore에 업데이트된 키워드 목록을 저장합니다.
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'keywords': updatedKeywords,
        });

        setState(() {
          keywords.remove(keyword);
        });

        // 로컬 저장소에서도 키워드를 삭제합니다.
        await _saveKeywordsToLocalStorage(keywords);
      }
    } catch (e) {
      print('Error removing keyword: $e');
    }
  }

  Future<void> _saveKeywordsToLocalStorage(List<String> keywords) async {
    var box = await Hive.openBox('keywords');
    await box.put('userKeywords', keywords); // 새로운 키워드 저장
  }
}