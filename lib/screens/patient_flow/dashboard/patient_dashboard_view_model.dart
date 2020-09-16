import 'dart:async';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';

class PatientDashboardViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;

  String get userFullName => userProvider.user.fullName.length > 3
      ? userProvider.user.fullName
      : "Patient";

  String get userFirstName => userProvider.user.firstName != ''
      ? userProvider.user.firstName
      : "Patient";

  // ignore: close_sinks
  StreamController<List<Consult>> consultStream = StreamController();

  PatientDashboardViewModel({
    @required this.database,
    @required this.userProvider,
  }) {
    consultStream.add([]);

    database
        .getActiveConsultsForPatient(userProvider.user.uid)
        .listen((List<Consult> consults) {
      List<String> uniqueProviderIds = [];

      consults.forEach((consult) {
        if (!uniqueProviderIds.contains(consult.providerId)) {
          uniqueProviderIds.add(consult.providerId);
        }
      });

      if (uniqueProviderIds.length == 0) {
        consultStream.add([]);
      } else {
        uniqueProviderIds.forEach((providerId) {
          database
              .userStream(USER_TYPE.PROVIDER, providerId)
              .listen((MedicallUser user) {
            for (Consult consult in consults) {
              if (consult.providerId == user.uid) {
                consult.providerUser = user as ProviderUser;
                if (consult.state == ConsultStatus.Completed) {
                  //Completed consults are not signed and should show to the user as in review
                  consult.state = ConsultStatus.InReview;
                }
              }
            }
            consultStream.add(consults.length > 0 ? consults : []);
          });
        });
      }
    });
  }
}
