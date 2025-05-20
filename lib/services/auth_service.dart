import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password, String username) async{
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      final user = result.user;

      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'username': username,
        'displayName': username,
        'bio': "Hey, I'm a Sonique user!",
        'profilePic': null,
        'followerCount': 0,
        'followingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),

      });

      return user;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> logIn(String input, String password)async{
    try{
      String email = input;

      if (!input.contains('@')) {
        final query = await _firestore
            .collection('users')
            .where('username', isEqualTo: input)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('Username not found.');
        }


        email = query.docs.first['email'];
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      return result.user;
    } on FirebaseAuthException catch (e){
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

}