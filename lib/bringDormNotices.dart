import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> bringDormNoticesFromFirestore(String collectionName) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore.collection(collectionName)
      .orderBy('date', descending: true)
      .get();

  List<Map<String, dynamic>> dormNotices = [];

  querySnapshot.docs.forEach((doc) {
    Map<String, dynamic> dormNoticeData = {
      'category': doc['category'],
      'title': doc['title'],
      'date': doc['date'],
      'url': doc['url'],
    };
    dormNotices.add(dormNoticeData);
  });

  return dormNotices;
}