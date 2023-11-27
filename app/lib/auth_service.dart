
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUp({required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
//send email verification email
final user = FirebaseAuth.instance.currentUser;
if (user != null && !user.emailVerified) {
  await user.sendEmailVerification();
}
  }

  Future<String?> getUserId() async {
    try {
      User? user = _firebaseAuth.currentUser;
      return user?.uid;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }
}
