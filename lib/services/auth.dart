import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pedantic/pedantic.dart';

abstract class AuthBase {
  bool triggerAuthStream;
  Stream<MedicallUser> get onAuthStateChanged;
  Future<MedicallUser> currentUser();
  Future<String> currentUserIdToken();
  Future<void> addUserToAuthStream({@required FirebaseUser user});
  Future<MedicallUser> signInAnonymously();
  Future<MedicallUser> signInWithEmailAndPassword(
      {@required String email, @required String password});
  Future<FirebaseUser> createUserWithEmailAndPassword(
      {@required String email, @required String password});
  Future<List<String>> fetchProvidersForEmail({@required String email});
  Future<AuthCredential> fetchEmailAndPasswordCredential(
      {@required String email, @required String password});
  Future<GoogleAuthModel> fetchGoogleSignInCredential();
  Future<AppleSignInModel> fetchAppleSignInCredential(
      {List<Scope> scopes = const []});
  Future<AuthCredential> fetchPhoneAuthCredential(
      {@required String verificationId, @required String smsCode});
  Future<FirebaseUser> signInWithGoogle({@required AuthCredential credential});
  Future<FirebaseUser> signInWithApple(
      {@required AuthCredential appleIdCredential});
  Future<MedicallUser> signInWithPhoneNumber(
      {@required AuthCredential credential});
  Future<FirebaseUser> linkCredentialWithCurrentUser(
      {@required AuthCredential credential});
  Future<bool> emailAlreadyUsed({@required String email});
  Future<bool> phoneNumberAlreadyUsed({@required String phoneNumber});
  Future<void> resetPassword({@required String email});
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  // ignore: close_sinks
  StreamController<MedicallUser> authStreamController;

  bool triggerAuthStream = true;

  Auth() {
    authStreamController = StreamController();
    _firebaseAuth.onAuthStateChanged.listen((user) {
      if (triggerAuthStream) {
        unawaited(addUserToAuthStream(user: user));
      }
      triggerAuthStream = true;
    });
  }

  Future<void> addUserToAuthStream({@required FirebaseUser user}) async {
    if (user == null) {
      authStreamController.sink.add(null);
      return;
    }
    MedicallUser medicallUser = await _getMedicallUserFromFirestore(user: user);
    authStreamController.sink.add(medicallUser);
  }

  Future<MedicallUser> _getMedicallUserFromFirestore(
      {@required FirebaseUser user}) async {
    final DocumentReference documentReference =
        Firestore.instance.collection('users').document(user.uid);
    final snapshot = await documentReference.get();
    return MedicallUser.from(user.uid, snapshot);
  }

  MedicallUser _userFromFirebaseAuth(FirebaseUser user) {
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
  }

  @override
  Future<MedicallUser> currentUser() async {
    final user = await _firebaseAuth.currentUser();
    return _userFromFirebaseAuth(user);
  }

  @override
  Future<String> currentUserIdToken() async {
    final user = await _firebaseAuth.currentUser();
    await user.reload();
    final IdTokenResult idToken = await user.getIdToken(refresh: true);
    return idToken.token;
  }

  @override
  Future<MedicallUser> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    final user = authResult.user;
    return _userFromFirebaseAuth(user);
  }

  @override
  Future<MedicallUser> signInWithEmailAndPassword(
      {@required String email, @required String password}) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
    return _userFromFirebaseAuth(user);
  }

  @override
  Future<FirebaseUser> createUserWithEmailAndPassword(
      {@required String email, @required String password}) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = authResult.user;
    unawaited(user.sendEmailVerification());
    return user;
  }

  Future<List<String>> fetchProvidersForEmail({@required String email}) async {
    return await _firebaseAuth.fetchSignInMethodsForEmail(email: email);
  }

  @override
  Future<AuthCredential> fetchEmailAndPasswordCredential(
      {String email, String password}) async {
    return EmailAuthProvider.getCredential(email: email, password: password);
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

        List<String> providers =
            await this.fetchProvidersForEmail(email: googleAccount.email);

        return GoogleAuthModel(
          email: googleAccount.email,
          credential: credential,
          displayName: googleAccount.displayName,
          providers: providers,
        );
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

  Future<AppleSignInModel> fetchAppleSignInCredential(
      {List<Scope> scopes = const []}) async {
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider(providerId: 'apple.com');
        final credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );

        List<String> providers = List<String>();
        try {
          providers =
              await this.fetchProvidersForEmail(email: appleIdCredential.email);
        } catch (e) {
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message:
                "Apple Sign In Error. Please go to Settings -> [Your Apple ID] (First List Item) -> Password and Security -> Apps using Your Apple ID -> Medicall -> Stop Using Apple ID. Then Try Again.",
          );
        }

        return AppleSignInModel(
          email: appleIdCredential.email,
          credential: credential,
          displayName: appleIdCredential.fullName.givenName,
          providers: providers,
        );
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
    }
    return null;
  }

  @override
  Future<FirebaseUser> signInWithGoogle(
      {@required AuthCredential credential}) async {
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    return authResult.user;
  }

  @override
  Future<FirebaseUser> signInWithApple(
      {@required AuthCredential appleIdCredential}) async {
    final authResult =
        await _firebaseAuth.signInWithCredential(appleIdCredential);
    return authResult.user;
  }

  @override
  Future<FirebaseUser> linkCredentialWithCurrentUser(
      {AuthCredential credential}) async {
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    final AuthResult linkCredentialAuthResult =
        await currentUser.linkWithCredential(credential);

    final MedicallUser currentMedicallUser =
        _userFromFirebaseAuth(linkCredentialAuthResult.user);

    if (currentMedicallUser != null) {
      return currentUser;
    } else {
      throw PlatformException(
        code: 'ERROR_PHONE_AUTH_FAILED',
        message: 'Phone Sign In Failed.',
      );
    }
  }

  @override
  Future<MedicallUser> signInWithPhoneNumber(
      {AuthCredential credential}) async {
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    return _userFromFirebaseAuth(authResult.user);
  }

  @override
  Future<bool> emailAlreadyUsed({@required String email}) async {
    List<String> providers = await this.fetchProvidersForEmail(email: email);

    return (providers != null && providers.length > 0);
  }

  @override
  Future<bool> phoneNumberAlreadyUsed({@required String phoneNumber}) async {
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'checkPhoneNumberAlreadyUsed')
          ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'phoneNumber': phoneNumber,
      },
    );

    return (!["NONE", null, false, 0].contains(result.data));
  }

  @override
  Future<void> resetPassword({@required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
