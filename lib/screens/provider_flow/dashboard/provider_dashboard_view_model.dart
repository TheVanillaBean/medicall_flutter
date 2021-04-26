import 'dart:async';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

class ProviderDashboardViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;

  // ignore: close_sinks
  StreamController<List<Consult>> consultStream = StreamController();

  ProviderDashboardViewModel({
    @required this.database,
    @required this.userProvider,
  }) {
    consultStream.add([]);

    database.getPendingConsultsForProvider(userProvider.user.uid).listen(
      (List<Consult> consults) {
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
      },
    );
  }

  Future<String> getVideoLink(Consult consult) async {
    final callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'retrieveVideoLink')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'consult_id': consult.uid,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    // this.updateWith(isLoading: false);

    if (result.data != null) {
      return result.data;
    }

    return "";
  }
}
