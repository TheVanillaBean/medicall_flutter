import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PhotoIDViewModel with ChangeNotifier {
  final Consult consult;
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;
  final FirebaseStorageService firebaseStorageService;

  AssetEntity idPhoto;
  bool isLoading;

  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  PhotoIDViewModel({
    @required this.consult,
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.firebaseStorageService,
    this.isLoading = false,
    this.idPhoto,
  });

  Future<void> submit() async {
    if (this.idPhoto == null) {
      btnController.reset();
      throw "Please add a photo ID image...";
    }

    updateWith(isLoading: true);
    PatientUser medicallUser = userProvider.user;
    try {
      medicallUser.photoID =
          await firebaseStorageService.uploadProfileImage(asset: this.idPhoto);
    } catch (e) {
      updateWith(isLoading: false);
      btnController.reset();
      throw "Could not save your photo ID image...";
    }

    userProvider.user = medicallUser;
    await firestoreDatabase.setUser(userProvider.user);
    btnController.success();
    updateWith(isLoading: false);
  }

  void updateWith({
    bool isLoading,
    AssetEntity idPhoto,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    this.idPhoto = idPhoto ?? this.idPhoto;
    notifyListeners();
  }
}
