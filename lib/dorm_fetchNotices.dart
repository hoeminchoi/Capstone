import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

Future<List<Map<String, String>>> dormFetchNotices(String baseUrl, int startPage, int endPage) async {
  List<Map<String, String>> dormNotices = [];
  List<String> existingTitles = [];
  String dorm_baseUrl2 = "https://dorm.mju.ac.kr";

  for (int page = startPage; page <= endPage; page++) {
    String url = "$baseUrl?page=$page";
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
          String noticeType = document.querySelector('#sideB > h1')?.text.trim() ?? 'Unknown';
          String noticeTitle = link.text.trim();
          noticeTitle = noticeTitle.replaceAll('새글', '');
          String noticeDate = dateElements[i].text.trim();

          if (!existingTitles.contains(noticeTitle)) {
            dormNotices.add({
              'category':noticeType,
              'title': noticeTitle,
              'date': noticeDate,
              'url': "$dorm_baseUrl2$href"
            });
            existingTitles.add(noticeTitle);
          }
        }
      }
    }
  }
  return dormNotices;
}