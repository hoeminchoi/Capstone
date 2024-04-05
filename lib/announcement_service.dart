import 'dart:async';
import 'api.dart';
import 'announcement_parser.dart';

void startFetchingAnnouncements() {
  Timer.periodic(Duration(minutes: 30), (timer) {
    fetchAndDisplayAnnouncements();
  });
}

void fetchAndDisplayAnnouncements() async {
  try {
    String html = await fetchAnnouncements();
    List<String> parsedAnnouncements = parseAnnouncements(html);
    // parsedAnnouncements를 표시할 화면으로 전달하여 업데이트합니다.
    // 예를 들어, AnnouncementListScreen의 setState 메서드를 호출하여 UI를 갱신합니다.
  } catch (e) {
    print('Failed to fetch announcements: $e');
  }
}
