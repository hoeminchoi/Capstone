import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notice Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoticeBoard(),
    );
  }
}

class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  final String baseUrl = "https://www.mju.ac.kr";
  final int startPage = 1;
  final int endPage = 10;
  List<Map<String, String>> notices = [];

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    for (int page = startPage; page <= endPage; page++) {
      String url = "$baseUrl/mjukr/255/subview.do?page=$page";
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);
        List<dom.Element> linkElements =
        document.querySelectorAll('a[href^="/bbs/mjukr/"]');
        for (var link in linkElements) {
          String? href = link.attributes['href'];
          if (href != null) {
            String noticeTitle = link.text.trim();
            String noticeUrl = baseUrl + href;
            setState(() {
              notices.add({'title': noticeTitle, 'url': noticeUrl});
            });
          }
        }
      }
    }
  }

  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Board'),
      ),
      body: ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          String title = notices[index]['title']!;
          String url = notices[index]['url']!;
          return ListTile(
            title: Text(title),
            onTap: () => launchUrl(url),
          );
        },
      ),
    );
  }
}
