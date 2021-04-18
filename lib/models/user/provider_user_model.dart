import 'package:Medicall/models/user/user_model_base.dart';

class ProviderUser extends MedicallUser {
  String professionalTitle;
  String medSchool;
  String medResidency;
  String medLicense;
  String medLicenseState;
  String npi;
  String boardCertified;
  String providerBio;
  String practiceName;
  bool stripeConnectAuthorized;
  List<dynamic> selectedServices;
  List<String> acceptedInsurances;
  String assistantEmail;
  bool nylasConnected;

  ProviderUser({
    this.professionalTitle = '',
    this.medSchool = '',
    this.medResidency = '',
    this.medLicense = '',
    this.medLicenseState = '',
    this.npi = '',
    this.boardCertified = '',
    this.providerBio = '',
    this.practiceName = '',
    this.stripeConnectAuthorized = false,
    this.selectedServices = const [],
    this.assistantEmail = '',
    this.acceptedInsurances = const [],
    this.nylasConnected = false,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.baseToMap();
    userMap.addAll({
      'professional_title': professionalTitle,
      'med_school': medSchool,
      'med_residency': medResidency,
      'med_license': medLicense,
      'state_issued': medLicenseState,
      'npi': npi,
      'board_certified': boardCertified,
      'provider_bio': providerBio,
      'practice_name': practiceName,
      'stripe_connect_authorized': stripeConnectAuthorized,
      'selected_services': selectedServices,
      'assistant_email': assistantEmail,
      'accepted_insurances': acceptedInsurances,
      'nylas_connected': nylasConnected,
    });
    return userMap;
  }

  static ProviderUser fromMap(String uid, Map<String, dynamic> data) {
    ProviderUser provider = ProviderUser();
    provider.professionalTitle =
        data['professional_title'] ?? provider.professionalTitle;
    provider.medSchool = data['med_school'] ?? provider.medSchool;
    provider.medResidency = data['med_residency'] ?? provider.medResidency;
    provider.medLicense = data['med_license'] ?? provider.medLicense;
    provider.npi = data['npi'] ?? provider.npi;
    provider.boardCertified =
        data['board_certified'] ?? provider.boardCertified;
    provider.providerBio = data['provider_bio'] ?? provider.providerBio;
    provider.medLicenseState = data['state_issued'] ?? provider.medLicenseState;
    provider.practiceName = data['practice_name'] ?? provider.practiceName;
    provider.stripeConnectAuthorized =
        data['stripe_connect_authorized'] ?? provider.stripeConnectAuthorized;
    if (data['selected_services'] != null) {
      provider.selectedServices =
          (data['selected_services'] as List).map((e) => e.toString()).toList();
    }
    if (data['accepted_insurances'] != null) {
      provider.acceptedInsurances = (data['accepted_insurances'] as List)
          .map((e) => e.toString())
          .toList();
    }
    provider.assistantEmail =
        data['assistant_email'] ?? provider.assistantEmail;
    provider.nylasConnected =
        data['nylas_connected'] ?? provider.nylasConnected;

    return provider;
  }
}
