import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Auth/index.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_auth_codes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:Medicall/secrets.dart' as secrets;

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: secrets.kGoogleApiKey);

class RegistrationScreen extends StatefulWidget {
  final data;
  const RegistrationScreen({Key key, @required this.data}) : super(key: key);
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormBuilderState> _userRegKey = GlobalKey<FormBuilderState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final FirebaseAnonymouslyUtil firebaseAnonymouslyUtil =
      FirebaseAnonymouslyUtil();
  var data;
  bool autoValidate = true;
  bool _isLoading = false;
  bool readOnly = false;
  double formSpacing = 20;
  bool showSegmentedControl = true;
  FirebaseUser firebaseUser;
  DocumentReference documentReference = medicallUser.id != null
      ? Firestore.instance.document("users/" + medicallUser.id)
      : null;

  @override
  void initState() {
    medicallUser = widget.data['user'];
    super.initState();
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

  Future moveUserDashboardScreen(FirebaseUser currentUser) async {
    medicallUser.id = currentUser.uid;
    medicallUser.displayName = _userRegKey.currentState.value['First name'] +
        ' ' +
        _userRegKey.currentState.value['Last name'];
    medicallUser.firstName = _userRegKey.currentState.value['First name'];
    medicallUser.lastName = _userRegKey.currentState.value['Last name'];
    medicallUser.dob = DateFormat('MM-dd-yyyy')
        .format(_userRegKey.currentState.value['Date of birth'])
        .toString();
    medicallUser.gender = _userRegKey.currentState.value['Gender'];
    medicallUser.email = _userRegKey.currentState.value['Email'];
    medicallUser.terms = _userRegKey.currentState.value['Terms and conditions'];
    medicallUser.policy =
        _userRegKey.currentState.value['accept_privacy_switch'];
    medicallUser.consent = _userRegKey.currentState.value['accept_consent'];
    firebaseUser = currentUser;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            '${medicallUser.type != null ? medicallUser.type[0].toUpperCase() : ''}${medicallUser.type != null ? medicallUser.type.substring(1) : ''}' +
                ' Registration'),
      ),
      bottomNavigationBar: FlatButton(
        color: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        onPressed: () {
          _isLoading = true;
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
            print('validationSucceded');
            //print(_userRegKey.currentState.value);
            _signUp();
          } else {
            _isLoading = false;
            print('External FormValidation failed');
          }
        }, // Switch tabs

        child: !_isLoading
            ? Text(
                'SUBMIT',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  letterSpacing: 2,
                ),
              )
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                medicallUser.type == "provider"
                    ? Column(
                        children: <Widget>[
                          SizedBox(
                            height: formSpacing,
                          ),
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
                            height: formSpacing,
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 5,
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
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Must match your password exactly',
                      hintMaxLines: 2,
                      errorMaxLines: 2,
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
                    List<dynamic> _list = [];
                    if (pattern.length > 0) {
                      return await _places.searchByText(pattern).then((val) {
                        if (val.results.length == 0) {
                          this._typeAheadController.clear();
                        } else {
                          _list.add(val.results.first.formattedAddress);
                        }
                        return _list;
                      });
                    } else {
                      return _list;
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
                    this._typeAheadController.text = suggestion;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter valid address';
                    } else {
                      medicallUser.address = value;
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
                        Navigator.pushNamed(context, '/terms');
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
                        Navigator.pushNamed(context, '/privacy');
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
                FormBuilderCheckbox(
                  attribute: 'accept_consent',
                  initialValue: medicallUser.consent,
                  leadingInput: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  label: FlatButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 62, 0),
                      onPressed: () {
                        Navigator.pushNamed(context, '/consent');
                      },
                      child: Text('Telemedicine Consent',
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

  void _signUp() {
    setState(() {
      var _userN = _userRegKey.currentState.value['Email'];
      var _userP = _userRegKey.currentState.value['Password'];
      firebaseAnonymouslyUtil
          .createUser(_userN, _userP)
          .then((String user) => login(_userN, _userP))
          .catchError((e) => loginError(getErrorMessage(error: e)));
    });
  }

  login(String email, String pass) {
    firebaseAnonymouslyUtil
        .signIn(email, pass)
        .then((FirebaseUser user) => moveUserDashboardScreen(user))
        .catchError((e) => loginError(getErrorMessage(error: e)));
  }

  String getErrorMessage({dynamic error}) {
    _isLoading = false;
    if (error.code == FirebaseAuthCodes.ERROR_USER_NOT_FOUND) {
      return "A user with this email does not exist. Register first.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_DISABLED) {
      return "This user account has been disabled.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_TOKEN_EXPIRED) {
      return "A password change is in the process.";
    } else {
      return error.message;
    }
  }

  loginError(e) {
    setState(() {
      AppUtil().showAlert(e, 5);
    });
  }
}
