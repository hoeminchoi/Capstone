import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  List<Map<String, String>> notices=[];
  late String currentCategory;
  late Map<String, String> categoryUrls;
  late Map<String, String> dorm_categoryUrls;
  late String baseUrl2;
  late String dorm_baseUrl2;
  TextEditingController searchController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    currentCategory = '일반 공지';
    baseUrl2 = "https://www.mju.ac.kr";
    dorm_baseUrl2 = "https://dorm.mju.ac.kr";
    categoryUrls = {
      '일반 공지': 'https://www.mju.ac.kr/mjukr/255/subview.do',
      '행사 공지': 'https://www.mju.ac.kr/mjukr/256/subview.do',
      '학사 공지': 'https://www.mju.ac.kr/mjukr/257/subview.do',
      '장학/학자금 공지': 'https://www.mju.ac.kr/mjukr/259/subview.do',
      '진로/취업/창업 공지': 'https://www.mju.ac.kr/mjukr/260/subview.do',
      '학생활동 공지': 'https://www.mju.ac.kr/mjukr/5364/subview.do',
      '입찰 공지': 'https://www.mju.ac.kr/mjukr/261/subview.do',
      '대학 안전 공지': 'https://www.mju.ac.kr/mjukr/8972/subview.do',
      '학칙개정 사전 공고': 'https://www.mju.ac.kr/mjukr/4450/subview.do',
    };
    dorm_categoryUrls = {
      '기숙사공지': 'https://dorm.mju.ac.kr/dorm/6729/subview.do',
      '입퇴사공지': 'https://dorm.mju.ac.kr/dorm/7792/subview.do',
    };
    fetchNotices(categoryUrls, 1, 5);
    dorm_fetchNotices(dorm_categoryUrls, 1, 5);
    //fetchNoticesFromFirestore(currentCategory);
  }

  Future<void> fetchNotices(Map<String, String> categoryUrls, int startPage, int endPage) async {
    try {
      List<String> existingTitles = []; // 중복 확인용 리스트
      List<Map<String, String>> noticeList = []; // 공지사항 리스트

      for (String category in categoryUrls.values) {
        for (int page = startPage; page <= endPage; page++) {
          String url = "${categoryUrls[category]}?page=$page";
          http.Response response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            dom.Document document = parser.parse(response.body);
            document.querySelectorAll('.fnLeft').forEach((element) {
              element.remove();
            });

            List<dom.Element> linkElements = document.querySelectorAll('a[href^="/bbs/mjukr/"][onclick^="jf_viewArtcl"]');
            List<dom.Element> dateElements = document.querySelectorAll('td._artclTdRdate');

            for (int i = 0; i < linkElements.length; i++) {
              var link = linkElements[i];
              String? href = link.attributes['href'];
              if (href != null) {
                String noticeTitle = link.text.trim().replaceAll('새글', '');
                String noticeDate = dateElements[i].text.trim();
                String noticeType = document.querySelector('#contentWrap > div.h1Title')?.text.trim() ?? '';

                // 중복 확인
                if (!existingTitles.contains(noticeTitle)) {
                  // Firestore에 추가할 데이터 생성
                  Map<String, String> noticeData = {
                    'type': noticeType,
                    'title': noticeTitle,
                    'date': noticeDate,
                    'url': "$baseUrl2$href",
                  };
                  noticeList.add(noticeData); // 리스트에 추가
                  existingTitles.add(noticeTitle); // 중복 확인용 리스트에 추가
                }
              }
            }
          }
        }
      }

      // 한 번에 Firestore에 추가
      await addNoticesToFirestore(noticeList);
    } catch (e) {
      print('Error fetching notices: $e');
    }
  }

// 공지사항 한 번에 Firestore에 추가
  Future<void> addNoticesToFirestore(List<Map<String, String>> notices) async {

    for (var notice in notices) {
      await firestore.collection('notices').add(notice);
    }
  }



  Future<void> dorm_fetchNotices(Map<String, String> categoryUrls, int startPage, int endPage) async {
    try {
      List<String> existingTitles = []; // 중복 확인용 리스트
      List<Map<String, String>> dormnoticeList = []; // 공지사항 리스트

      for (String category in categoryUrls.values) {
        for (int page = startPage; page <= endPage; page++) {
          String url = "${categoryUrls[category]}?page=$page";
          http.Response response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            dom.Document document = parser.parse(response.body);
            document.querySelectorAll('.fnLeft').forEach((element) {
              element.remove();
            });

            List<dom.Element> linkElements = document.querySelectorAll('a[href^="/bbs/dorm/"][onclick^="jf_viewArtcl"]');
            List<dom.Element> dateElements = document.querySelectorAll('td._artclTdRdate');

            for (int i = 0; i < linkElements.length; i++) {
              var link = linkElements[i];
              String? href = link.attributes['href'];
              if (href != null) {
                String noticeTitle = link.text.trim().replaceAll('새글', '');
                String noticeDate = dateElements[i].text.trim();
                String noticeType = document.querySelector('#contentWrap > div.h1Title')?.text.trim() ?? '';

                // 중복 확인
                if (!existingTitles.contains(noticeTitle)) {
                  // Firestore에 추가할 데이터 생성
                  Map<String, String> noticeData = {
                    'type': noticeType,
                    'title': noticeTitle,
                    'date': noticeDate,
                    'url': "$dorm_baseUrl2$href",
                  };
                  dormnoticeList.add(noticeData); // 리스트에 추가
                  existingTitles.add(noticeTitle); // 중복 확인용 리스트에 추가
                }
              }
            }
          }
        }
      }

      // 한 번에 Firestore에 추가
      await addNoticesToFirestore(dormnoticeList);
    } catch (e) {
      print('Error fetching notices: $e');
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
      fetchNoticesFromFirestore(category); // Firestore에서 해당 카테고리의 공지사항을 가져오도록 수정
    });
  }

  void dorm_selectCategory(String category) {
    setState(() {
      currentCategory = category;
      fetchNoticesFromFirestore(category); // Firestore에서 해당 카테고리의 공지사항을 가져오도록 수정
    });
  }

  Future<void> fetchNoticesFromFirestore(String category) async {
    try {
      // 해당 카테고리의 공지사항 가져오기
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notices')
          .where('category', isEqualTo: category)
          .get();

      List<Map<String, String>> fetchedNotices = [];

      querySnapshot.docs.forEach((doc) {
        Map<String, String> noticeData = {
          'title': doc['title'],
          'date': doc['date'],
          'url': doc['url'],
        };
        fetchedNotices.add(noticeData);
      });

      setState(() {
        notices = fetchedNotices;
      });
    } catch (e) {
      print('Error fetching notices from Firestore: $e');
    }
  }


  void searchNotices(String keyword) {
    List<Map<String, String>> filteredNotices = [];
    for (var notice in notices) {
      if (notice['title']!.toLowerCase().contains(keyword.toLowerCase())) {
        filteredNotices.add(notice);
      }
    }
    setState(() {
      notices = filteredNotices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          title: Text(
            '$currentCategory',
            style: TextStyle(fontSize: 30),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: 35),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('검색'),
                    content: TextField(
                      controller: searchController,
                      decoration: InputDecoration(hintText: '검색어 입력'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          searchNotices(searchController.text);
                          Navigator.pop(context);
                        },
                        child: Text('검색'),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Text(
                '명지사항',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text('학교 공지사항'),
              children: <Widget>[
                for (String category in categoryUrls.keys)
                  ListTile(
                    title: Text(category),
                    onTap: () {
                      selectCategory(category);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title: Text('기숙사 공지사항'),
              children: <Widget>[
                for (String category in dorm_categoryUrls.keys)
                  ListTile(
                    title: Text(category),
                    onTap: () {
                      dorm_selectCategory(category);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            ExpansionTile(
              title: Text('도서관'),
              children: <Widget>[
                ListTile(
                  title: Text('자연'),
                  onTap: () {
                    // 도서관 홈페이지 URL
                    String Y_libraryUrl = 'https://lib.mju.ac.kr/guide/bulletin/notice?max=10&offset=0&bulletinCategoryId=15';
                    launchUrl(Y_libraryUrl);
                    Navigator.pop(context); // Drawer를 닫습니다.
                  },
                ),
                ListTile(
                  title: Text('인문'),
                  onTap: () {
                    // 도서관 홈페이지 URL
                    String S_libraryUrl = 'https://lib.mju.ac.kr/guide/bulletin/notice?max=10&offset=0&bulletinCategoryId=14';
                    launchUrl(S_libraryUrl);
                    Navigator.pop(context); // Drawer를 닫습니다.
                  },
                ),
              ],
            ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '타임라인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '키워드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: 0, // 현재 선택된 아이템의 인덱스
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          // Handle item tap
          switch (index) {
            case 0:
            // Handle home button tap
              selectCategory('일반 공지');
              break;
            case 1:
              break;
            case 2:
            // Handle keyword button tap
            // Navigate to keyword screen
              break;
            case 3:
            // Handle settings button tap
            // Navigate to settings screen
              break;
          }
        },
      ),
    );
  }
}