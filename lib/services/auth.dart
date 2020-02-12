import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/reg_user_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_auth_codes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  Stream<MedicallUser> get onAuthStateChanged;
  Future<MedicallUser> currentUser();
  bool newUser;
  void addUserToAuthStream(MedicallUser user);
  bool isGoogleUser;
  Future<MedicallUser> signInAnonymously();
  Future<MedicallUser> signInWithEmailAndPassword(
      String email, String password);
  Future<MedicallUser> createUserWithEmailAndPassword(
      String email, String password);
  Future<MedicallUser> signInWithGoogle();
  Future<MedicallUser> signInWithPhoneNumber(
      String verificationId, String smsCode);
  Future<void> signOut();
  signUp(BuildContext context);
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAnonymouslyUtil firebaseAnonymouslyUtil =
      FirebaseAnonymouslyUtil();
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

  void addUserToAuthStream(MedicallUser user) {
    authStreamController.sink.add(user);
  }

  MedicallUser _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    //check google sign in
    for (var i = 0; i < user.providerData.length; i++) {
      if (user.providerData[i].providerId == 'google.com') {
        isGoogleUser = true;
      }
    }
    medicallUser = MedicallUser(
      displayName: user.displayName != null ? user.displayName : null,
      firstName:
          user.displayName != null ? user.displayName.split(' ')[0] : null,
      lastName:
          user.displayName != null ? user.displayName.split(' ')[1] : null,
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      email: user.email,
    );
    return medicallUser;
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
      String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
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

  //returnGoogleCreds

  @override
  Future<MedicallUser> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        //return credential
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

    final AuthResult linkPhoneAuthResult =
        await currentUser.linkWithCredential(credential);

    final MedicallUser currentMedicallUser =
        _userFromFirebase(linkPhoneAuthResult.user);

    if (currentMedicallUser != null &&
        currentMedicallUser.phoneNumber != null &&
        currentMedicallUser.phoneNumber.isNotEmpty) {
      // final phoneSignInAuthResult =
      //     await _firebaseAuth.signInWithCredential(credential);
      // final user = phoneSignInAuthResult.user;
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
    medicallUser = MedicallUser(displayName: 'logout');
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }

  Future login(String email, String pass, context) async {
    firebaseAnonymouslyUtil.signIn(email, pass).then((onValue) {
      medicallUser.uid = onValue.uid;
      return print('Login Success');
    }).catchError((e) => loginError(getErrorMessage(error: e), context));
  }

  String getErrorMessage({dynamic error}) {
    if (error.code == FirebaseAuthCodes.ERROR_USER_NOT_FOUND) {
      return "A user with this email does not exist. Register first.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_DISABLED) {
      return "This user account has been disabled.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_TOKEN_EXPIRED) {
      return "A password change is in the process.";
    } else {
      return error.message;
    }
  }

  @override
  signUp(context) async {
    await firebaseAnonymouslyUtil
        .createUser(tempRegUser.username, tempRegUser.pass)
        .then((String user) async {
      await login(tempRegUser.username, tempRegUser.pass, context);
    }).catchError((e) => loginError(getErrorMessage(error: e), context));
  }

  loginError(e, context) {
    AppUtil().showFlushBar(e, context);
  }
}
