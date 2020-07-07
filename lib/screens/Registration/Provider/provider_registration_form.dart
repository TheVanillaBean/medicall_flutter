import 'package:Medicall/screens/Registration/Provider/provider_custom_text_field.dart';
import 'package:flutter/material.dart';

class ProviderRegistrationForm extends StatefulWidget {
  @override
  _ProviderRegistrationFormState createState() =>
      _ProviderRegistrationFormState();
}

class _ProviderRegistrationFormState extends State<ProviderRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _firstName;
  String _lastName;
  String _dob;
  String _email;
  String _password;
  String _address;
  String _titles;
  String _medLicense;
  String _medLicenseState;
  String _displayName;
  bool _loading = false;
  bool _autoValidate = false;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          ProviderCustomTextField(
            onSaved: (input) {
              _firstName = input;
            },
            icon: Icon(Icons.person),
            labelText: 'First Name',
            hint: 'Jane',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _lastName = input;
            },
            icon: Icon(Icons.person),
            labelText: 'Last Name',
            hint: 'Doe',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _dob = input;
            },
            icon: Icon(Icons.calendar_today),
            labelText: 'Date of Birth',
            hint: 'mm/dd/yyyy',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _email = input;
            },
            icon: Icon(Icons.email),
            labelText: 'Email',
            hint: 'janedoe@email.com',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _address = input;
            },
            icon: Icon(Icons.home),
            labelText: 'Address',
            hint: '123 Main St, Anytown, MA 12345',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _titles = input;
            },
            icon: Icon(Icons.school),
            labelText: 'Titles',
            hint: 'M.D., D.O., PharmD',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _medLicense = input;
            },
            icon: Icon(Icons.local_hospital),
            labelText: 'Medical License Number',
            hint: '12345',
          ),
          ProviderCustomTextField(
            onSaved: (input) {
              _medLicenseState = input;
            },
            icon: Icon(Icons.place),
            labelText: 'Medical License State',
            hint: 'MA',
          ),
          SizedBox(height: 20),
          Container(
            width: 250,
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
              shape: StadiumBorder(),
              color: Colors.green,
              textColor: Colors.white,
              child: Text('Register'),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
