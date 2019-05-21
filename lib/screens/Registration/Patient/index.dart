import 'package:Medicall/models/medicall_user.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Medicall/globals.dart' as globals;
import 'package:intl/intl.dart';
//import 'package:localstorage/localstorage.dart';

class RegistrationPatientScreen extends StatefulWidget {
  final GoogleSignInAccount googleUser;
  final FirebaseUser firebaseUser;

  const RegistrationPatientScreen({Key key, this.googleUser, this.firebaseUser})
      : super(key: key);
  @override
  _RegistrationPatientScreenState createState() =>
      _RegistrationPatientScreenState();
}

class _RegistrationPatientScreenState extends State<RegistrationPatientScreen> {
  final GlobalKey<FormBuilderState> _userRegKey = GlobalKey<FormBuilderState>();
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  bool showSegmentedControl = true;
  Function _setTerms = () {
    medicallUser.terms = true;
  };
  Function _setPolicy = () {
    medicallUser.policy = true;
  };
  //final LocalStorage storage = LocalStorage('medicallStor');
  ValueChanged _onChanged = (val) => print(val);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    medicallUser = MedicallUser(
        firstName: globals.currentFirebaseUser.displayName.split(' ')[0],
        lastName: globals.currentFirebaseUser.displayName.split(' ')[1],
        email: globals.currentFirebaseUser.email,
        phoneNumber: globals.currentFirebaseUser.phoneNumber);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Patient Registration'),
      ),
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
            medicallUser.firstName =
                _userRegKey.currentState.value['First name'];
            medicallUser.lastName =
                _userRegKey.currentState.value['Last name'];
            medicallUser.email =
                _userRegKey.currentState.value['Email'];
            medicallUser.phoneNumber =
                _userRegKey.currentState.value['Phone'];
            medicallUser.dob = DateFormat('yyyy-MM-dd')
                .format(_userRegKey.currentState.value['Date of birth']);
            medicallUser.terms =
                _userRegKey.currentState.value['Terms and conditions'];
            medicallUser.policy =
                _userRegKey.currentState.value['accept_privacy_switch'];
            //storage.setItem('user', [].toJSONEncodable());
            //medicallUser data = storage.getItem('user');
            print('validationSucceded');
            print(_userRegKey.currentState.value);
            Navigator.pushNamed(context, '/doctors');
          } else {
            print('External FormValidation failed');
          }
        }, // Switch tabs

        child: Text(
          'SUBMIT',
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
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  attribute: "First name",
                  initialValue: medicallUser.firstName,
                  decoration: InputDecoration(
                      labelText: 'First Name',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  onChanged: _onChanged,
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
                  attribute: "Last name",
                  initialValue: medicallUser.lastName,
                  decoration: InputDecoration(
                      labelText: 'Last Name',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  onChanged: _onChanged,
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
                  attribute: "Email",
                  initialValue: medicallUser.email,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  onChanged: _onChanged,
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required(),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderDateTimePicker(
                  attribute: "Date of birth",
                  onChanged: _onChanged,
                  inputType: InputType.date,
                  format: DateFormat("yyyy-MM-dd"),
                  decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  readonly: false,
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderTextField(
                  attribute: "Phone",
                  initialValue: medicallUser.phoneNumber,
                  onChanged: _onChanged,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Phone Number',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    FormBuilderValidators.required(),
                  ],
                  readonly: false,
                ),
                SizedBox(
                  height: formSpacing,
                ),
                FormBuilderCheckbox(
                  attribute: 'Terms and conditions',
                  initialValue: false,
                  onChanged: _setTerms(),
                  leadingInput: true,
                  decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
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
                  initialValue: false,
                  onChanged: _setPolicy(),
                  leadingInput: true,
                  decoration: InputDecoration(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
