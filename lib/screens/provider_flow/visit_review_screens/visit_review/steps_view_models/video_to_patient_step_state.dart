import 'package:Medicall/common_widgets/camera_picker/constants/constants.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';

class VideoToPatientStepState with ChangeNotifier {
  final ExtImageProvider extImageProvider;
  final FirebaseStorageService storageService;
  final VisitReviewViewModel visitReviewViewModel;

  AssetEntity assetEntity;
  String videoURL;
  bool isLoading;
  bool editedStep = false;

  VideoToPatientStepState({
    @required this.visitReviewViewModel,
    @required this.storageService,
    @required this.extImageProvider,
    this.assetEntity,
    this.isLoading = false,
    this.videoURL = "",
  });

  bool get minimumRequiredFieldsFilledOut {
    return this.assetEntity != null;
  }

  void updateAssetEntity(AssetEntity assetEntity) =>
      updateWith(assetEntity: assetEntity);

  void updateWith({
    AssetEntity assetEntity,
    bool isLoading,
    String videoURL,
  }) {
    this.editedStep = true;
    this.assetEntity = assetEntity ?? this.assetEntity;
    this.isLoading = isLoading ?? this.isLoading;
    this.videoURL = videoURL ?? this.videoURL;
    notifyListeners();
  }
}
