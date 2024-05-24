import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bringData.dart';
import 'test_bringData.dart';  // bringData.dart를 import

class NoticeBoard extends StatefulWidget {
  @override
  _NoticeBoardState createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  late List<Map<String, String>> notices = [];
  late String currentCategory;
  late Map<String, String> categoryUrls;
  late Map<String, String> dormCategoryUrls;
  TextEditingController searchController = TextEditingController();
  Map<String, List<Map<String, String>>> allFetchedData = {};

  @override
  void initState() {
    super.initState();
    currentCategory = '일반 공지';
    categoryUrls = {
      '일반 공지': 'notices_일반공지',
      '행사 공지': 'notices_행사공지',
      '학사 공지': 'notices_학사공지',
      '장학/학자금 공지': 'notices_장학학자금공지',
      '진로/취업/창업 공지': 'notices_진로취업창업공지',
      '학생활동 공지': 'notices_학생활동공지',
      '입찰 공지': 'notices_입찰공지',
      '대학 안전 공지': 'notices_대학안전공지',
      '학칙개정 사전 공고': 'notices_학칙개정사전공고',
    };
    dormCategoryUrls = {
      '기숙사공지': 'dormNotices_기숙사공지',
      '입퇴사공지': 'dormNotices_입퇴사공지',
    };
    // Firebase에서 데이터를 가져옵니다.
    fetchData();
  }

  Future<void> fetchData() async {
    allFetchedData = await bringData();
    setState(() {
      notices = allFetchedData[categoryUrls[currentCategory]] ?? [];
    });
  }

  void selectCategory(String category) {
    setState(() {
      currentCategory = category;
      notices = allFetchedData[categoryUrls[currentCategory]!] ?? [];
    });
  }

  void dormSelectCategory(String category) {
    setState(() {
      currentCategory = category;
      notices = allFetchedData[dormCategoryUrls[currentCategory]!] ?? [];
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
                for (String category in dormCategoryUrls.keys)
                  ListTile(
                    title: Text(category),
                    onTap: () {
                      dormSelectCategory(category);
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
                    String yLibraryUrl = 'https://lib.mju.ac.kr/guide/bulletin/notice?max=10&offset=0&bulletinCategoryId=15';
                    launchUrl(yLibraryUrl);
                    Navigator.pop(context); // Drawer를 닫습니다.
                  },
                ),
                ListTile(
                  title: Text('인문'),
                  onTap: () {
                    // 도서관 홈페이지 URL
                    String sLibraryUrl = 'https://lib.mju.ac.kr/guide/bulletin/notice?max=10&offset=0&bulletinCategoryId=14';
                    launchUrl(sLibraryUrl);
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
      ),
    );
  }
}