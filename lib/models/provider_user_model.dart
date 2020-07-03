import 'package:Medicall/models/user_model_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Provider extends User {
  String type;
  String titles;
  String medLicense;
  String medLicenseState;
  String npi;
  bool stripeConnectAuthorized;

  Provider({
    this.type = 'Provider',
    this.titles = '',
    this.npi = '',
    this.medLicense = '',
    this.medLicenseState = '',
    this.stripeConnectAuthorized = false,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.toMap();
    userMap.addAll({
      "type": type,
      'stripeConnectAuthorized': stripeConnectAuthorized,
      'titles': titles,
      'npi': npi,
      'med_license': medLicense,
      'state_issued': medLicenseState,
    });
    return userMap;
  }

  factory Provider.fromMap(String uid, DocumentSnapshot snapshot) {
    Provider provider = User.fromMap(uid, snapshot);
    provider.titles = snapshot.data['titles'] ?? provider.titles;
    provider.stripeConnectAuthorized =
        snapshot.data['stripeConnectAuthorized'] ??
            provider.stripeConnectAuthorized;
    provider.type = snapshot.data['type'] ?? provider.type;
    return provider;
  }
}
