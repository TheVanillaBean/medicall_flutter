import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/secrets.dart' as secrets;
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey<FormBuilderState> _userRegKey = GlobalKey<FormBuilderState>();
  final TextEditingController _typeAheadController = TextEditingController();

  var data;
  bool autoValidate = true;
  bool readOnly = false;
  List<dynamic> _addressList = [];
  double formSpacing = 20;
  bool showSegmentedControl = true;
  FirebaseUser firebaseUser;
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
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: medicallUser.type.length > 0
            ? Text(
                '${medicallUser.type != null ? medicallUser.type[0].toUpperCase() : ''}${medicallUser.type != null ? medicallUser.type.substring(1) : ''}' +
                    ' Registration')
            : Container(),
      ),
      bottomNavigationBar: FlatButton(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        onPressed: () {
          if (!this._addressList.contains(this._typeAheadController.text)) {
            this._typeAheadController.clear();
          }

          bool successfullySaveForm =
              _userRegKey.currentState.saveAndValidate();
          if (successfullySaveForm) {
            updateUserWithFormData(tempUserProvider);
            Navigator.of(context).pushReplacementNamed("/photoID");
          } else {
            PlatformAlertDialog(
              title: 'Registration failed',
              defaultActionText: "Okay",
              content: "An error occured processing your information.",
            ).show(context);
          }
        }, // Switch tabs

        child: Text(
          'CONTINUE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: FormBuilder(
            key: _userRegKey,
            autovalidate: false,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FormBuilderTextField(
                        attribute: "First name",
                        initialValue: medicallUser.firstName,
                        readOnly: false,
                        decoration: InputDecoration(
                            labelText: 'First Name',
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: FormBuilderTextField(
                        attribute: "Last name",
                        initialValue: medicallUser.lastName,
                        readOnly: false,
                        decoration: InputDecoration(
                            labelText: 'Last Name',
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                FormBuilderDateTimePicker(
                  attribute: "Date of birth",
                  inputType: InputType.date,
                  initialDatePickerMode: DatePickerMode.year,
                  initialDate: DateTime.utc(DateTime.now().year - 19, 1, 1),
                  format: DateFormat("MM-dd-yyyy"),
                  decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                medicallUser.type == "provider"
                    ? Column(
                        children: <Widget>[
                          FormBuilderTextField(
                            attribute: "Medical Titles",
                            initialValue: medicallUser.titles,
                            decoration: InputDecoration(
                                labelText: 'Medical Titles',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FormBuilderTextField(
                            attribute: "NPI Number",
                            initialValue: medicallUser.npi,
                            decoration: InputDecoration(
                                labelText: 'NPI Number',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FormBuilderTextField(
                            attribute: "License Number",
                            initialValue: medicallUser.medLicense,
                            decoration: InputDecoration(
                                labelText: 'License Number',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          FormBuilderDropdown(
                            attribute: "State Issued",
                            isDense: true,
                            decoration: InputDecoration(
                                labelText: 'State Issued',
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                            items: states
                                .map((state) => DropdownMenuItem(
                                      value: state,
                                      child: Text('$state'),
                                    ))
                                .toList(),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 5,
                      ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 15, 10, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Please select your gender below,',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FormBuilderRadio(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          isDense: true,
                          focusedBorder: InputBorder.none),
                      attribute: "Gender",
                      leadingInput: true,
                      options: [
                        FormBuilderFieldOption(
                          value: 'Male',
                        ),
                        FormBuilderFieldOption(
                          value: 'Female',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
                  attribute: "Email",
                  initialValue: medicallUser.email,
                  readOnly: auth.isGoogleUser,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: !auth.isGoogleUser,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required(),
                  ],
                ),
                !auth.isGoogleUser
                    ? SizedBox(
                        height: formSpacing,
                      )
                    : Container(),
                !auth.isGoogleUser
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
                !auth.isGoogleUser
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
                !auth.isGoogleUser
                    ? SizedBox(
                        height: formSpacing,
                      )
                    : Container(),
                TypeAheadFormField(
                  hideOnEmpty: true,
                  suggestionsBoxVerticalOffset: 5.0,
                  hideOnError: true,
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  textFieldConfiguration: TextFieldConfiguration(
                    onEditingComplete: () {
                      if (_addressList.length == 0) {
                        this._typeAheadController.clear();
                      }
                    },
                    onSubmitted: (v) {
                      if (_addressList.length == 0) {
                        this._typeAheadController.clear();
                      }
                      if (_addressList.indexOf(v) == -1) {
                        this._typeAheadController.clear();
                      }
                    },
                    controller: this._typeAheadController,
                    decoration: InputDecoration(
                        labelText: 'Street Address',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none),
                  ),
                  suggestionsCallback: (pattern) async {
                    _addressList = [];
                    if (pattern.length > 0) {
                      final PlacesSearchResponse response =
                          await _places.searchByText(pattern);
                      _addressList.add(response.results.first.formattedAddress);
                      return _addressList;
                    } else {
                      return _addressList;
                    }
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  onSuggestionSelected: (suggestion) {
                    medicallUser.address = suggestion;
                    this._typeAheadController.text = suggestion;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter valid address';
                    } else {
                      if (_addressList.indexOf(value) == -1) {
                        this._typeAheadController.clear();
                      } else {
                        medicallUser.address = value;
                      }
                      return null;
                    }
                  },
                  onSaved: (value) => medicallUser.address = value,
                ),
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
                  label: FlatButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 62, 0),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/terms');
                      },
                      child: Text('Terms & Conditions',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ))),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                FormBuilderCheckbox(
                  attribute: 'accept_privacy_switch',
                  initialValue: medicallUser.policy,
                  leadingInput: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  label: FlatButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 62, 0),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/privacy');
                      },
                      child: Text('Privacy Policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ))),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateUserWithFormData(TempUserProvider tempUserProvider) {
    tempUserProvider.updateWith(firstName: this.firstName);
    tempUserProvider.updateWith(lastName: this.lastName);
    tempUserProvider.updateWith(displayName: this.displayName);
    tempUserProvider.updateWith(password: this.password);
    tempUserProvider.updateWith(dob: this.dob);
    tempUserProvider.updateWith(gender: this.gender);
    tempUserProvider.updateWith(email: this.email);
    tempUserProvider.updateWith(terms: this.terms);
    tempUserProvider.updateWith(policy: this.policy);
    tempUserProvider.updateWith(consent: this.consent);
    if (tempUserProvider.medicallUser.type == 'provider') {
      tempUserProvider.updateWith(titles: this.titles);
      tempUserProvider.updateWith(npi: this.npi);
      tempUserProvider.updateWith(medLicense: this.medLicense);
      tempUserProvider.updateWith(medLicenseState: this.medLicenseState);
    }
    tempUserProvider.updateWith(address: this.address);
  }

  String get displayName {
    return firstName + ' ' + lastName;
  }

  String get firstName {
    return _userRegKey.currentState.value['First name'];
  }

  String get lastName {
    return _userRegKey.currentState.value['Last name'];
  }

  String get password {
    return _userRegKey.currentState.value['Password'];
  }

  String get dob {
    return DateFormat('MM-dd-yyyy')
        .format(_userRegKey.currentState.value['Date of birth'])
        .toString();
  }

  String get gender {
    return _userRegKey.currentState.value['Gender'];
  }

  String get email {
    return _userRegKey.currentState.value['Email'];
  }

  bool get terms {
    return _userRegKey.currentState.value['Terms and conditions'];
  }

  bool get policy {
    return _userRegKey.currentState.value['accept_privacy_switch'];
  }

  bool get consent {
    return _userRegKey.currentState.value['accept_consent'];
  }

  String get titles {
    return _userRegKey.currentState.value['Medical Titles'];
  }

  String get npi {
    return _userRegKey.currentState.value['NPI Number'];
  }

  String get medLicense {
    return _userRegKey.currentState.value['License Number'];
  }

  String get medLicenseState {
    return _userRegKey.currentState.value['State Issued'];
  }

  String get address {
    return _typeAheadController.text;
  }
}
