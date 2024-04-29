import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

class DormitoryNoticeBoard extends StatefulWidget {
  final String category; // 카테고리 매개변수 추가

  // 생성자에서 카테고리를 받아옴
  DormitoryNoticeBoard({required this.category});

  @override
  _DormitoryNoticeBoardState createState() => _DormitoryNoticeBoardState();
}

class _DormitoryNoticeBoardState extends State<DormitoryNoticeBoard> {
  late List<Map<String, String>> notices;
  late String currentCategory;
  late Map<String, String> categoryUrls;
  late String baseUrl2;

  @override
  void initState() {
    super.initState();
    currentCategory = widget.category; // 위젯의 카테고리를 사용
    baseUrl2 = "https://dorm.mju.ac.kr/";
    categoryUrls = {
      '기숙사공지': 'https://dorm.mju.ac.kr/dorm/6729/subview.do',
      '입퇴사공지': 'https://dorm.mju.ac.kr/dorm/7792/subview.do',
    };
    fetchNotices(categoryUrls[currentCategory]!, 1, 10);
  }

  Future<void> fetchNotices(String baseUrl, int startPage, int endPage) async {
    notices = []; // Reset notices list before fetching new notices
    List<String> existingTitles = []; // Reset existingTitles list

    for (int page = startPage; page <= endPage; page++) {
      String url = "$baseUrl?page=$page";
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);
        document.querySelectorAll('.fnLeft').forEach((element) {
          element.remove();
        });
        List<dom.Element> linkElements =
        document.querySelectorAll('a[href^="/bbs/dorm/"][onclick^="jf_viewArtcl"]');
        List<dom.Element> dateElements =
        document.querySelectorAll('td._artclTdRdate');
        for (int i = 0; i < linkElements.length; i++) {
          var link = linkElements[i];
          String? href = link.attributes['href'];
          if (href != null) {
            String noticeTitle = link.text.trim();
            noticeTitle = noticeTitle.replaceAll('새글', '');

            String noticeDate = dateElements[i].text.trim();

            if (!existingTitles.contains(noticeTitle)) {
              setState(() {
                notices.add({
                  'title': noticeTitle,
                  'date': noticeDate,
                  'url': "$baseUrl2$href" // baseUrl2로 변경
                });
                existingTitles.add(noticeTitle);
              });
            }
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

  void selectCategory(String category) {
    setState(() {
      currentCategory = category;
      fetchNotices(categoryUrls[currentCategory]!, 1, 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Text(
            '명지사항 - $currentCategory',
            style: TextStyle(fontSize: 30),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: 35),
              onPressed: null,
            )
          ],
        ),
      ),



      body: notices != null
          ? ListView.separated(
        itemCount: notices.length,
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey[400],
            thickness: 1,
            height: 1,
          );
        },
        itemBuilder: (context, index) {
          String title = notices[index]['title']!;
          String date = notices[index]['date']!;
          String url = notices[index]['url']!;
          Color? bgColor =
          index.isEven ? Colors.grey[200] : Colors.white;

          bool isSpecialNotice = title.contains('일반공지');

          title = title.replaceAll(RegExp(r'\[[^\]]*일반공지[^\]]*\]'), '');

          return GestureDetector(
            onTap: () => launchUrl(url),
            child: Container(
              color: bgColor,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isSpecialNotice)
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                      SizedBox(width: 1),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(child: CircularProgressIndicator()), // 데이터 로딩 중이면 로딩 표시
    );
  }
}
