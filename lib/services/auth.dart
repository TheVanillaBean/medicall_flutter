import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/reg_user_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_auth_codes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  Stream<MedicallUser> get onAuthStateChanged;
  Future<MedicallUser> currentUser();
  MedicallUser medicallUser;
  TempRegUser tempRegUser;
  MedicallUser patientDetail;
  DocumentSnapshot consultSnapshot;
  List<DocumentSnapshot> userHistory;
  bool hasPayment;
  bool isDone;
  var consultQuestions;
  ConsultData newConsult;
  var userMedicalRecord;
  String currConsultId;
  Future<MedicallUser> signInAnonymously();
  Future<MedicallUser> signInWithEmailAndPassword(
      String email, String password);
  Future<MedicallUser> createUserWithEmailAndPassword(
      String email, String password);
  Future<MedicallUser> signInWithGoogle();
  Future<MedicallUser> signInWithPhoneNumber(
      String verificationId, String smsCode);
  Future<MedicallUser> currentMedicallUser();
  Future<void> signOut();
  Future<void> getConsultDetail();
  Future<void> getPatientDetail();
  Future<void> getUserHistory();
  signUp();
  saveImages();
  addUserMedicalHistory();
  getUserMedicalHistory();
  getConsultQuestions();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAnonymouslyUtil firebaseAnonymouslyUtil =
      FirebaseAnonymouslyUtil();

  MedicallUser _medicallUser;
  @override
  MedicallUser medicallUser;
  @override
  TempRegUser tempRegUser;
  @override
  MedicallUser patientDetail;
  @override
  DocumentSnapshot consultSnapshot;
  @override
  List<DocumentSnapshot> userHistory;
  @override
  bool hasPayment;
  @override
  bool isDone;
  @override
  String currConsultId;
  @override
  var consultQuestions;
  @override
  ConsultData newConsult = ConsultData();
  @override
  var userMedicalRecord;

  Future<MedicallUser> _getMedicallUser(String uid) async {
    if (uid != null) {
      final DocumentReference documentReference =
          Firestore.instance.collection('users').document(uid);

      try {
        final snapshot = await documentReference.get();
        _medicallUser = MedicallUser.from(uid, snapshot);
      } catch (e) {
        print('Error getting user');
      }
    }

    return _medicallUser;
  }

  MedicallUser _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    _medicallUser = MedicallUser(
      uid: user.uid,
      phoneNumber: user.phoneNumber,
      email: user.email,
    );
    return _medicallUser;
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
  Future<void> getConsultDetail() async {
    if (consultSnapshot == null ||
        currConsultId != consultSnapshot.documentID) {
      final DocumentReference documentReference =
          Firestore.instance.collection('consults').document(currConsultId);
      await documentReference.get().then((datasnapshot) async {
        if (datasnapshot.data != null) {
          consultSnapshot = datasnapshot;
          consultSnapshot.data['details'] = [
            consultSnapshot['screening_questions'],
            consultSnapshot['media']
          ];
          if (consultSnapshot['state'] == 'done') {
            isDone = true;
          } else {
            isDone = false;
          }
        }
      }).catchError((e) => print(e));
    }
  }

  @override
  Future<void> getPatientDetail() async {
    final DocumentReference documentReference = Firestore.instance
        .collection('users')
        .document(consultSnapshot.data['patient_id']);
    await documentReference.get().then((datasnapshot) async {
      if (datasnapshot.data != null) {
        patientDetail = MedicallUser(
            address: datasnapshot.data['address'],
            displayName: datasnapshot.data['name'],
            dob: datasnapshot.data['dob'],
            gender: datasnapshot.data['gender'],
            phoneNumber: datasnapshot.data['phone']);
        _getUserPaymentCard();
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getUserPaymentCard() async {
    if (medicallUser.uid.length > 0) {
      final Future<QuerySnapshot> documentReference = Firestore.instance
          .collection('cards')
          .document(medicallUser.uid)
          .collection('sources')
          .getDocuments();
      await documentReference.then((datasnapshot) {
        if (datasnapshot.documents.length > 0) {
          hasPayment = true;
        }
      }).catchError((e) => print(e));
    }
  }

  Future<void> getUserHistory() async {
    if (medicallUser.uid.length > 0) {
      final Future<QuerySnapshot> documentReference = Firestore.instance
          .collection('consults')
          .where(medicallUser.type == 'provider' ? 'provider_id' : 'patient_id',
              isEqualTo: medicallUser.uid)
          .orderBy('date', descending: true)
          .getDocuments();
      await documentReference.then((datasnapshot) {
        if (datasnapshot.documents != null) {
          userHistory = [];
          for (var i = 0; i < datasnapshot.documents.length; i++) {
            if (!userHistory.contains(datasnapshot.documents[i])) {
              userHistory.add(datasnapshot.documents[i]);
            }
          }
        }
      }).catchError((e) => print(e));
    }
  }

  Future<void> addUserMedicalHistory() async {
    if (medicallUser.uid.length > 0) {
      final DocumentReference ref = Firestore.instance
          .collection('medical_history')
          .document(medicallUser.uid);
      Map<String, dynamic> data = <String, dynamic>{
        "medical_history_questions": newConsult.historyQuestions,
      };
      ref.setData(data).whenComplete(() {
        print("Consult Added");
      }).catchError((e) => print(e));
    }
  }

  Future<void> getUserMedicalHistory() async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(medicallUser.uid)
          .get();
    }
  }

  Future<void> getConsultQuestions() async {
    if (medicallUser.uid.length > 0) {
      consultQuestions = await Firestore.instance
          .document('services/dermatology/symptoms/' +
              newConsult.consultType.toLowerCase())
          .get();
    }
  }

  @override
  Future<MedicallUser> currentMedicallUser() async {
    final user = await _firebaseAuth.currentUser();
    if (user != null) {
      return _getMedicallUser(user.uid);
    } else {
      return _getMedicallUser(null);
    }
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
    medicallUser = MedicallUser();
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> saveImages() async {
    if (medicallUser.uid.length > 0) {
      var assets = tempRegUser.images;
      var allMediaList = [];
      for (var i = 0; i < assets.length; i++) {
        ByteData byteData = await assets[i].requestOriginal();
        List<int> imageData = byteData.buffer.asUint8List();
        StorageReference ref = FirebaseStorage.instance
            .ref()
            .child("profile/" + medicallUser.uid + '/' + assets[i].name);
        StorageUploadTask uploadTask = ref.putData(imageData);

        allMediaList
            .add(await (await uploadTask.onComplete).ref.getDownloadURL());
      }
      medicallUser.profilePic = allMediaList[0];
      medicallUser.govId = allMediaList[1];
    }
  }

  @override
  signUp() async {
    await firebaseAnonymouslyUtil
        .createUser(tempRegUser.username, tempRegUser.pass)
        .then((String user) async {
      await login(tempRegUser.username, tempRegUser.pass);
    }).catchError((e) => loginError(getErrorMessage(error: e)));
  }

  Future login(String email, String pass) async {
    firebaseAnonymouslyUtil.signIn(email, pass).then((onValue) {
      medicallUser.uid = onValue.uid;
      return print('Login Success');
    }).catchError((e) => loginError(getErrorMessage(error: e)));
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

  loginError(e) {
    AppUtil().showAlert(e, 5);
  }
}
