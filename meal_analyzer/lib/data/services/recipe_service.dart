import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/recipe.dart';

// Asks Gemini to generate 3 balanced-diet recipes for a given food.
// Reuses the same "force JSON, thinkingBudget: 0" pattern as your
// meal analysis call, so behaviour stays predictable.
class RecipeService {
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<List<Recipe>> generateRecipes(String foodName) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Missing GEMINI_API_KEY in .env');
    }

    final prompt = '''
Suggest exactly 3 healthy, balanced recipes where "$foodName" is a main ingredient.
Return ONLY valid JSON. No markdown, no backticks, no extra text.
Use this exact structure:
{
  "recipes": [
    {
      "title": "string",
      "description": "one short line, max 15 words",
      "difficulty": "Easy" | "Medium" | "Hard",
      "prepTimeMinutes": number,
      "calories": number,
      "ingredients": ["string", "string"],
      "steps": ["string", "string"]
    }
  ]
}
''';

    final response = await http.post(
      Uri.parse('$_endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "thinkingConfig": {"thinkingBudget": 0},
          "maxOutputTokens": 2048,
        },
      }),
    );
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Recipe generation failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final rawText =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

    if (rawText == null || rawText.trim().isEmpty) {
      throw Exception('Gemini returned an empty response');
    }

    // Gemini sometimes wraps JSON in markdown fences despite instructions —
    // same defensive extraction you use for meal analysis.
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
    if (match == null) {
      throw Exception('Could not find JSON in Gemini response');
    }

    final parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
    final recipesJson = parsed['recipes'] as List? ?? [];

    return recipesJson
        .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
