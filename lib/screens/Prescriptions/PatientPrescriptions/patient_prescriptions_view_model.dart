import 'dart:async';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

class PatientPrescriptionsViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;

  // ignore: close_sinks
  StreamController<List<TreatmentOptions>> treatmentOptionsStream =
      StreamController();

  PatientPrescriptionsViewModel({
    @required this.database,
    @required this.userProvider,
  }) {
    treatmentOptionsStream.add([]);

    database
        .getConsultsForPatient(
            userProvider.user.uid, EnumToString.parse(ConsultStatus.Signed))
        .listen((consults) {
      List<TreatmentOptions> treatmentOptions = [];

      consults.forEach((consult) {
        database
            .visitReviewStream(consultId: consult.uid)
            .listen((visitReview) {
          if (visitReview.treatmentOptions.length > 0) {
            treatmentOptions.addAll(visitReview.treatmentOptions);
          }
          treatmentOptionsStream.add(treatmentOptions);
        });
      });
    });
  }
}
