// api.dart
import 'package:http/http.dart' as http;

Future<String> fetchAnnouncements() async {
  final Uri url = Uri.parse('https://www.mju.ac.kr/mjukr/255/subview.do');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load announcements');
  }
}


