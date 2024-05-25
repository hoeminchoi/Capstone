import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bringNotices.dart'; // bringNotices.dart를 import
import 'keyword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  List<Map<String, dynamic>> notices=[];
  late String currentCategory;
  late Map<String, String> categoryUrls;
  late Map<String, String> dorm_categoryUrls;
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; // 로딩 상태를 추가합니다.
  List<Map<String, dynamic>>  bookmarks = []; // 즐겨찾기 목록
  late String userId; // 사용자의 UID를 저장할 변수 추가
  late Box<Map> bookmarkBox; // Hive Box 초기화


  @override
  void initState() {
    super.initState();
    currentCategory = '일반공지';
    categoryUrls = {
      '일반공지': 'notices_일반공지',
      '행사공지': 'notices_행사공지',
      '학사공지': 'notices_학사공지',
      '장학학자금공지': 'notices_장학학자금공지',
      '진로취업창업공지': 'notices_진로취업창업공지',
      '학생활동공지': 'notices_학생활동공지',
      '입찰공지': 'notices_입찰공지',
      '대학안전공지': 'notices_대학안전공지',
      '학칙개정 사전공고': 'notices_학칙개정사전공고',
    };
    dorm_categoryUrls = {
      '기숙사공지': 'dormNotices_기숙사공지',
      '입퇴사공지': 'dormNotices_입퇴사공지',
    };
    _initializeHive(); // Hive 초기화
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchData(); // 데이터를 가져옵니다.

  }
  Future<void> _initializeHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    // 'bookmarkBox'라는 이름의 Hive Box를 열고 초기화합니다.
    bookmarkBox = await Hive.openBox<Map>('bookmarkBox');
  }

  Future<void> fetchData() async {
    // bringNotices.dart나 bringDormNotices.dart에서 데이터를 가져옵니다.
    notices = await bringNoticesFromFirestore(categoryUrls[currentCategory]!);
    setState(() {
      isLoading = false; // 데이터를 가져왔으므로 로딩 상태를 false로 설정합니다.
    });
  }

  Future<void> dormfetchData() async {
    // bringNotices.dart나 bringDormNotices.dart에서 데이터를 가져옵니다.
    notices = await bringNoticesFromFirestore(dorm_categoryUrls[currentCategory]!);
    setState(() {
      isLoading = false; // 데이터를 가져왔으므로 로딩 상태를 false로 설정합니다.
    });
  }

  void selectCategory(String category) async {
    setState(() {
      currentCategory = category;
      fetchData(); // 선택한 카테고리에 맞게 데이터를 가져옵니다.
    });
  }

  void dormselectCategory(String category) async {
    setState(() {
      currentCategory = category;
      dormfetchData(); // 선택한 카테고리에 맞게 데이터를 가져옵니다.
    });
  }

  void searchNotices(String keyword) {
    List<Map<String, dynamic>> filteredNotices = [];
    for (var notice in notices) {
      if (notice['title'].toLowerCase().contains(keyword.toLowerCase())) {
        filteredNotices.add(notice);
      }
    }
    setState(() {
      notices = filteredNotices;
    });
  }
  void launchUrl(String url) async {
    // URL이 유효한지 확인합니다.
    if (Uri.tryParse(url) != null) {
      // 유효한 URL이면 실행합니다.
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // 유효하지 않은 URL인 경우 오류를 처리합니다.
      print('Invalid URL: $url');
    }
  }
  void toggleBookmark(String url, String title, String date) async {
    final bookmarkData = {
      'title': title,
      'date': date,
      'url': url,
    };

    // Hive에 즐겨찾기 정보 저장
    if (isBookmarked(url)) {
      // 즐겨찾기에서 제거
      bookmarkBox.delete(url);
    } else {
      // 즐겨찾기에 추가
      bookmarkBox.put(url, bookmarkData);
    }

    // UI 갱신
    setState(() {
      // Hive에서 모든 즐겨찾기 정보를 가져와서 'bookmarks' 변수에 할당
      bookmarks = bookmarkBox.values.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  bool isBookmarked(String url) {
    // 해당 URL이 이미 즐겨찾기되어 있는지 확인
    return bookmarkBox.containsKey(url);
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
                      dormselectCategory(category);
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
                    String Y_libraryUrl = 'https://lib.mju.ac.kr/guide/bulletin/notice?max=10&offset=0&bulletinCategoryId=15';
                    launchUrl(Y_libraryUrl);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('인문'),
                  onTap: () {
                    String S_libraryUrl = 'https://lib.mju.ac.kr/guide/bulletin/notice?max=10&offset=0&bulletinCategoryId=14';
                    launchUrl(S_libraryUrl);
                    Navigator.pop(context);
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
          Color? bgColor = index.isEven ? Colors.grey[200] : Colors.white;

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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked(url) ? Icons.star : Icons.star_border,
                          color: Colors.yellow[800],
                        ),
                        onPressed: () {
                          toggleBookmark(url, title, date);
                        },
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
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '즐겨찾기',
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
        currentIndex: 0,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.black54,
        unselectedLabelStyle: TextStyle(color: Colors.grey[700]),
        showUnselectedLabels: true,
        onTap: (index) {
          switch (index) {
            case 0:
              selectCategory('일반공지');
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarkScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KeywordPage(userId: userId,)),
              );
              break;
            case 3:
            // 설정 화면으로 이동하는 코드를 여기에 추가할 수 있습니다.
              break;
          }
        },
      ),
    );
  }
}

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Box<Map> bookmarkBox; // Hive Box 초기화

  @override
  void initState() {
    super.initState();
    _openBox(); // Hive Box 열기
  }

  Future<void> _openBox() async {
    // 이미 열려 있는 경우 다시 열지 않습니다.
    if (!Hive.isBoxOpen('bookmarkBox')) {
      // 새로운 인스턴스로 열기
      bookmarkBox = await Hive.openBox<Map>('bookmarkBox');
    } else {
      // 이미 열려 있는 경우 이미 있는 인스턴스 사용
      bookmarkBox = Hive.box<Map>('bookmarkBox');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기'),
      ),
      body: ListView.builder(
        itemCount: bookmarkBox.length,
        itemBuilder: (context, index) {
          final key = bookmarkBox.keyAt(index);
          final bookmarkInfo = bookmarkBox.get(key)!;
          final title = bookmarkInfo['title']!;
          final date = bookmarkInfo['date']!;
          final url = bookmarkInfo['url']!;
          return ListTile(
            title: Text(title),
            subtitle: Text(date),
            onTap: () {
              launchUrl(Uri.parse(url));
            },
          );
        },
      ),
    );
  }
}

