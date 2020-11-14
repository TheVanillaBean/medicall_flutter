import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/foundation.dart';

abstract class FollowUpSteps {
  static const String ViaMedicall = 'Follow-up via Medicall';
  static const String InPerson = 'Follow-up in person';
  static const String ElectiveProcedure =
      'At patient discretion (elective procedure)';
  static const String NoFollowUp = 'No follow-up needed/As needed basis';
  static const String Emergency = 'Immediate medical care (Emergency/ED)';
  static List<String> get followUpSteps => [
        FollowUpSteps.ViaMedicall,
        FollowUpSteps.InPerson,
        FollowUpSteps.ElectiveProcedure,
        FollowUpSteps.NoFollowUp,
        FollowUpSteps.Emergency,
      ];
}

class FollowUpStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;

  String followUp;
  String documentation; //if immediate care option
  String duration;

  bool editedStep = false;

  FollowUpStepState({
    @required this.visitReviewViewModel,
    this.followUp = "",
    this.documentation = "",
    this.duration = "",
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    VisitReviewData firestoreData = this.visitReviewViewModel.visitReviewData;
    if (firestoreData.followUp != null && firestoreData.followUp.length > 0) {
      if (firestoreData.followUp.keys.first != null) {
        this.followUp = firestoreData.followUp.keys.first;
        String followUpValue = firestoreData.followUp.values.first;
        if (followUpValue.length != null) {
          if (this.followUp == FollowUpSteps.ViaMedicall ||
              this.followUp == FollowUpSteps.InPerson) {
            this.duration = followUpValue;
          } else if (this.followUp == FollowUpSteps.Emergency) {
            this.documentation = followUpValue;
          }
        }

        if (this.followUp == FollowUpSteps.ViaMedicall ||
            this.followUp == FollowUpSteps.InPerson ||
            this.followUp == FollowUpSteps.ElectiveProcedure ||
            this.followUp == FollowUpSteps.Emergency ||
            this.followUp == FollowUpSteps.NoFollowUp) {
          if (minimumRequiredFieldsFilledOut) {
            visitReviewViewModel.addCompletedStep(
                step: VisitReviewSteps.FollowUpStep, setState: false);
          }
        }
      }
    }
  }

  bool get minimumRequiredFieldsFilledOut {
    return this.followUp.length > 0;
  }

  Map<String, String> get followUpMap {
    if (followUp == FollowUpSteps.ViaMedicall ||
        followUp == FollowUpSteps.InPerson) {
      return {followUp: duration};
    } else if (followUp == FollowUpSteps.Emergency) {
      return {followUp: documentation};
    } else {
      return {followUp.length > 0 ? followUp : "": ""};
    }
  }

  String get getInitialValueForFollowUp {
    if (followUp == FollowUpSteps.ViaMedicall ||
        followUp == FollowUpSteps.InPerson) {
      return duration;
    } else if (followUp == FollowUpSteps.Emergency) {
      return documentation;
    } else {
      return "";
    }
  }

  void updateFollowUpStepWith({
    String followUp,
    String documentation,
    String duration,
  }) {
    this.editedStep = true;

    this.followUp = followUp ?? this.followUp;
    this.documentation = documentation ?? this.documentation;
    this.duration = duration ?? this.duration;
    notifyListeners();
  }
}
