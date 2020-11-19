import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class VideoToPatientStepState with ChangeNotifier {
  final ExtImageProvider extImageProvider;
  final FirebaseStorageService storageService;
  final VisitReviewViewModel visitReviewViewModel;

  MediaInfo mediaInfo;
  String videoURL;
  bool isLoading;
  bool isSubmitted;
  bool editedStep = false;

  final f = new DateFormat('E MMM d');

  final imagePicker = ImagePicker();

  VideoToPatientStepState({
    @required this.visitReviewViewModel,
    @required this.storageService,
    @required this.extImageProvider,
    this.mediaInfo,
    this.isLoading = false,
    this.isSubmitted = false,
    this.videoURL = "",
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    VisitReviewData firestoreData = this.visitReviewViewModel.visitReviewData;
    if (firestoreData.videoNoteURL.length > 0) {
      this.updateWith(videoURL: firestoreData.videoNoteURL);

      if (minimumRequiredFieldsFilledOut) {
        visitReviewViewModel.addCompletedStep(
            step: VisitReviewSteps.PatientVideoStep, setState: false);
      }
    }
  }

  bool get minimumRequiredFieldsFilledOut {
    return (this.mediaInfo != null || this.videoURL.length > 0) &&
        !this.isLoading &&
        !this.isSubmitted;
  }

  String get formattedRecordedDate {
    return f.format(visitReviewViewModel.consult.date);
  }

  void updateAssetEntity(MediaInfo mediaInfo) =>
      updateWith(mediaInfo: mediaInfo);

  void updateWith({
    MediaInfo mediaInfo,
    bool isLoading,
    bool isSubmitted,
    String videoURL,
  }) {
    this.editedStep = true;
    this.mediaInfo = mediaInfo ?? this.mediaInfo;
    this.isLoading = isLoading ?? this.isLoading;
    this.isSubmitted = isSubmitted ?? this.isSubmitted;
    this.videoURL = videoURL ?? this.videoURL;
    notifyListeners();
  }
}
