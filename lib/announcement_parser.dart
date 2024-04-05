import 'package:html/parser.dart' as htmlParser;

List<String> parseAnnouncements(String html) {
  final document = htmlParser.parse(html);
  List<String> announcements = [];
  // 공지사항을 추출하는 로직을 구현하세요.
  // document를 파싱하여 공지사항을 추출하고 announcements 리스트에 추가합니다.
  return announcements;
}
