import 'package:Medicall/common_widgets/camera_picker/constants/constants.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class VideoNotesToPatientViewModel with ChangeNotifier {
  AssetEntity assetEntity;
  final FirestoreDatabase database;
  final UserProvider userProvider;

  VideoNotesToPatientViewModel(
      {this.database, this.userProvider, this.assetEntity});

  void updateWith({
    AssetEntity assetEntity,
  }) {
    this.assetEntity = assetEntity ?? this.assetEntity;
    notifyListeners();
  }

  void updateAssetEntity(AssetEntity assetEntity) =>
      updateWith(assetEntity: assetEntity);
}
