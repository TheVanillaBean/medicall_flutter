import 'dart:async';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class ProviderVisitsViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;
  bool isLoading = false;

  StreamController<List<Consult>> consultStream = StreamController();

  ProviderVisitsViewModel(
      {@required this.database, @required this.userProvider}) {
    database
        .getConsultsForProvider(userProvider.user.uid)
        .listen((List<Consult> consults) {
      List<String> uniquePatientIds = [];

      consults.forEach((consult) {
        if (!uniquePatientIds.contains(consult.patientId)) {
          uniquePatientIds.add(consult.patientId);
        }
      });

      if (uniquePatientIds.length == 0) {
        consultStream.add([]);
      } else {
        uniquePatientIds.forEach((patientId) {
          database
              .userStream(USER_TYPE.PATIENT, patientId)
              .listen((MedicallUser user) {
            for (Consult consult in consults) {
              if (consult.patientId == user.uid) {
                consult.patientUser = user as PatientUser;
              }
            }
            consultStream.add(consults.length > 0 ? consults : null);
          });
        });
      }
    });
  }

  void updateWith({bool isLoading}) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
