import 'package:Medicall/models/user_model_base.dart';

class ProviderUser extends User {
  String professionalTitle;
  String medLicense;
  String medLicenseState;
  String npi;
  String boardCertified;
  bool stripeConnectAuthorized;

  ProviderUser({
    this.professionalTitle = '',
    this.npi = '',
    this.boardCertified = '',
    this.medLicense = '',
    this.medLicenseState = '',
    this.stripeConnectAuthorized = false,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.baseToMap();
    userMap.addAll({
      'stripe_connect_authorized': stripeConnectAuthorized,
      'professional_title': professionalTitle,
      'npi': npi,
      'med_license': medLicense,
      'state_issued': medLicenseState,
      'board_certified': boardCertified,
    });
    return userMap;
  }

  static ProviderUser fromMap(String uid, Map<String, dynamic> data) {
    ProviderUser provider = ProviderUser();
    provider.professionalTitle =
        data['professional_title'] ?? provider.professionalTitle;
    provider.medLicense = data['med_license'] ?? provider.medLicense;
    provider.npi = data['npi'] ?? provider.npi;
    provider.boardCertified =
        data['board_certified'] ?? provider.boardCertified;
    provider.medLicenseState = data['state_issued'] ?? provider.medLicenseState;
    provider.stripeConnectAuthorized =
        data['stripe_connect_authorized'] ?? provider.stripeConnectAuthorized;
    return provider;
  }
}
