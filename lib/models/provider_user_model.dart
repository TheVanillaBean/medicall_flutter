import 'package:Medicall/models/user_model_base.dart';

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

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.baseToMap();
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

  static Provider fromMap(String uid, Map<String, dynamic> data) {
    Provider provider = Provider();
    provider.titles = data['titles'] ?? provider.titles;
    provider.stripeConnectAuthorized =
        data['stripeConnectAuthorized'] ?? provider.stripeConnectAuthorized;
    provider.type = data['type'] ?? provider.type;
    return provider;
  }
}
