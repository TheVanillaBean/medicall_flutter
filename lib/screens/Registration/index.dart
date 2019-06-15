import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class RegistrationScreen extends StatefulWidget {
  final data;
  const RegistrationScreen({Key key, @required this.data}) : super(key: key);
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormBuilderState> _userRegKey = GlobalKey<FormBuilderState>();
  var data;
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  bool showSegmentedControl = true;
  FirebaseUser firebaseUser;
  final DocumentReference documentReference =
      Firestore.instance.document("users/" + medicallUser.id);

  @override
  void initState() {
    medicallUser = widget.data['user'];
    super.initState();
  }

  void _updateUser() {
    medicallUser.dob = DateFormat('MM-dd-yyyy')
        .format(_userRegKey.currentState.value['Date of birth'])
        .toString();
    medicallUser.terms = _userRegKey.currentState.value['Terms and conditions'];
    medicallUser.firstName = _userRegKey.currentState.value['First name'];
    medicallUser.lastName = _userRegKey.currentState.value['Last name'];
    medicallUser.displayName =
        medicallUser.firstName + " " + medicallUser.lastName;
    medicallUser.address = _userRegKey.currentState.value['Address'];
    medicallUser.titles = _userRegKey.currentState.value['Medical Titles'];
    medicallUser.policy =
        _userRegKey.currentState.value['accept_privacy_switch'];
    Map<String, dynamic> data = <String, dynamic>{
      "name": medicallUser.displayName,
      "first_name": medicallUser.firstName,
      "last_name": medicallUser.lastName,
      "dob": medicallUser.dob,
      "terms": medicallUser.terms,
      "policy": medicallUser.policy,
      "address": medicallUser.address,
      "titles": medicallUser.titles,
      "registered": true,
    };
    documentReference.updateData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
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
          _userRegKey.currentState.save();
          if (_userRegKey.currentState.validate()) {
            print('validationSucceded');
            //print(_userRegKey.currentState.value);
            _updateUser();
            if (medicallUser.type == "provider") {
              Navigator.pushNamed(context, '/history', arguments: widget.data);
            } else {
              Navigator.pushNamed(context, '/doctors', arguments: widget.data);
            }
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
            autovalidate: true,
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
                  validators: [
                    FormBuilderValidators.required(),
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
                  inputType: InputType.date,
                  format: DateFormat("MM-dd-yyyy"),
                  decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  readonly: false,
                ),
                medicallUser.type == "provider"
                    ? Column(
                        children: <Widget>[
                          SizedBox(
                            height: formSpacing,
                          ),
                          FormBuilderTextField(
                            attribute: "Address",
                            initialValue: medicallUser.address,
                            decoration: InputDecoration(
                                labelText: 'Address',
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
                        height: formSpacing,
                      ),
                FormBuilderTextField(
                  attribute: "Phone",
                  initialValue: medicallUser.phoneNumber,
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
                  initialValue: medicallUser.terms,
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
                  initialValue: medicallUser.policy,
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