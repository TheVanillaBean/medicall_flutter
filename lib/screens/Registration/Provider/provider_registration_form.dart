import 'package:Medicall/screens/Registration/Provider/provider_custom_text_field.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProviderRegistrationForm extends StatefulWidget {
  @override
  _ProviderRegistrationFormState createState() =>
      _ProviderRegistrationFormState();
}

class _ProviderRegistrationFormState extends State<ProviderRegistrationForm>
    with VerificationStatus {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submit(ProviderRegistrationViewModel model) async {
    try {
      await model.submit();
    } on PlatformException catch (e) {
      AppUtil.internal().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProviderRegistrationViewModel model =
        Provider.of<ProviderRegistrationViewModel>(context);
    model.setVerificationStatus(this);
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          ProviderCustomTextField(
            icon: Icon(Icons.person),
            labelText: 'First Name',
            hint: 'Jane',
            onChanged: model.updateFirstName,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.person),
            labelText: 'Last Name',
            hint: 'Doe',
            onChanged: model.updateLastName,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.calendar_today),
            labelText: 'Date of Birth',
            hint: 'mm/dd/yyyy',
            onChanged: model.updateDOB,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.email),
            labelText: 'Email',
            hint: 'janedoe@email.com',
            onChanged: model.updateEmail,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.security),
            labelText: 'Password',
            onChanged: model.updatePassword,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.home),
            labelText: 'Address',
            hint: '123 Main St, Anytown, MA 12345',
            onChanged: model.updateAddress,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.school),
            labelText: 'Titles',
            hint: 'M.D., D.O., PharmD',
            onChanged: model.updateTitles,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.local_hospital),
            labelText: 'Medical License Number',
            hint: '12345',
            onChanged: model.updateMedLicense,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.place),
            labelText: 'Medical License State',
            hint: 'MA',
            onChanged: model.updateMedLicenseState,
          ),
          SizedBox(height: 20),
          Container(
            width: 250,
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _submit(model);
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

  void _showFlushBarMessage(String message) {
    AppUtil().showFlushBar(message, context);
  }

  @override
  void updateStatus(String msg) {
    _showFlushBarMessage(msg);
  }
}
