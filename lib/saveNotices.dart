import 'package:cloud_firestore/cloud_firestore.dart';
import 'fetchNotices.dart'; // 학교 공지사항을 가져오는 함수
import 'dorm_fetchNotices.dart'; // 기숙사 공지사항을 가져오는 함수

Map<String, String> categoryUrls = {
  '일반공지': 'https://www.mju.ac.kr/mjukr/255/subview.do',
  '행사공지': 'https://www.mju.ac.kr/mjukr/256/subview.do',
  '학사공지': 'https://www.mju.ac.kr/mjukr/257/subview.do',
  '장학학자금공지': 'https://www.mju.ac.kr/mjukr/259/subview.do',
  '진로취업창업공지': 'https://www.mju.ac.kr/mjukr/260/subview.do',
  '학생활동공지': 'https://www.mju.ac.kr/mjukr/5364/subview.do',
  '입찰공지': 'https://www.mju.ac.kr/mjukr/261/subview.do',
  '대학안전공지': 'https://www.mju.ac.kr/mjukr/8972/subview.do',
  '학칙개정사전공고': 'https://www.mju.ac.kr/mjukr/4450/subview.do',
};

Map<String, String> dormCategoryUrls = {
  '기숙사공지': 'https://dorm.mju.ac.kr/dorm/6729/subview.do',
  '입퇴사공지': 'https://dorm.mju.ac.kr/dorm/7792/subview.do',
};

Future<void> saveNoticesToFirestore(List<Map<String, String>> notices, String collectionName) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (var notice in notices) {
    await firestore.collection(collectionName).add({
      'category': notice['category'] ?? 'Unknown',
      'title': notice['title'] ?? 'No Title',
      'date': notice['date'] ?? 'No Date',
      'url': notice['url'] ?? 'No URL',
    });
  }
}

void testNoticesMain() async {
  for (var entry in categoryUrls.entries) {
    String categoryName = entry.key;
    String url = entry.value;
    // fetchNotices 함수를 호출하여 공지사항 데이터를 가져옴
    List<Map<String, String>> notices = await fetchNotices(url, 1, 1);
    // Firestore에 notices 저장
    await saveNoticesToFirestore(notices, 'notices_$categoryName');
  }

  // dorm_fetchNotices 함수를 호출하여 기숙사 공지사항 데이터를 가져옴
  for (var entry in dormCategoryUrls.entries) {
    String categoryName = entry.key;
    String url = entry.value;
    // dorm_fetchNotices 함수를 호출하여 기숙사 공지사항 데이터를 가져옴
    List<Map<String, String>> dormNotices = await dormFetchNotices(url, 1, 1);
    // Firestore에 dormNotices 저장
    await saveNoticesToFirestore(dormNotices, 'dormNotices_$categoryName');
  }
}