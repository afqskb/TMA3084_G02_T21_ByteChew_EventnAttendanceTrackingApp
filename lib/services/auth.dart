import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_tracking_app/models/app_user.dart';
import 'package:logger/logger.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();
  String error = '';

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
      logger.d('Debug message');
      logger.e('Error message: $error');
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
      logger.d('Debug message');
      logger.e('Error message: $error');
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
      logger.d('Debug message');
      logger.e('Error message: $error');
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      logger.d('Debug message');
      logger.e('Error message: $error');
      return null;
    }
  }


}