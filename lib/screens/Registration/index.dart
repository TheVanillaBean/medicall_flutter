import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/reg_user_model.dart';
import 'package:Medicall/screens/Registration/photoIdScreen.dart';
import 'package:Medicall/secrets.dart' as secrets;
import 'package:Medicall/services/auth.dart';
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
  const RegistrationScreen({Key key}) : super(key: key);
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
    var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
    medicallUser = auth.medicallUser;
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
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
            print('validationSucceded');
            //print(_userRegKey.currentState.value);
            //_signUp();
            auth.tempRegUser = TempRegUser();
            auth.tempRegUser.username = _userRegKey.currentState.value['Email'];
            auth.tempRegUser.pass = _userRegKey.currentState.value['Password'];
            medicallUser = auth.medicallUser;
            medicallUser.displayName =
                _userRegKey.currentState.value['First name'] +
                    ' ' +
                    _userRegKey.currentState.value['Last name'];
            medicallUser.firstName =
                _userRegKey.currentState.value['First name'];
            medicallUser.lastName = _userRegKey.currentState.value['Last name'];
            medicallUser.dob = DateFormat('MM-dd-yyyy')
                .format(_userRegKey.currentState.value['Date of birth'])
                .toString();
            medicallUser.gender = _userRegKey.currentState.value['Gender'];
            medicallUser.email = _userRegKey.currentState.value['Email'];
            medicallUser.terms =
                _userRegKey.currentState.value['Terms and conditions'];
            medicallUser.policy =
                _userRegKey.currentState.value['accept_privacy_switch'];
            medicallUser.consent =
                _userRegKey.currentState.value['accept_consent'];
            if (medicallUser.type == 'provider') {
              medicallUser.titles =
                  _userRegKey.currentState.value['Medical Titles'];
              medicallUser.npi = _userRegKey.currentState.value['NPI Number'];
              medicallUser.medLicense =
                  _userRegKey.currentState.value['License Number'];
              medicallUser.medLicenseState =
                  _userRegKey.currentState.value['State Issued'];
            }
            medicallUser.address = _typeAheadController.text;
            GlobalNavigatorKey.key.currentState.push(
              MaterialPageRoute(builder: (context) => PhotoIdScreen()),
            );
          } else {
            print('External FormValidation failed');
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required(),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
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
                ),
                SizedBox(
                  height: 5,
                ),
                FormBuilderTextField(
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
                      var _passW = _userRegKey
                          .currentState.fields['Password'].currentState.value;
                      if (val == _passW)
                        return null;
                      else
                        return "What you entered is not matching your password";
                    },
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
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
                      return await _places.searchByText(pattern).then((val) {
                        _addressList.add(val.results.first.formattedAddress);
                        return _addressList;
                      });
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
                        GlobalNavigatorKey.key.currentState.pushNamed('/terms');
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
                        GlobalNavigatorKey.key.currentState
                            .pushNamed('/privacy');
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
}
