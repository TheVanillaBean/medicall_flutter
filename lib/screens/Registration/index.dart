import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/secrets.dart' as secrets;
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: secrets.kGoogleApiKey);

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  static final GlobalKey<FormBuilderState> _userRegKey =
      GlobalKey<FormBuilderState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final phoneAuth = PhoneAuthStateModel(auth: Auth(), userRegKey: _userRegKey);
  var data;
  bool autoValidate = true;
  bool readOnly = false;
  List<dynamic> _addressList = [];
  double formSpacing = 20;
  bool showSegmentedControl = true;
  List<String> states = [
    'Alabama',
    'Alaska',
    'American Samoa',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'District of Columbia',
    'Florida',
    'Georgia',
    'Guam',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Minor Outlying Islands',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Northern Mariana Islands',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Puerto Rico',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'U.S. Virgin Islands',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    this._typeAheadController.dispose();
  }

  getNearbyPlaces(addresses) async {
    var placesList = [];

    for (var i = 0; i < addresses.length; i++) {
      placesList.add(await _places.searchByText(addresses[i]));
      if (placesList[i].status == 'OK') {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempUserProvider = Provider.of<TempUserProvider>(context);
    final medicallUser = tempUserProvider.medicallUser;
    medicallUser.type = 'patient';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: medicallUser.type.length > 0
            ? Text(
                '${medicallUser.type != null ? medicallUser.type[0].toUpperCase() : ''}${medicallUser.type != null ? medicallUser.type.substring(1) : ''}' +
                    ' Registration')
            : Text(
                'Protect your visit Information',
              ),
      ),
      // bottomNavigationBar: FlatButton(
      //   color: Theme.of(context).colorScheme.primary,
      //   padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
      //   onPressed: () {
      //     if (!this._addressList.contains(this._typeAheadController.text)) {
      //       this._typeAheadController.clear();
      //     }
      //     bool successfullySaveForm =
      //         _userRegKey.currentState.saveAndValidate();
      //     if (successfullySaveForm &&
      //         _userRegKey.currentState.value['Terms and conditions'] &&
      //         _userRegKey.currentState.value['accept_privacy_switch']) {
      //       updateUserWithFormData(tempUserProvider);
      //       Navigator.of(context).pushNamed("/photoID");
      //     } else {
      //       if (!_userRegKey.currentState.value['Terms and conditions']) {
      //         AppUtil().showFlushBar(
      //             'Please accept the "Terms & Conditions" to continue.',
      //             context);
      //       }
      //       if (!_userRegKey.currentState.value['accept_privacy_switch']) {
      //         AppUtil().showFlushBar(
      //             'Please accept the "Privacy Policy" to continue.', context);
      //       }
      //     }
      //   }, // Switch tabs

      //   child: Text(
      //     'CONTINUE',
      //     style: TextStyle(
      //       color: Theme.of(context).colorScheme.onPrimary,
      //       letterSpacing: 2,
      //     ),
      //   ),
      // ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: FormBuilder(
            key: _userRegKey,
            autovalidate: false,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  attribute: "Email",
                  initialValue: medicallUser.email,
                  readOnly: tempUserProvider.googleAuthModel != null ||
                          tempUserProvider.appleSignInModel != null
                      ? true
                      : false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: tempUserProvider.googleAuthModel != null ||
                              tempUserProvider.appleSignInModel != null
                          ? false
                          : true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required(),
                  ],
                ),
                tempUserProvider.googleAuthModel == null &&
                        tempUserProvider.appleSignInModel == null
                    ? SizedBox(
                        height: formSpacing,
                      )
                    : Container(),
                tempUserProvider.googleAuthModel == null &&
                        tempUserProvider.appleSignInModel == null
                    ? FormBuilderTextField(
                        attribute: "Password",
                        initialValue: "",
                        maxLines: 1,
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText:
                                'Must be 8 characters or more and have at least one uppercase, a lowercase, a number, special character \(\!\@\#\$\&\*\~\)',
                            hintMaxLines: 2,
                            errorMaxLines: 2,
                            hintStyle: TextStyle(fontSize: 12),
                            labelText: 'Password',
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.min(8),
                          FormBuilderValidators.pattern(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                              errorText:
                                  'Requires at least one uppercase, a lowercase, a number, special character \(\!\@\#\$\&\*\~\)'),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 5,
                ),
                tempUserProvider.googleAuthModel == null &&
                        tempUserProvider.appleSignInModel == null
                    ? FormBuilderTextField(
                        attribute: "ConfirmPassword",
                        initialValue: "",
                        maxLines: 1,
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: 'Must match your password exactly',
                            hintStyle: TextStyle(fontSize: 12),
                            labelText: 'Confirm Password',
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                          (val) {
                            var _passW = _userRegKey.currentState
                                .fields['Password'].currentState.value;
                            if (val == _passW)
                              return null;
                            else
                              return "What you entered is not matching your password";
                          },
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 10.0,
                ),
                FormBuilderCheckbox(
                  attribute: 'Terms and conditions',
                  initialValue: medicallUser.terms,
                  leadingInput: true,
                  decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  label: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('I agree to Medicall’s'),
                          GestureDetector(
                              onTap: () {
                                tempUserProvider.medicallUser.consent = true;
                                tempUserProvider.medicallUser.policy = true;
                                Navigator.of(context).pushNamed('/terms');
                              },
                              child: Text('Terms & Privacy Policy',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ))),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('I have reviewed the'),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('/privacy');
                              },
                              child: Text('Privacy Policy',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ))),
                          Text('and understand'),
                        ],
                      ),
                      Text('the benefits and risks of remote treatment.')
                    ],
                  ),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                Container(
                  child: PhoneAuthScreen.create(context, _userRegKey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get displayName {
    return firstName + ' ' + lastName;
  }

  String get firstName {
    return _userRegKey.currentState.value['First name'].toString().trim();
  }

  String get lastName {
    return _userRegKey.currentState.value['Last name'].toString().trim();
  }

  String get gender {
    return _userRegKey.currentState.value['Gender'];
  }

  String get titles {
    return _userRegKey.currentState.value['Medical Titles'].toString().trim();
  }

  String get npi {
    return _userRegKey.currentState.value['NPI Number'].toString().trim();
  }

  String get medLicense {
    return _userRegKey.currentState.value['License Number'].toString().trim();
  }

  String get medLicenseState {
    return _userRegKey.currentState.value['State Issued'];
  }

  String get address {
    return _typeAheadController.text;
  }
}
