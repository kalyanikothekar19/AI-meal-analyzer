import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/meal_result.dart';
import '../../core/constants.dart';

class ClaudeService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';

  /// Takes an image file, sends it to Claude Vision, returns parsed MealResult
  Future<MealResult> analyzeMeal(File imageFile) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Build the prompt — structured so Claude returns clean JSON
    const prompt = '''
Analyze this food image and respond ONLY with a valid JSON object.
No extra text, no markdown, just raw JSON.

Format:
{
  "meal_name": "string",
  "calories": integer,
  "protein_g": float,
  "carbs_g": float,
  "fat_g": float,
  "health_tip": "one helpful sentence"
}

Be accurate with estimates. If multiple foods, sum the totals.
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': AppConstants.claudeApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-opus-4-5',
        'max_tokens': 500,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': prompt,
              }
            ],
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode} — ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final rawText = decoded['content'][0]['text'] as String;

    // Parse the JSON Claude returned
    final nutritionJson = jsonDecode(rawText) as Map<String, dynamic>;
    return MealResult.fromJson(nutritionJson, imageFile.path);
  }
}