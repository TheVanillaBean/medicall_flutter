import 'dart:async';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';

class DashboardStateModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;

  // ignore: close_sinks
  StreamController<List<Consult>> consultStream = StreamController();

  DashboardStateModel({
    @required this.database,
    @required this.userProvider,
  }) {
    database
        .getActiveConsultsForPatient(userProvider.user.uid)
        .listen((List<Consult> consults) {
      int consultIterator = 0;
      int userIterator = 0;
      while (consultIterator < consults.length) {
        database
            .userStream(USER_TYPE.PROVIDER, consults[userIterator].providerId)
            .listen((User user) {
          if (userIterator == consultIterator) {
            //data has already been previously loaded, but data for a user has changed on firestore
            consults = consults.map((consult) {
              if (consult.providerId == user.uid) {
                consult.providerUser = user as ProviderUser;
              }
            }).toList();
            consultStream.add(consults);
          } else {
            //first time loading data
            consults[userIterator].providerUser = user as ProviderUser;
            userIterator++;
            if (userIterator == consultIterator) {
              consultStream.add(consults);
            }
          }
        });
        consultIterator++;
      }
    });
  }
}
