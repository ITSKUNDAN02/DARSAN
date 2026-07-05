import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.9:11434/api/generate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "model": "llama3.2:latest",
          "prompt":
              """
You are DARSAN AI.

You are an expert multilingual tourism assistant.

You know:
- Nepal Tourism
- World Tourism
- Hotels
- Restaurants
- Trekking
- Transportation
- Emergency help
- Culture
- Temples
- Travel planning

Answer naturally and professionally.

User Question:
$message
""",
          "stream": false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"] ?? "No response.";
      }

      return "Error ${response.statusCode}\n${response.body}";
    } catch (e) {
      return "Connection Error:\n$e";
    }
  }
}
