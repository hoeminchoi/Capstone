import 'package:cloud_firestore/cloud_firestore.dart';
import 'fetchNotes.dart';
import 'dorm_fetchNotices.dart';

Map<String, String> categoryUrls = {
  '일반 공지': 'https://www.mju.ac.kr/mjukr/255/subview.do',
  '행사 공지': 'https://www.mju.ac.kr/mjukr/256/subview.do',
  '학사 공지': 'https://www.mju.ac.kr/mjukr/257/subview.do',
  '장학학자금 공지': 'https://www.mju.ac.kr/mjukr/259/subview.do',
  '진로취업창업 공지': 'https://www.mju.ac.kr/mjukr/260/subview.do',
  '학생활동 공지': 'https://www.mju.ac.kr/mjukr/5364/subview.do',
  '입찰 공지': 'https://www.mju.ac.kr/mjukr/261/subview.do',
  '대학 안전 공지': 'https://www.mju.ac.kr/mjukr/8972/subview.do',
  '학칙개정 사전 공고': 'https://www.mju.ac.kr/mjukr/4450/subview.do',
};

Map<String, String> dormCategoryUrls = {
  '기숙사공지': 'https://dorm.mju.ac.kr/dorm/6729/subview.do',
  '입퇴사공지': 'https://dorm.mju.ac.kr/dorm/7792/subview.do',
};

Future<void> saveNoticesToFirestore(List<Map<String, String>> notices, String collectionName) async {
  // Firestore 초기화
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 데이터 저장
  for (var notice in notices) {
    await firestore.collection(collectionName).add(notice);
  }
}

void testNoticesMain() async {
  for (var entry in categoryUrls.entries) {
    String categoryName = entry.key;
    String url = entry.value;
    // fetchNotices 함수를 호출하여 공지사항 데이터를 가져옴
    List<Map<String, String>> notices = await fetchNotices(url, 1, 1);
    // Firestore에 notices 저장
    await saveNoticesToFirestore(notices, categoryName);
  }
  // dorm_fetchNotices 함수를 호출하여 기숙사 공지사항 데이터를 가져옴
  for (var entry in dormCategoryUrls.entries) {
    String categoryName = entry.key;
    String url = entry.value;

    // dorm_fetchNotices 함수를 호출하여 기숙사 공지사항 데이터를 가져옴
    List<Map<String, String>> dormNotices = await dormFetchNotices(url, 1, 1);
    // Firestore에 dormNotices 저장
    await saveNoticesToFirestore(dormNotices, categoryName);
  }
}