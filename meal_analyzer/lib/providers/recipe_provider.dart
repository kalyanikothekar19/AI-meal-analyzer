import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/recipe.dart';
import '../data/services/recipe_service.dart';
import '../data/services/image_service.dart';

final recipeServiceProvider = Provider<RecipeService>((ref) => RecipeService());
final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

final recipesProvider =
    FutureProvider.family<List<Recipe>, String>((ref, foodName) async {
  final recipeService = ref.read(recipeServiceProvider);
  final imageService = ref.read(imageServiceProvider);

  final recipes = await recipeService.generateRecipes(foodName);

  // Fetch all 3 images in parallel rather than one-by-one — keeps
  // the sheet's loading time roughly the same as a single image fetch.
  final withImages = await Future.wait(
    recipes.map((recipe) async {
      final url = await imageService.fetchImageUrl(recipe.title);
      return recipe.copyWithImage(url);
    }),
  );

  return withImages;
});
