import 'dart:async';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class PreviousVisitsViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;

  StreamController<List<Consult>> consultStream = StreamController();

  PreviousVisitsViewModel(
      {@required this.database, @required this.userProvider}) {
    database
        .getTotalConsultsForPatient(userProvider.user.uid)
        .listen((List<Consult> consults) {
      List<String> uniqueProviderIds = [];

      consults.forEach((consult) {
        if (!uniqueProviderIds.contains(consult.providerId)) {
          uniqueProviderIds.add(consult.providerId);
        }
      });

      uniqueProviderIds.forEach((providerId) {
        database
            .userStream(USER_TYPE.PROVIDER, providerId)
            .listen((MedicallUser user) {
          for (Consult consult in consults) {
            if (consult.providerId == user.uid) {
              consult.providerUser = user as ProviderUser;
            }
          }
          consultStream.add(consults.length > 0 ? consults : null);
        });
      });
    });
  }
}
