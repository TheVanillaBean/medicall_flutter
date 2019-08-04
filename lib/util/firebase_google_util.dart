import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:Medicall/util/firebase_listenter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseGoogleUtil {
  static final FirebaseGoogleUtil _instance = FirebaseGoogleUtil.internal();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuthListener _view;

  FirebaseGoogleUtil.internal();

  factory FirebaseGoogleUtil() {
    return _instance;
  }

  setScreenListener(FirebaseAuthListener view) {
    _view = view;
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    if (!identical(user.uid, currentUser.uid)) {
      onLoginUserVerified(currentUser);
    } else {
      onTokenError(user.toString());
    }
  }

  void onLoginUserVerified(FirebaseUser currentUser) {
    _view.onLoginUserVerified(currentUser);
  }

  onTokenError(String string) {
    _view.onError(string);
  }
}
