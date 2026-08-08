// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import '../models/meal_result.dart';
// import '../../core/constants.dart';

// class ClaudeService {
//   static const _apiUrl = 'https://api.anthropic.com/v1/messages';

//   /// Takes an image file, sends it to Claude Vision, returns parsed MealResult
//   Future<MealResult> analyzeMeal(File imageFile) async {
//     // Convert image to base64
//     final bytes = await imageFile.readAsBytes();
//     final base64Image = base64Encode(bytes);

//     // Build the prompt — structured so Claude returns clean JSON
//     const prompt = '''
// Analyze this food image and respond ONLY with a valid JSON object.
// No extra text, no markdown, just raw JSON.

// Format:
// {
//   "meal_name": "string",
//   "calories": integer,
//   "protein_g": float,
//   "carbs_g": float,
//   "fat_g": float,
//   "health_tip": "one helpful sentence"
// }

// Be accurate with estimates. If multiple foods, sum the totals.
// ''';

//     final response = await http.post(
//       Uri.parse(_apiUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'x-api-key': AppConstants.claudeApiKey,
//         'anthropic-version': '2023-06-01',
//       },
//       body: jsonEncode({
//         'model': 'claude-opus-4-5',
//         'max_tokens': 500,
//         'messages': [
//           {
//             'role': 'user',
//             'content': [
//               {
//                 'type': 'image',
//                 'source': {
//                   'type': 'base64',
//                   'media_type': 'image/jpeg',
//                   'data': base64Image,
//                 },
//               },
//               {
//                 'type': 'text',
//                 'text': prompt,
//               }
//             ],
//           }
//         ],
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception('API Error: ${response.statusCode} — ${response.body}');
//     }

//     final decoded = jsonDecode(response.body);
//     final rawText = decoded['content'][0]['text'] as String;

//     // Parse the JSON Claude returned
//     final nutritionJson = jsonDecode(rawText) as Map<String, dynamic>;
//     return MealResult.fromJson(nutritionJson, imageFile.path);
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/meal_result.dart';
import '../../core/constants.dart';

class ClaudeService {
  static const _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<MealResult> analyzeMeal(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    const prompt = '''
Analyze this image and respond ONLY with a valid JSON object. No extra text, no markdown, no explanations — just raw JSON.

If the image contains food, use this format:
{
  "is_food": true,
  "meal_name": "string",
  "calories": integer,
  "protein_g": float,
  "carbs_g": float,
  "fat_g": float,
  "health_tip": "one helpful sentence"
}

If the image does NOT contain identifiable food (e.g. objects, people, animals, blurry/unclear images), respond with:
{
  "is_food": false,
  "meal_name": "Not a food item",
  "calories": 0,
  "protein_g": 0,
  "carbs_g": 0,
  "fat_g": 0,
  "health_tip": "Please take a clearer photo of a meal or food item."
}
''';

    final response = await http.post(
      Uri.parse('$_apiUrl?key=${AppConstants.geminiApiKey}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
              },
              {
                'text': prompt,
              }
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 1024,
          'thinkingConfig': {
            'thinkingBudget': 0,
          },
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode} — ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception(
          'No response from Gemini — possibly blocked. Raw: ${response.body}');
    }

    final finishReason = candidates[0]['finishReason'];
    final parts = candidates[0]['content']?['parts'] as List?;

    if (parts == null || parts.isEmpty) {
      throw Exception(
          'Gemini returned no content (finishReason: $finishReason). Try a clearer image.');
    }

    final rawText = parts[0]['text'] as String;

    final cleanText = rawText
        .replaceAll(RegExp(r'```json', caseSensitive: false), '')
        .replaceAll('```', '')
        .trim();

// Try to extract JSON even if there's surrounding text
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanText);
    if (jsonMatch == null) {
      print('RAW GEMINI RESPONSE: $cleanText'); // debug only
      throw Exception('No food detected or invalid response from AI.');
    }

    final nutritionJson =
        jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

    if (nutritionJson['is_food'] == false) {
      throw Exception(nutritionJson['health_tip'] ?? 'Not a food image.');
    }

    return MealResult.fromJson(nutritionJson, imageFile.path);
  }
}
