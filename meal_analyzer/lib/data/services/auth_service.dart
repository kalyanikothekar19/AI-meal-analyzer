import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password ──────────────────────────────

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<void> sendPasswordReset(String email) async {
      try {
        await _auth.sendPasswordResetEmail(email: email.trim());
      } on FirebaseAuthException catch (e) {
        // Throw the error message to catch it in the UI
        throw Exception(e.message ?? 'An unknown error occurred.');
      }
    }
  // ── Google Sign-In ────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> createUserProfile(String uid, Map<String, dynamic> userData) async {
    try {
      // We use the Auth UID as the document ID so we can easily find the user later
      await _db.collection('user').doc(uid).set(userData);
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // ── Sign Out ──────────────────────────────────────
Future<UserCredential?>signInwithGoogleWeb()async {
  GoogleAuthProvider authProvider = GoogleAuthProvider();
        // signInWithPopup safely manages the browser window and catches closures!
  return await _auth.signInWithPopup(authProvider); 
}
  Future<void> signOut() async {
// try {
//     // Attempt to clear Google session if it exists
//     await _googleSignIn.signOut();
//   } catch (e) {
//     print('Google sign-out skipped or failed: $e');
//   }    
  await _auth.signOut();
  }
}