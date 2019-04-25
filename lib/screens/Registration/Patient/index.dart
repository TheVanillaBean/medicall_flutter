import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Medicall/globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

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
  GlobalKey<FormBuilderState> _userRegKey = GlobalKey();
  var data;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  final LocalStorage storage = new LocalStorage('medicallStor');
  @override
  Widget build(BuildContext context) {
    globals.medicallUser = globals.MedicallUser(
        firstName: globals.currentFirebaseUser.displayName.split(' ')[0],
        lastName: globals.currentFirebaseUser.displayName.split(' ')[1],
        email: globals.currentFirebaseUser.email,
        phoneNumber: globals.currentFirebaseUser.phoneNumber);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: Text('Patient Registration'),
        leading: new Text('', style: TextStyle(color: Colors.black26)),
      ),
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () {
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
            globals.medicallUser.firstName =
                _userRegKey.currentState.value['First name'];
            globals.medicallUser.lastName =
                _userRegKey.currentState.value['Last name'];
            globals.medicallUser.email =
                _userRegKey.currentState.value['Email'];
            globals.medicallUser.phoneNumber =
                _userRegKey.currentState.value['Phone'];
            globals.medicallUser.dob = DateFormat('yyyy-MM-dd')
                .format(_userRegKey.currentState.value['Date of birth']);
            globals.medicallUser.terms =
                _userRegKey.currentState.value['Terms and conditions'];
            globals.medicallUser.policy =
                _userRegKey.currentState.value['accept_privacy_switch'];
            //storage.setItem('user', [].toJSONEncodable());
            //globals.MedicallUser data = storage.getItem('user');
            print(data);
            print('validationSucceded');
            print(_userRegKey.currentState.value);
            Navigator.pushNamed(context, '/home');
          } else {
            print('External FormValidation failed');
          }
        }, // Switch tabs

        child: Text(
          'SUBMIT',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            children: <Widget>[
              FormBuilder(
                context,
                key: _userRegKey,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_TEXT,
                    attribute: 'First name',
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'First name is required';
                      }
                    },
                    decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixText: '    ',
                        suffixText: '    ',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        counterStyle:
                            TextStyle(color: Color.fromRGBO(241, 100, 119, 1))),
                    value: globals.medicallUser.firstName,
                    require: true,
                    min: 3,
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_TEXT,
                    attribute: 'spacer',
                    decoration: InputDecoration.collapsed(
                        hintText: '', enabled: false, border: InputBorder.none),
                    value: '',
                    validator: (value) {},
                    readonly: true,
                    require: false,
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_TEXT,
                    attribute: 'Last name',
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Last name is required';
                      }
                    },
                    decoration: InputDecoration(
                        prefixText: '    ',
                        suffixText: '    ',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        labelText: 'Last Name'),
                    value: globals.medicallUser.lastName,
                    require: true,
                    min: 3,
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_TEXT,
                    attribute: 'spacer',
                    decoration: InputDecoration.collapsed(
                        hintText: '', enabled: false, border: InputBorder.none),
                    value: '',
                    readonly: true,
                    validator: (value) {},
                    require: false,
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_EMAIL,
                    attribute: 'Email',
                    decoration: InputDecoration(
                      prefixText: '    ',
                      suffixText: '    ',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.1)),
                      ),
                      labelText: 'Email',
                    ),
                    require: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Last name is required';
                      }
                    },
                    value: globals.medicallUser.email,
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_TEXT,
                    attribute: 'spacer',
                    decoration: InputDecoration.collapsed(
                        hintText: '', enabled: false, border: InputBorder.none),
                    value: '',
                    validator: (value) {},
                    readonly: true,
                    require: false,
                  ),
                  FormBuilderInput.datePicker(
                    require: true,
                    decoration: InputDecoration(
                      prefixText: '    ',
                      suffixText: '    ',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.1)),
                      ),
                      labelText: 'Date of Birth',
                    ),
                    attribute: 'Date of birth',
                    validator: (value) {},
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_TEXT,
                    attribute: 'spacer',
                    decoration: InputDecoration.collapsed(
                        hintText: '', enabled: false, border: InputBorder.none),
                    value: '',
                    validator: (value) {},
                    readonly: true,
                    require: false,
                  ),
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_PHONE,
                    attribute: 'Phone',
                    require: true,
                    value: globals.medicallUser.phoneNumber,
                    validator: (value) {},
                    decoration: InputDecoration(
                        prefixText: '    ',
                        suffixText: '    ',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        labelText: 'Phone Number'),
                    //require: true,
                  ),
                  FormBuilderInput.checkbox(
                      require: true,
                      decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none),
                      label: FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/terms');
                        },
                        child: Text('Terms & Conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            )),
                      ),
                      attribute: 'Terms and conditions',
                      value: false,
                      validator: (value) {
                        if (!value)
                          return 'Terms and Conditions must be accepted';
                      }),
                  FormBuilderInput.checkbox(
                      require: true,
                      decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none),
                      label: FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/privacy');
                        },
                        child: Text('Privacy Policy',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            )),
                      ),
                      attribute: 'accept_privacy_switch',
                      value: false,
                      validator: (value) {
                        if (!value) return 'Privacy policy must be accepted';
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
