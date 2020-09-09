import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/drivers_license/drivers_license_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriversLicenseScreen extends StatelessWidget {
  final DriversLicenseViewModel model;
  final ExtendedImageProvider extendedImageProvider;

  const DriversLicenseScreen({
    @required this.model,
    @required this.extendedImageProvider,
  });

  static Widget create(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final ExtendedImageProvider extendedImageProvider =
        Provider.of<ExtImageProvider>(context);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    final FirebaseStorageService firestoreStorage =
        Provider.of<FirebaseStorageService>(context);
    return ChangeNotifierProvider<DriversLicenseViewModel>(
      create: (context) => DriversLicenseViewModel(
        userProvider: userProvider,
        firestoreDatabase: firestoreDatabase,
        firebaseStorageService: firestoreStorage,
      ),
      child: Consumer<DriversLicenseViewModel>(
        builder: (_, model, __) => DriversLicenseScreen(
          model: model,
          extendedImageProvider: extendedImageProvider,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
  }) async {
    if (pushReplaceNamed) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.driversLicense,
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.driversLicense,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
