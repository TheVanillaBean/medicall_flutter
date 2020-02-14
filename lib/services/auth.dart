import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  bool newUser;
  bool isGoogleUser;
  Stream<MedicallUser> get onAuthStateChanged;
  Future<MedicallUser> currentUser();
  void addUserToAuthStream({@required MedicallUser user});
  Future<MedicallUser> signInAnonymously();
  Future<MedicallUser> signInWithEmailAndPassword(
      {@required String email, @required String password});
  Future<MedicallUser> createUserWithEmailAndPassword(
      {@required String email, @required String password});
  Future<List<String>> fetchProvidersForEmail({@required String email});
  Future<GoogleAuthModel> fetchGoogleSignInCredential();
  Future<AuthCredential> fetchPhoneAuthCredential(
      {@required String verificationId, @required String smsCode});
  Future<MedicallUser> signInWithGoogle();
  Future<MedicallUser> linkCredentialWithCurrentUser(
      {@required AuthCredential credential});
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  bool isGoogleUser = false;

  // ignore: close_sinks
  StreamController<MedicallUser> authStreamController;

  bool newUser = false;

  Auth() {
    authStreamController = StreamController();
    _firebaseAuth.onAuthStateChanged.listen((user) {
      if (!newUser) {
        print("Existing User");
        authStreamController.sink.add(_userFromFirebase(user));
      } else {
        print("New User");
      }
    });
  }

  void addUserToAuthStream({@required MedicallUser user}) {
    authStreamController.sink.add(user);
  }

  MedicallUser _userFromFirebase(FirebaseUser user) {
//    if (user == null) {
//      return null;
//    }
//    //check google sign in
//    for (var i = 0; i < user.providerData.length; i++) {
//      if (user.providerData[i].providerId == 'google.com') {
//        isGoogleUser = true;
//      }
//    }
//    medicallUser = MedicallUser(
//      displayName: user.displayName != null ? user.displayName : null,
//      firstName:
//          user.displayName != null ? user.displayName.split(' ')[0] : null,
//      lastName:
//          user.displayName != null ? user.displayName.split(' ')[1] : null,
//      uid: user.uid,
//      phoneNumber: user.phoneNumber,
//      email: user.email,
//    );
//    return medicallUser;
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
    return authStreamController.stream;
//    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
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
      {@required String email, @required String password}) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
    return _userFromFirebase(user);
  }

  @override
  Future<MedicallUser> createUserWithEmailAndPassword(
      {@required String email, @required String password}) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
    return _userFromFirebase(user);
  }

  Future<List<String>> fetchProvidersForEmail({@required String email}) async {
    return await _firebaseAuth.fetchSignInMethodsForEmail(email: email);
  }

  Future<GoogleAuthModel> fetchGoogleSignInCredential() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final AuthCredential credential = GoogleAuthProvider.getCredential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

        return GoogleAuthModel(
            email: googleAccount.email, credential: credential);
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

  Future<AuthCredential> fetchPhoneAuthCredential({
    @required String verificationId,
    @required String smsCode,
  }) async {
    return PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
  }

  @override
  Future<MedicallUser> signInWithGoogle(
      {@required AuthCredential credential}) async {
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<MedicallUser> linkCredentialWithCurrentUser(
      {AuthCredential credential}) async {
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    final AuthResult linkCredentialAuthResult =
        await currentUser.linkWithCredential(credential);

    final MedicallUser currentMedicallUser =
        _userFromFirebase(linkCredentialAuthResult.user);

    if (currentMedicallUser != null) {
      currentUser.sendEmailVerification();
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
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
