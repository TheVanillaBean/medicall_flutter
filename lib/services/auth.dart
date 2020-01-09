import 'package:Medicall/models/medicall_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  Stream<MedicallUser> get onAuthStateChanged;
  Future<MedicallUser> currentUser();
  Future<MedicallUser> signInAnonymously();
  Future<MedicallUser> signInWithEmailAndPassword(
      String email, String password);
  Future<MedicallUser> createUserWithEmailAndPassword(
      String email, String password);
  Future<MedicallUser> signInWithGoogle();
  Future<MedicallUser> signInWithPhoneNumber(
      String verificationId, String smsCode);
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  MedicallUser _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return MedicallUser(
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      email: user.email,
    );
  }

  @override
  Stream<MedicallUser> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  @override
  Future<MedicallUser> currentUser() async {
    final user = await _firebaseAuth.currentUser();
    return _userFromFirebase(user);
  }

  @override
  Future<MedicallUser> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    final user = authResult.user;
    return _userFromFirebase(user);
  }

  @override
  Future<MedicallUser> signInWithEmailAndPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
    user.sendEmailVerification();
    return _userFromFirebase(user);
  }

  @override
  Future<MedicallUser> createUserWithEmailAndPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
    return _userFromFirebase(user);
  }

  @override
  Future<MedicallUser> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
        );

        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in canceled by user',
      );
    }
  }

  @override
  Future<MedicallUser> signInWithPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    final AuthResult authResult =
        await currentUser.linkWithCredential(credential);

    final MedicallUser currentMedicallUser = _userFromFirebase(authResult.user);

    if (currentMedicallUser != null &&
        currentMedicallUser.phoneNumber != null &&
        currentMedicallUser.phoneNumber.isNotEmpty) {
      await _firebaseAuth.signInWithCredential(credential);
      return currentMedicallUser;
    } else {
      throw PlatformException(
        code: 'ERROR_PHONE_AUTH_FAILED',
        message: 'Phone Sign In Failed.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
