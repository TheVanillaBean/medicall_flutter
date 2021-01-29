import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class EnterInsuranceViewModel with EmailAndPasswordValidators, ChangeNotifier {
  final AuthBase auth;
  final NonAuthDatabase nonAuthDatabase;
  final Symptom symptom;
  final TempUserProvider tempUserProvider;

  bool showEmailField;
  String email;
  String zipcode;
  bool isLoading;

  bool showInsuranceWidgets;
  String insurance;
  int selectedItemIndex;
  List<String> insuranceOptions = [
    'Proceed without insurance',
    'Aetna',
    'AllWays Health Plan',
    'Blue Cross and Blue Shield of Massachusetts',
    'Cigna',
    'Fallon Community Health Plan',
    'Harvard Pilgrim Health Care',
    'Health Plans Inc.',
    'Humana',
    'Medicare',
    'Tufts Health Plan',
    'UnitedHealthcare',
    'AARP Medicare Replacement',
  ];

  bool waiverCheck;

  EnterInsuranceViewModel({
    @required this.nonAuthDatabase,
    @required this.symptom,
    @required this.auth,
    @required this.tempUserProvider,
    this.showEmailField = false,
    this.email = '',
    this.zipcode = '',
    this.isLoading = false,
    this.waiverCheck = false,
    this.insurance = '',
    this.selectedItemIndex = 0,
    this.showInsuranceWidgets = false,
  });

  String get emailErrorText {
    bool showErrorText = isLoading && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : "";
  }

  void updateEmail(String email) => updateWith(email: email);
  void updateZipcode(String zipcode) => updateWith(zipcode: zipcode);

  Future<void> addEmailToWaitList() async {
    updateWith(isLoading: true);

    try {
      String state = getState();
      if (state == null || state == "none") {
        throw PlatformException(
            code: 'ERROR', message: 'Please enter a valid zipcode');
      }
      String alreadyInArea = await this.areProvidersInArea(zipcode);
      if (alreadyInArea != null) {
        this.updateWith(showEmailField: false);
        throw PlatformException(
            code: 'ERROR', message: 'We are already in your area :)');
      }
      bool emailAlreadyUsed = await auth.emailAlreadyUsed(email: this.email);
      if (!emailAlreadyUsed) {
        await nonAuthDatabase.addEmailToWaitList(email: email, state: state);
        updateWith(isLoading: false);
      } else {
        throw PlatformException(
            code: 'AUTH_ERROR',
            message: 'This email address has already been used.');
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future<String> validateZipCodeAndInsurance() async {
    String state = await this.areProvidersInArea(this.zipcode);
    if (state != null) {
      if (showInsuranceWidgets && waiverCheck) {
        this.tempUserProvider.setUser(userType: USER_TYPE.PATIENT);
        this.tempUserProvider.user.mailingZipCode = this.zipcode;
        this.tempUserProvider.user.mailingState = state;
        return state;
      }
      this.updateWith(showEmailField: false);
    } else {
      this.updateWith(showEmailField: true, showInsuranceWidgets: false);
    }
    return null;
  }

  String getState() {
    // Ensure we don't parse strings starting with 0 as octal values
    int thisZip = int.tryParse(this.zipcode);

    if (thisZip == null) return null;

    String st;

    // Code blocks alphabetized by state
    if (thisZip >= 35000 && thisZip <= 36999) {
      st = 'AL';
    } else if (thisZip >= 99500 && thisZip <= 99999) {
      st = 'AK';
    } else if (thisZip >= 85000 && thisZip <= 86999) {
      st = 'AZ';
    } else if (thisZip >= 71600 && thisZip <= 72999) {
      st = 'AR';
    } else if (thisZip >= 90000 && thisZip <= 96699) {
      st = 'CA';
    } else if (thisZip >= 80000 && thisZip <= 81999) {
      st = 'CO';
    } else if (thisZip >= 6000 && thisZip <= 6999) {
      st = 'CT';
    } else if (thisZip >= 19700 && thisZip <= 19999) {
      st = 'DE';
    } else if (thisZip >= 32000 && thisZip <= 34999) {
      st = 'FL';
    } else if (thisZip >= 30000 && thisZip <= 31999) {
      st = 'GA';
    } else if (thisZip >= 96700 && thisZip <= 96999) {
      st = 'HI';
    } else if (thisZip >= 83200 && thisZip <= 83999) {
      st = 'ID';
    } else if (thisZip >= 60000 && thisZip <= 62999) {
      st = 'IL';
    } else if (thisZip >= 46000 && thisZip <= 47999) {
      st = 'IN';
    } else if (thisZip >= 50000 && thisZip <= 52999) {
      st = 'IA';
    } else if (thisZip >= 66000 && thisZip <= 67999) {
      st = 'KS';
    } else if (thisZip >= 40000 && thisZip <= 42999) {
      st = 'KY';
    } else if (thisZip >= 70000 && thisZip <= 71599) {
      st = 'LA';
    } else if (thisZip >= 3900 && thisZip <= 4999) {
      st = 'ME';
    } else if (thisZip >= 20600 && thisZip <= 21999) {
      st = 'MD';
    } else if (thisZip >= 1000 && thisZip <= 2799) {
      st = 'MA';
    } else if (thisZip >= 48000 && thisZip <= 49999) {
      st = 'MI';
    } else if (thisZip >= 55000 && thisZip <= 56999) {
      st = 'MN';
    } else if (thisZip >= 38600 && thisZip <= 39999) {
      st = 'MS';
    } else if (thisZip >= 63000 && thisZip <= 65999) {
      st = 'MO';
    } else if (thisZip >= 59000 && thisZip <= 59999) {
      st = 'MT';
    } else if (thisZip >= 27000 && thisZip <= 28999) {
      st = 'NC';
    } else if (thisZip >= 58000 && thisZip <= 58999) {
      st = 'ND';
    } else if (thisZip >= 68000 && thisZip <= 69999) {
      st = 'NE';
    } else if (thisZip >= 88900 && thisZip <= 89999) {
      st = 'NV';
    } else if (thisZip >= 3000 && thisZip <= 3899) {
      st = 'NH';
    } else if (thisZip >= 7000 && thisZip <= 8999) {
      st = 'NJ';
    } else if (thisZip >= 87000 && thisZip <= 88499) {
      st = 'NM';
    } else if (thisZip >= 10000 && thisZip <= 14999) {
      st = 'NY';
    } else if (thisZip >= 43000 && thisZip <= 45999) {
      st = 'OH';
    } else if (thisZip >= 73000 && thisZip <= 74999) {
      st = 'OK';
    } else if (thisZip >= 97000 && thisZip <= 97999) {
      st = 'OR';
    } else if (thisZip >= 15000 && thisZip <= 19699) {
      st = 'PA';
    } else if (thisZip >= 300 && thisZip <= 999) {
      st = 'PR';
    } else if (thisZip >= 2800 && thisZip <= 2999) {
      st = 'RI';
    } else if (thisZip >= 29000 && thisZip <= 29999) {
      st = 'SC';
    } else if (thisZip >= 57000 && thisZip <= 57999) {
      st = 'SD';
    } else if (thisZip >= 37000 && thisZip <= 38599) {
      st = 'TN';
    } else if ((thisZip >= 75000 && thisZip <= 79999) ||
        (thisZip >= 88500 && thisZip <= 88599)) {
      st = 'TX';
    } else if (thisZip >= 84000 && thisZip <= 84999) {
      st = 'UT';
    } else if (thisZip >= 5000 && thisZip <= 5999) {
      st = 'VT';
    } else if (thisZip >= 22000 && thisZip <= 24699) {
      st = 'VA';
    } else if (thisZip >= 20000 && thisZip <= 20599) {
      st = 'DC';
    } else if (thisZip >= 98000 && thisZip <= 99499) {
      st = 'WA';
    } else if (thisZip >= 24700 && thisZip <= 26999) {
      st = 'WV';
    } else if (thisZip >= 53000 && thisZip <= 54999) {
      st = 'WI';
    } else if (thisZip >= 82000 && thisZip <= 83199) {
      st = 'WY';
    } else {
      st = 'none';
    }

    return st;
  }

  Future<String> areProvidersInArea(String zipCode) async {
    List<String> states = await nonAuthDatabase.getAllProviderStates();

    for (var state in states) {
      String enteredState = getState();
      if (state == enteredState) {
        updateWith(showInsuranceWidgets: true);
        return state;
      }
    }

    updateWith(showInsuranceWidgets: false);
    return null;
  }

  void updateWith({
    bool showEmailField,
    String email,
    String zipcode,
    bool isLoading,
    bool showInsuranceWidgets,
    int selectedItemIndex,
    bool waiverCheck,
    bool zipCodeFieldEnabled,
  }) {
    this.showEmailField = showEmailField ?? this.showEmailField;
    this.email = email ?? this.email;
    this.zipcode = zipcode ?? this.zipcode;
    this.isLoading = isLoading ?? this.isLoading;
    this.selectedItemIndex = selectedItemIndex ?? this.selectedItemIndex;
    this.insurance = this.insuranceOptions[this.selectedItemIndex];
    this.showInsuranceWidgets =
        showInsuranceWidgets ?? this.showInsuranceWidgets;
    this.waiverCheck = waiverCheck ?? this.waiverCheck;
    notifyListeners();
  }
}
