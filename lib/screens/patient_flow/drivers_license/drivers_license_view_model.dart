import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class DriversLicenseViewModel with ChangeNotifier {
  List<Asset> idPhoto;
  bool isLoading;

  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;
  final FirebaseStorageService firebaseStorageService;

  DriversLicenseViewModel({
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.firebaseStorageService,
    this.isLoading = false,
    this.idPhoto = const [],
  });

  void updateWith({
    bool isLoading,
    List<Asset> idPhoto,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    this.idPhoto = idPhoto ?? this.idPhoto;
    notifyListeners();
  }
}
