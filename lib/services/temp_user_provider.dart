import 'package:Medicall/models/medicall_user_model.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TempUserProvider {
  MedicallUser _medicallUser;
  List<Asset> _images;

  MedicallUser get medicallUser {
    return _medicallUser;
  }

  TempUserProvider() {
    _medicallUser = MedicallUser();
  }

  void updateWith({
    String userType,
    String displayName,
    String firstName,
    String lastName,
    String dob,
    String gender,
    String email,
    bool terms,
    bool policy,
    bool consent,
    String titles,
    String npi,
    String medLicense,
    String medLicenseState,
    String address,
    List<Asset> images,
  }) {
    this._medicallUser.type = userType ?? this._medicallUser.type;
    this._medicallUser.displayName =
        displayName ?? this._medicallUser.displayName;
    this._medicallUser.firstName = firstName ?? this._medicallUser.firstName;
    this._medicallUser.lastName = lastName ?? this._medicallUser.lastName;
    this._medicallUser.dob = dob ?? this._medicallUser.dob;
    this._medicallUser.gender = gender ?? this._medicallUser.gender;
    this._medicallUser.email = email ?? this._medicallUser.email;
    this._medicallUser.terms = terms ?? this._medicallUser.terms;
    this._medicallUser.policy = policy ?? this._medicallUser.policy;
    this._medicallUser.consent = consent ?? this._medicallUser.consent;
    this._medicallUser.titles = titles ?? this._medicallUser.titles;
    this._medicallUser.npi = npi ?? this._medicallUser.npi;
    this._medicallUser.medLicense = medLicense ?? this._medicallUser.medLicense;
    this._medicallUser.medLicenseState =
        medLicenseState ?? this._medicallUser.medLicenseState;
    this._medicallUser.address = address ?? this._medicallUser.address;
    this._images = images ?? this._images;
  }
}
