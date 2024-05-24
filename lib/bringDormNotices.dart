import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> bringDormNoticesFromFirestore(String collectionName) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore.collection(collectionName)
    .orderBy('timestamp', descending: true) // timestamp 필드를 기준으로 내림차순으로 정렬
    .get();

  List<Map<String, dynamic>> dormNotices = [];

  querySnapshot.docs.forEach((doc) {
    Map<String, dynamic> dormNoticeData = {
      'category': doc['category'],
      'title': doc['title'],
      'date': doc['date'],
      'url': doc['url'],
      'timestamp': (doc['timestamp'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    };
    dormNotices.add(dormNoticeData);
  });
  
  return dormNotices;
}