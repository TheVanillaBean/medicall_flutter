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

  FollowUpStepState({
    @required this.visitReviewViewModel,
    this.followUp = "",
    this.documentation = "",
    this.duration = "",
  });

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
      return {followUp.length > 0 ? followUp : "N/A": "N/A"};
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
    this.followUp = followUp ?? this.followUp;
    this.documentation = documentation ?? this.documentation;
    this.duration = duration ?? this.duration;
    notifyListeners();
  }
}
