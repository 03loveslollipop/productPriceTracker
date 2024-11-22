import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  //Create a singleton
  static final AuthService _instance = AuthService._internal();

  //Define a factory constructor
  factory AuthService() {
    return _instance;
  }

  //Define a private constructor
  AuthService._internal();

  //email and password methods
  static Future<User?> createUsr(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<User?> currentUser() async {
    try {
      return FirebaseAuth.instance.currentUser;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user != null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  //google sign in method

}
