import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '././models/meal_result.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's meals collection reference.
  // Throws a helpful error if no user is signed in.
  CollectionReference<Map<String, dynamic>> get _mealsRef {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-signed-in',
        message: 'You must be signed in to access saved meals.',
      );
    }

    return _db
        .collection('user')
        .doc(currentUser.uid)
        .collection('user_history');
  }

  // Save a meal after analysis
  Future<void> saveMeal(MealResult meal) async {
    await _mealsRef.add({
      'meal_name': meal.mealName,
      'calories': meal.calories,
      'protein_g': meal.protein,
      'carbs_g': meal.carbs,
      'fat_g': meal.fat,
      'health_tip': meal.healthTip,
      'image_path': meal.imagePath,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Fetch all meals, newest first
  Future<List<MealResult>> getMeals() async {
    final snapshot =
        await _mealsRef.orderBy('created_at', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MealResult.fromFirestore(
        data,
        doc.id,
        data['image_path'] ?? '',
      );
    }).toList();
  }

  // Delete a meal by Firestore document ID
  Future<void> deleteMeal(String docId) async {
    await _mealsRef.doc(docId).delete();
  }

  Future<void> clearAllMeals() async {
    final snapshot = await _mealsRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
