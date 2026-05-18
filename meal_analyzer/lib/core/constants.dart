class AppConstants {
  // ⚠️ In production: use flutter_dotenv or --dart-define
  // Never hardcode keys in a real app!
  static const claudeApiKey = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: 'YOUR_KEY_HERE',
  );
  static const String mealHistoryBox = 'meal_history_box';
  static const String appName = 'Nutrient Analyzer';
  static const String tagline = 'It analysies your deit';

}