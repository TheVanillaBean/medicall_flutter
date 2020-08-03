import 'package:Medicall/common_widgets/custom_date_picker_formfield.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/screens/PersonalInfo/patient_custom_text_field.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info_view_model.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:super_rich_text/super_rich_text.dart';

class PatientRegistrationForm extends StatefulWidget {
  @override
  _PatientRegistrationFormState createState() =>
      _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm>
    with VerificationStatus {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submit(PersonalInfoViewModel model) async {
    try {
      await model.submit();
    } on PlatformException catch (e) {
      AppUtil.internal().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PersonalInfoViewModel model =
        Provider.of<PersonalInfoViewModel>(context);
    //model.setVerificationStatus(this);
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          PatientCustomTextField(
            labelText: 'First Name',
            hint: 'Jane',
            onChanged: model.updateFirstName,
          ),
          PatientCustomTextField(
            labelText: 'Last Name',
            hint: 'Doe',
            onChanged: model.updateLastName,
          ),
          PatientCustomTextField(
            labelText: 'Phone Number',
            hint: '(123)456-7890',
            keyboardType: TextInputType.phone,
            onChanged: model.updatePhoneNumber,
          ),
          CustomDatePickerFormField(
            labelText: 'Date of Birth: mm/dd/yyyy',
            hint: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
            initialDate: model.initialDatePickerDate,
            onChanged: model.updateBirthDate,
          ),

          PatientCustomTextField(
            labelText: 'Billing Address',
            hint: '123 Main St',
            onChanged: model.updateBillingAddress,
          ),

          PatientCustomTextField(
            labelText: 'City',
            hint: 'Anytown',
            onChanged: model.updateCity,
          ),

          CustomDropdownFormField(
            labelText: 'State',
            onChanged: model.updateState,
            items: model.states,
            selectedItem: model.state,
          ),

          PatientCustomTextField(
            labelText: 'Zip code',
            hint: '12345',
            keyboardType: TextInputType.number,
            onChanged: model.updateZipCode,
          ),

          //SizedBox(height: 20),
//          Container(
//            child: ExcludeSemantics(
//              child: _buildTermsCheckbox(model),
//            ),
//          ),
          SizedBox(height: 20),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: ReusableRaisedButton(
              title: 'Looks Good!',
              onPressed: model.canSubmit
                  ? () {
                      if (_formKey.currentState.validate()) {
                        _submit(model);
                      }
                    }
                  : null,
            ),
          ),
          SizedBox(height: 30),
          if (model.isLoading)
            Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator()),
        ],
      ),
    );
  }

//  Widget _buildTermsCheckbox(PersonalInfoViewModel model) {
//    return CheckboxListTile(
//      title: Title(
//        color: Colors.blue,
//        child: SuperRichText(
//          text:
//              'I agree to Medicall’s <terms>Terms & Conditions<terms>. I have reviewed the <privacy>Privacy Policy<privacy> and understand the benefits and risks of remote treatment.',
//          style: TextStyle(color: Colors.black87, fontSize: 14),
//          othersMarkers: [
//            MarkerText.withSameFunction(
//              marker: '<terms>',
//              function: () => Navigator.of(context).pushNamed('/terms'),
//              onError: (msg) => print('$msg'),
//              style: TextStyle(
//                  color: Colors.blue, decoration: TextDecoration.underline),
//            ),
//            MarkerText.withSameFunction(
//              marker: '<privacy>',
//              function: () => Navigator.of(context).pushNamed('/privacy'),
//              onError: (msg) => print('$msg'),
//              style: TextStyle(
//                  color: Colors.blue, decoration: TextDecoration.underline),
//            ),
//          ],
//        ),
//      ),
//      value: model.checkValue,
//      onChanged: model.updateCheckValue,
//      controlAffinity: ListTileControlAffinity.leading,
//      activeColor: Colors.blue,
//    );
//  }

  void _showFlushBarMessage(String message) {
    AppUtil().showFlushBar(message, context);
  }

  @override
  void updateStatus(String msg) {
    _showFlushBarMessage(msg);
  }
}
