import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart'; // 타임스탬프 형식을 위해 추가

Future<List<Map<String, String>>> fetchNotices(String baseUrl, int startPage, int endPage) async {
  List<Map<String, String>> notices = [];
  List<String> existingTitles = [];
  String baseUrl2 = "https://www.mju.ac.kr";

  for (int page = startPage; page <= endPage; page++) {
    String url = "$baseUrl?page=$page";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      document.querySelectorAll('.fnLeft').forEach((element) { element.remove(); });
      List<dom.Element> linkElements = document.querySelectorAll('a[href^="/bbs/mjukr/"][onclick^="jf_viewArtcl"]');
      List<dom.Element> dateElements = document.querySelectorAll('td._artclTdRdate');
      for (int i = 0; i < linkElements.length; i++) {
        var link = linkElements[i];
        String? href = link.attributes['href'];
        if (href != null) {
          String? noticeType = document.querySelector('#contentWrap > div.h1Title')?.text.trim();
          String noticeTitle = link.text.trim();
          String noticeDate = dateElements[i].text.trim();

          // 일반공지 여부 확인 및 제목 수정
          bool isSpecialNotice = noticeTitle.contains('일반공지');
          noticeTitle = noticeTitle.replaceAll(RegExp(r'\[[^\]]*일반공지[^\]]*\]'), '');

          if (!existingTitles.contains(noticeTitle)) {
            // 현재 시간(타임스탬프) 추가
            String timestamp = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

            notices.add({
              'category': noticeType ?? '유형없음',
              'title': noticeTitle,
              'date': noticeDate,
              'url': "$baseUrl2$href",
            });
            existingTitles.add(noticeTitle);
          }
        }
      }
    }
  }
  return notices;
}
