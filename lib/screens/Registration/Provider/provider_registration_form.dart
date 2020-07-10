import 'package:Medicall/screens/Registration/Provider/provider_custom_text_field.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:super_rich_text/super_rich_text.dart';
import '../../../common_widgets/custom_date_picker_formfield.dart';

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
          CustomDatePickerFormField(
            icon: Icon(Icons.calendar_today),
            labelText: 'Date of Birth: mm/dd/yyyy',
            hint: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
            initialDate: model.initialDatePickerDate,
            onChanged: model.updateDOB,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.email),
            labelText: 'Email',
            hint: 'janedoe@email.com',
            onChanged: model.updateEmail,
            errorText: model.emailErrorText,
            enabled: model.isLoading == false,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.security),
            labelText: 'Password',
            obscureText: true,
            onChanged: model.updatePassword,
            errorText: model.passwordErrorText,
            enabled: model.isLoading == false,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.security),
            labelText: 'Confirm Password',
            obscureText: true,
            onChanged: model.updateConfirmPassword,
            errorText: model.confirmPasswordErrorText,
            enabled: model.isLoading == false,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.home),
            labelText: 'Address',
            hint: '123 Main St, Anytown, MA 12345',
            onChanged: model.updateAddress,
          ),
          CustomDropdownFormField(
            icon: Icon(Icons.school),
            labelText: 'Title',
            hint: 'M.D., D.O., PharmD',
            onChanged: model.updateTitles,
            items: ["M.D.", "D.O.", "P.A.", "PharmD"],
            selectedItem: model.titles,
          ),
          ProviderCustomTextField(
            icon: Icon(Icons.local_hospital),
            labelText: 'Medical License Number',
            hint: '12345',
            onChanged: model.updateMedLicense,
          ),
          CustomDropdownFormField(
            icon: Icon(Icons.place),
            labelText: 'Medical License State',
            onChanged: model.updateMedLicenseState,
            items: model.states,
            selectedItem: model.medLicenseState,
          ),
          SizedBox(height: 20),
          Container(
            child: ExcludeSemantics(
              child: _buildTermsCheckbox(model),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: 250,
            child: RaisedButton(
              onPressed: model.canSubmit
                  ? () {
                      if (_formKey.currentState.validate()) {
                        _submit(model);
                      }
                    }
                  : null,
              shape: StadiumBorder(),
              color: Colors.green,
              textColor: Colors.white,
              child: Text('Register'),
            ),
          ),
          SizedBox(height: 24),
          if (model.isLoading)
            Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(ProviderRegistrationViewModel model) {
    return CheckboxListTile(
      title: Title(
        color: Colors.blue,
        child: SuperRichText(
          text:
              'I agree to Medicall’s <terms>Terms & Conditions<terms>. I have reviewed the <privacy>Privacy Policy<privacy> and understand the benefits and risks of remote treatment.',
          style: TextStyle(color: Colors.black87, fontSize: 14),
          othersMarkers: [
            MarkerText.withSameFunction(
              marker: '<terms>',
              function: () => Navigator.of(context).pushNamed('/terms'),
              onError: (msg) => print('$msg'),
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            MarkerText.withSameFunction(
              marker: '<privacy>',
              function: () => Navigator.of(context).pushNamed('/privacy'),
              onError: (msg) => print('$msg'),
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
      value: model.checkValue,
      onChanged: model.updateCheckValue,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.blue,
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
