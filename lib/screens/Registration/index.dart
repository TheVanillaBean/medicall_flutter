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
  final GlobalKey<FormBuilderState> _userRegKey = GlobalKey<FormBuilderState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final phoneAuth = PhoneAuthStateModel(auth: Auth());
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Expanded(
                //       child: FormBuilderTextField(
                //         attribute: "First name",
                //         initialValue: medicallUser.firstName,
                //         readOnly: false,
                //         decoration: InputDecoration(
                //             labelText: 'First Name',
                //             fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //             filled: true,
                //             disabledBorder: InputBorder.none,
                //             enabledBorder: InputBorder.none,
                //             border: InputBorder.none),
                //         validators: [
                //           FormBuilderValidators.required(),
                //         ],
                //       ),
                //     ),
                //     SizedBox(
                //       width: 5,
                //     ),
                //     Expanded(
                //       child: FormBuilderTextField(
                //         attribute: "Last name",
                //         initialValue: medicallUser.lastName,
                //         readOnly: false,
                //         decoration: InputDecoration(
                //             labelText: 'Last Name',
                //             fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //             filled: true,
                //             disabledBorder: InputBorder.none,
                //             enabledBorder: InputBorder.none,
                //             border: InputBorder.none),
                //         validators: [
                //           FormBuilderValidators.required(),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // FormBuilderCustomField(
                //   attribute: "Date of birth",
                //   formField: FormField(
                //     builder: (context) {
                //       return Row(
                //         children: <Widget>[
                //           Expanded(
                //             child: FlatButton(
                //                 padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                //                 color: Color.fromRGBO(35, 179, 232, 0.1),
                //                 onPressed: () {
                //                   DatePicker.showDatePicker(this.context,
                //                       showTitleActions: true,
                //                       minTime: DateTime(1900, 1, 1),
                //                       maxTime: DateTime(2001, 6, 7),
                //                       onChanged: (date) {}, onConfirm: (date) {
                //                     tempUserProvider.updateWith(
                //                         dob: DateFormat('MM-dd-yyyy')
                //                             .format(date)
                //                             .toString());
                //                     setState(() {});
                //                   },
                //                       currentTime: DateTime.now(),
                //                       locale: LocaleType.en);
                //                 },
                //                 child: Text(
                //                   tempUserProvider.medicallUser.dob == null ||
                //                           tempUserProvider
                //                                   .medicallUser.dob.length ==
                //                               0
                //                       ? 'Date of Birth'
                //                       : tempUserProvider.medicallUser.dob,
                //                   style: TextStyle(fontSize: 16),
                //                 )),
                //           ),
                //         ],
                //       );
                //     },
                //   ),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                // medicallUser.type == "provider"
                //     ? Column(
                //         children: <Widget>[
                //           FormBuilderTextField(
                //             attribute: "Medical Titles",
                //             initialValue: medicallUser.titles,
                //             decoration: InputDecoration(
                //                 labelText: 'Medical Titles',
                //                 fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //                 filled: true,
                //                 disabledBorder: InputBorder.none,
                //                 enabledBorder: InputBorder.none,
                //                 border: InputBorder.none),
                //             validators: [
                //               FormBuilderValidators.required(),
                //             ],
                //           ),
                //           SizedBox(
                //             height: 5,
                //           ),
                //           FormBuilderTextField(
                //             attribute: "NPI Number",
                //             initialValue: medicallUser.npi,
                //             decoration: InputDecoration(
                //                 labelText: 'NPI Number',
                //                 fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //                 filled: true,
                //                 disabledBorder: InputBorder.none,
                //                 enabledBorder: InputBorder.none,
                //                 border: InputBorder.none),
                //             validators: [
                //               FormBuilderValidators.required(),
                //             ],
                //           ),
                //           SizedBox(
                //             height: 5,
                //           ),
                //           FormBuilderTextField(
                //             attribute: "License Number",
                //             initialValue: medicallUser.medLicense,
                //             decoration: InputDecoration(
                //                 labelText: 'License Number',
                //                 fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //                 filled: true,
                //                 disabledBorder: InputBorder.none,
                //                 enabledBorder: InputBorder.none,
                //                 border: InputBorder.none),
                //             validators: [
                //               FormBuilderValidators.required(),
                //             ],
                //           ),
                //           SizedBox(
                //             height: 5,
                //           ),
                //           FormBuilderDropdown(
                //             attribute: "State Issued",
                //             isDense: true,
                //             decoration: InputDecoration(
                //                 labelText: 'State Issued',
                //                 fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //                 filled: true,
                //                 disabledBorder: InputBorder.none,
                //                 enabledBorder: InputBorder.none,
                //                 border: InputBorder.none),
                //             validators: [
                //               FormBuilderValidators.required(),
                //             ],
                //             items: states
                //                 .map(
                //                   (state) => DropdownMenuItem(
                //                     value: state,
                //                     child: Text('$state'),
                //                   ),
                //                 )
                //                 .toList(),
                //           ),
                //         ],
                //       )
                //     : SizedBox(
                //         height: 5,
                //       ),
                // Column(
                //   children: <Widget>[
                //     Padding(
                //       padding: EdgeInsets.fromLTRB(3, 15, 10, 0),
                //       child: Row(
                //         children: <Widget>[
                //           Expanded(
                //             child: Text(
                //               'Please select your gender below,',
                //               textAlign: TextAlign.left,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //     FormBuilderRadio(
                //       decoration: InputDecoration(
                //           border: InputBorder.none,
                //           enabledBorder: InputBorder.none,
                //           isDense: true,
                //           focusedBorder: InputBorder.none),
                //       attribute: "Gender",
                //       leadingInput: true,
                //       options: [
                //         FormBuilderFieldOption(
                //           value: 'Male',
                //         ),
                //         FormBuilderFieldOption(
                //           value: 'Female',
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: formSpacing,
                // ),
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
                // tempUserProvider.googleAuthModel == null &&
                //         tempUserProvider.appleSignInModel == null
                //     ? SizedBox(
                //         height: formSpacing,
                //       )
                //     : Container(),
                // TypeAheadFormField(
                //   hideOnEmpty: true,
                //   suggestionsBoxVerticalOffset: 1.0,
                //   hideOnError: true,
                //   suggestionsBoxDecoration: SuggestionsBoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.all(Radius.circular(5)),
                //   ),
                //   textFieldConfiguration: TextFieldConfiguration(
                //     onEditingComplete: () {
                //       if (_addressList.length == 0) {
                //         this._typeAheadController.clear();
                //       }
                //     },
                //     onSubmitted: (v) {
                //       if (_addressList.length == 0) {
                //         this._typeAheadController.clear();
                //       }
                //       if (_addressList.indexOf(v) == -1) {
                //         this._typeAheadController.clear();
                //       }
                //     },
                //     controller: this._typeAheadController,
                //     decoration: InputDecoration(
                //         labelText:
                //             tempUserProvider.medicallUser.type == 'provider'
                //                 ? 'Health Practice Address'
                //                 : 'Street Address',
                //         fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                //         filled: true,
                //         disabledBorder: InputBorder.none,
                //         enabledBorder: InputBorder.none,
                //         border: InputBorder.none),
                //   ),
                //   suggestionsCallback: (pattern) async {
                //     _addressList = [];
                //     if (pattern.length > 0) {
                //       final PlacesSearchResponse response =
                //           await _places.searchByText(pattern);
                //       _addressList.add(response.results.first.formattedAddress);
                //       return _addressList;
                //     } else {
                //       return _addressList;
                //     }
                //   },
                //   itemBuilder: (context, suggestion) {
                //     return ListTile(
                //       title: Text(suggestion),
                //     );
                //   },
                //   transitionBuilder: (context, suggestionsBox, controller) {
                //     return suggestionsBox;
                //   },
                //   onSuggestionSelected: (suggestion) {
                //     medicallUser.address = suggestion;
                //     this._typeAheadController.text = suggestion;
                //   },
                //   validator: (value) {
                //     if (value.isEmpty) {
                //       return 'Please enter valid address';
                //     } else {
                //       if (_addressList.indexOf(value) == -1) {
                //         this._typeAheadController.clear();
                //       } else {
                //         medicallUser.address = value;
                //       }
                //       return null;
                //     }
                //   },
                //   onSaved: (value) => medicallUser.address = value,
                // ),
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
