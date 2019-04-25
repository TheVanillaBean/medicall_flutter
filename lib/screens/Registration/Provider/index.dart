import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Medicall/globals.dart' as globals;

class RegistrationProviderScreen extends StatefulWidget {
  final GoogleSignInAccount googleUser;
  final FirebaseUser firebaseUser;

  const RegistrationProviderScreen(
      {Key key, this.googleUser, this.firebaseUser})
      : super(key: key);
  @override
  _RegistrationProviderScreenState createState() =>
      _RegistrationProviderScreenState();
}

class _RegistrationProviderScreenState
    extends State<RegistrationProviderScreen> {
  GlobalKey<FormBuilderState> _userRegKey = GlobalKey();
  var data;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: Text('Provider Registration'),
        leading: new Text('', style: TextStyle(color: Colors.black26)),
      ),
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () {
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
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
                    value: globals.currentFirebaseUser.email != null
                        ? ''
                        : globals.currentFirebaseUser.phoneNumber.length > 0
                            ? ''
                            : widget.googleUser.displayName.split(' ')[0],
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
                    value: globals.currentFirebaseUser.email != null
                        ? ''
                        : globals.currentFirebaseUser.phoneNumber.length > 0
                            ? ''
                            : widget.googleUser.displayName.split(' ')[1],
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

                  // FormBuilderInput.typeAhead(
                  //   value: '',
                  //   getImmediateSuggestions: true,
                  //   validator: (value) {
                  //     if (value.isEmpty) {
                  //       return 'Country is required';
                  //     }
                  //   },
                  //   require: true,
                  //   autovalidate: true,
                  //   decoration: InputDecoration(
                  //       fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                  //       filled: true,
                  //       enabledBorder: OutlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: Colors.black.withOpacity(0.1)),
                  //       ),
                  //       labelText: 'Country'),
                  //   attribute: 'Country',
                  //   itemBuilder: (context, country) {
                  //     return ListTile(
                  //       title: Text(country),
                  //     );
                  //   },
                  //   suggestionsCallback: (query) {
                  //     if (query.length != 0) {
                  //       var lowercaseQuery = query.toLowerCase();
                  //       return allCountries.where((country) {
                  //         return country.toLowerCase().contains(lowercaseQuery);
                  //       }).toList(growable: false)
                  //         ..sort((a, b) => a
                  //             .toLowerCase()
                  //             .indexOf(lowercaseQuery)
                  //             .compareTo(
                  //                 b.toLowerCase().indexOf(lowercaseQuery)));
                  //     } else {
                  //       return allCountries;
                  //     }
                  //   },
                  // ),
                  // FormBuilderInput.textField(
                  //   type: FormBuilderInput.TYPE_TEXT,
                  //   attribute: 'spacer',
                  //   decoration: InputDecoration.collapsed(
                  //       hintText: '', enabled: false, border: InputBorder.none),
                  //   value: '',
                  //   readonly: true,
                  //   require: false,
                  // ),
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
                    value: globals.currentFirebaseUser.email != null
                        ? globals.currentFirebaseUser.email
                        : globals.currentFirebaseUser.phoneNumber.length > 0
                            ? ''
                            : widget.googleUser.email,
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
                    value: globals.currentFirebaseUser.phoneNumber != null
                        ? globals.currentFirebaseUser.phoneNumber
                        : '',
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
