import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return "";

    try {
      final url = Uri.parse(
        "https://api.mymemory.translated.net/get"
        "?q=${Uri.encodeComponent(text)}"
        "&langpair=$from|$to",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["responseData"]["translatedText"];
      }

      return "Translation failed (${response.statusCode})";
    } catch (e) {
      return e.toString();
    }
  }
}
