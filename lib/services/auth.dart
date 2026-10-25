import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_tracking_app/models/AppUser.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _userFromFirebaseUser(User? user) {
    return user != null ? AppUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<AppUser?> get user {

    return _auth.authStateChanges()
      .map((User? user)=> _userFromFirebaseUser(user));

  }

  // sign in anom

  Future signInAnom() async {
    try{
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);

    }catch(e) {
      print('Sign-in failed: $e');
      return null;

    }
  }

  // sign in with email and password

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);

    }catch(e){
      print (e.toString());
      return null;
    }
  }

  // register with email and password

  Future registerWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);

    }catch(e){
      print (e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print('Sign-out failed: $e');
      return null;
    }
  }


}