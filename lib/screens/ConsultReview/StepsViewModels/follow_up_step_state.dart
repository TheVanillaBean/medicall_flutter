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

class FollowUpStepState {
  String followUp;
}
