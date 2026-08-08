import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_analyzer/core/constants.dart';

// Fetches a single relevant photo URL from Pexels for a given search term.
// Used to attach a real photo to each AI-generated recipe.
class ImageService {
  static const _endpoint = 'https://api.pexels.com/v1/search';

  Future<String?> fetchImageUrl(String query) async {
    final apiKey = AppConstants.pexelsApiKey;
    if (apiKey == null || apiKey.isEmpty)
      return null; // fail silently — image is optional

    try {
      final uri = Uri.parse(
          '$_endpoint?query=${Uri.encodeComponent(query)}&per_page=1');
      final response = await http.get(uri, headers: {'Authorization': apiKey});

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final photos = data['photos'] as List?;
      if (photos == null || photos.isEmpty) return null;

      // 'medium' size is a good balance for card thumbnails — swap to
      // 'large' if you want a sharper hero image on the detail screen.
      return photos[0]['src']?['medium'] as String?;
    } catch (_) {
      // Any network/parsing hiccup here shouldn't break the whole recipe flow.
      return null;
    }
  }
}
