import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bringData.dart';  // bringData.dart를 import

class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  late List<Map<String, String>> notices;
  late String currentCategory;
  late Map<String, String> categoryUrls;
  late Map<String, String> dorm_categoryUrls;
  TextEditingController searchController = TextEditingController();
  Map<String, List<Map<String, String>>> allFetchedData = {};
  bool isLoading = true;  // 로딩 상태를 추가합니다.

  @override
  void initState() {
    super.initState();
    currentCategory = '일반 공지';
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
    fetchData();  // 데이터를 가져옵니다.
  }

  Future<void> fetchData() async {
    allFetchedData = await bringData();
    setState(() {
      notices = allFetchedData['notices_일반공지'] ?? [];
      isLoading = false;  // 데이터를 가져왔으므로 로딩 상태를 false로 설정합니다.
    });
  }

  void selectCategory(String category) {
    setState(() {
      currentCategory = category;
      notices = allFetchedData[categoryUrls[currentCategory]!] ?? [];
    });
  }

  void dorm_selectCategory(String category) {
    setState(() {
      currentCategory = category;
      notices = allFetchedData[dorm_categoryUrls[currentCategory]!] ?? [];
    });
  }

  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
      body: isLoading  // 로딩 중일 때 로딩 표시를 추가합니다.
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중이면 로딩 표시
          : notices.isNotEmpty
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
          : Center(child: Text('공지사항이 없습니다.')),  // 공지사항이 없을 때 표시할 내용
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
              selectCategory('일반공지');
              break;
            case 1:
              break;
            case 2:
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