import 'package:flutter/material.dart';

class AnnouncementListScreen extends StatelessWidget {
  final List<String> announcements;

  AnnouncementListScreen({required this.announcements});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항'),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(announcements[index]),
          );
        },
      ),
    );
  }
}
