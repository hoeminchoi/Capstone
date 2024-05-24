import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, String>>> getNoticesFromFirestore(FirebaseFirestore firestore, String collectionName) async {
  List<Map<String, String>> fetchedData = [];

  QuerySnapshot querySnapshot = await firestore.collection(collectionName).get();

  querySnapshot.docs.forEach((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, String> notice2 = {
      'category': data['category'] ?? 'Unknown',
      'title': data['title'] ?? 'No Title',
      'date': data['date'] ?? 'No Date',
      'url': data['url'] ?? 'No URL',
    };
    fetchedData.add(notice2);
  });

  return fetchedData;
}

Future<Map<String, List<Map<String, String>>>> bringData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, List<Map<String, String>>> allFetchedData = {};

  try {
    allFetchedData['notices_일반_공지'] = await getNoticesFromFirestore(firestore, 'notices_일반 공지');
    allFetchedData['notices_행사_공지'] = await getNoticesFromFirestore(firestore, 'notices_행사 공지');
    allFetchedData['notices_학사_공지'] = await getNoticesFromFirestore(firestore, 'notices_학사 공지');
    allFetchedData['notices_장학_학자금_공지'] = await getNoticesFromFirestore(firestore, 'notices_장학 학자금 공지');
    allFetchedData['notices_진로_취업_창업_공지'] = await getNoticesFromFirestore(firestore, 'notices_진로 취업 창업 공지');
    allFetchedData['notices_학생활동_공지'] = await getNoticesFromFirestore(firestore, 'notices_학생활동 공지');
    allFetchedData['notices_입찰_공지'] = await getNoticesFromFirestore(firestore, 'notices_입찰 공지');
    allFetchedData['notices_대학_안전_공지'] = await getNoticesFromFirestore(firestore, 'notices_대학 안전 공지');
    allFetchedData['notices_학칙개정_사전_공고'] = await getNoticesFromFirestore(firestore, 'notices_학칙개정 사전 공고');
    allFetchedData['dormNotices_기숙사_공지'] = await getNoticesFromFirestore(firestore, 'dormNotices_기숙사공지');
    allFetchedData['dormNotices_입퇴사_공지'] = await getNoticesFromFirestore(firestore, 'dormNotices_입퇴사공지');

    // 데이터 확인을 위해 print 문 추가
    allFetchedData.forEach((key, value) {
      print("Category: $key");
      value.forEach((notice) {
        print("Notice: $notice");
      });
    });

  } catch (e) {
    print("Error bringing data: $e");
  }

  return allFetchedData;
}