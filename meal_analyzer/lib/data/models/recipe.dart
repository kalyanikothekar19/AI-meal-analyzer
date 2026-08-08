class Recipe {
  final String title;
  final String description;
  final String difficulty;
  final int prepTimeMinutes;
  final int calories;
  final List<String> ingredients;
  final List<String> steps;
  final String?
      imageUrl; // 🆕 nullable — populated after a separate image fetch

  Recipe({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.calories,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title']?.toString() ?? 'Untitled Recipe',
      description: json['description']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'Easy',
      prepTimeMinutes: _toInt(json['prepTimeMinutes'], fallback: 15),
      calories: _toInt(json['calories'], fallback: 0),
      ingredients: List<String>.from(json['ingredients'] ?? const []),
      steps: List<String>.from(json['steps'] ?? const []),
    );
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse('$value') ?? fallback;
  }

  // Returns a copy with the image URL attached — Recipe itself stays immutable.
  Recipe copyWithImage(String? url) {
    return Recipe(
      title: title,
      description: description,
      difficulty: difficulty,
      prepTimeMinutes: prepTimeMinutes,
      calories: calories,
      ingredients: ingredients,
      steps: steps,
      imageUrl: url,
    );
  }
}
