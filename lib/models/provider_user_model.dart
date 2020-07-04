import 'package:Medicall/models/user_model_base.dart';

class ProviderUser extends User {
  String titles;
  String medLicense;
  String medLicenseState;
  String npi;
  bool stripeConnectAuthorized;

  ProviderUser({
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
      'stripeConnectAuthorized': stripeConnectAuthorized,
      'titles': titles,
      'npi': npi,
      'med_license': medLicense,
      'state_issued': medLicenseState,
    });
    return userMap;
  }

  static ProviderUser fromMap(String uid, Map<String, dynamic> data) {
    ProviderUser provider = ProviderUser();
    provider.titles = data['titles'] ?? provider.titles;
    provider.stripeConnectAuthorized =
        data['stripeConnectAuthorized'] ?? provider.stripeConnectAuthorized;
    return provider;
  }
}
