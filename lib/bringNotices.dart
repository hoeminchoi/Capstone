import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> bringNoticesFromFirestore(String collectionName) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore.collection(collectionName)
    .orderBy('timestamp', descending: true) // timestamp 필드를 기준으로 내림차순으로 정렬
    .get();

  List<Map<String, dynamic>> notices = [];

  querySnapshot.docs.forEach((doc) {
    Map<String, dynamic> noticeData = {
      'category': doc['category'],
      'title': doc['title'],
      'date': doc['date'],
      'url': doc['url'],
      'timestamp': (doc['timestamp'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    };
    notices.add(noticeData);
  });

  return notices;
}