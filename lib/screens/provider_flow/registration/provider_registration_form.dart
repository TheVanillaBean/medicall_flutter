import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_custom_text_field.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_registration_view_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  MaskTextInputFormatter phoneTextInputFormatter = MaskTextInputFormatter(
      mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter dobTextInputFormatter = MaskTextInputFormatter(
      mask: "##/##/####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter zipCodeTextInputFormatter =
      MaskTextInputFormatter(mask: "#####", filter: {"#": RegExp(r'[0-9]')});

  Future<void> _submit(ProviderRegistrationViewModel model) async {
    try {
      await model.submit();
    } catch (e) {
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
            labelText: 'First Name',
            hint: 'Jane',
            onChanged: model.updateFirstName,
            errorText: model.firstNameErrorText,
          ),
          ProviderCustomTextField(
            labelText: 'Last Name',
            hint: 'Doe',
            onChanged: model.updateLastName,
            errorText: model.lastNameErrorText,
          ),
          ProviderCustomTextField(
            labelText: 'Email',
            hint: 'jane@email.com',
            errorText: model.emailErrorText,
            onChanged: model.updateEmail,
          ),
          CustomDatePickerFormField(
            labelText: 'Date of Birth',
            hint: 'mm/dd/yyyy',
            keyboardType: TextInputType.number,
            inputFormatters: [dobTextInputFormatter],
            initialDate: model.initialDatePickerDate,
            errorText: model.providerDobErrorText,
            onChanged: model.updateDOB,
          ),
          ProviderCustomTextField(
            inputFormatters: [phoneTextInputFormatter],
            labelText: 'Mobile Phone',
            hint: '(123)456-7890',
            keyboardType: TextInputType.phone,
            errorText: model.mobilePhoneErrorText,
            onChanged: model.updatePhoneNumber,
          ),
          ProviderCustomTextField(
            labelText: 'Password',
            obscureText: true,
            onChanged: model.updatePassword,
            errorText: model.passwordErrorText,
            enabled: model.isLoading == false,
          ),
          ProviderCustomTextField(
            labelText: 'Confirm Password',
            obscureText: true,
            onChanged: model.updateConfirmPassword,
            errorText: model.confirmPasswordErrorText,
            enabled: model.isLoading == false,
          ),
          ProviderCustomTextField(
            labelText: 'Practice Address',
            hint: '123 Main St',
            errorText: model.practiceAddressErrorText,
            onChanged: model.updateMailingAddress,
          ),
          ProviderCustomTextField(
            labelText: 'Apartment, building, suite (optional)',
            hint: 'BLDG E, APT 2',
            //errorText: model.practiceAddressErrorText,
            onChanged: model.updateMailingAddressLine2,
          ),
          ProviderCustomTextField(
            labelText: 'City',
            hint: 'Anytown',
            errorText: model.practiceCityErrorText,
            onChanged: model.updateMailingCity,
          ),
          CustomDropdownFormField(
            labelText: 'State',
            onChanged: model.updateMailingState,
            items: model.states,
            selectedItem: model.mailingState,
            errorText: model.practiceStateErrorText,
          ),
          ProviderCustomTextField(
            labelText: 'Zip Code',
            inputFormatters: [zipCodeTextInputFormatter],
            hint: '12345',
            keyboardType: TextInputType.number,
            errorText: model.practiceZipCodeErrorText,
            onChanged: model.updateMailingZipCode,
          ),
          CustomDropdownFormField(
            labelText: 'Select Your Title',
            hint: 'Select your title',
            items: model.professionalTitles,
            selectedItem: model.professionalTitle,
            errorText: model.professionalTitleErrorText,
            onChanged: model.updateProfessionalTitle,
          ),
          ProviderCustomTextField(
            labelText: 'NPI Number',
            hint: '1234567890',
            keyboardType: TextInputType.number,
            errorText: model.npiNumberErrorText,
            onChanged: model.updateNpi,
          ),
          ProviderCustomTextField(
            labelText: 'Medical License Number',
            hint: '12345',
            errorText: model.medicalLicenseErrorText,
            onChanged: model.updateMedLicense,
          ),
          CustomDropdownFormField(
            labelText: 'Medical License State',
            onChanged: model.updateMedLicenseState,
            items: model.states,
            selectedItem: model.medLicenseState,
            errorText: model.medicalStateErrorText,
          ),
          CustomDropdownFormField(
            labelText: 'Board Certification',
            onChanged: model.updateBoardCertified,
            items: model.boardCertification,
            selectedItem: model.boardCertified,
            errorText: model.boardCertificationErrorText,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Please select insurances you accept:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: ChipsChoice<String>.multiple(
                value: model.acceptedInsurances,
                onChanged: (val) => model.updateWith(acceptedInsurances: val),
                choiceItems: C2Choice.listFrom<String, String>(
                  source: model.selectInsurances,
                  value: (i, v) => v,
                  label: (i, v) => v,
                ),
                wrapped: true,
                choiceActiveStyle: C2ChoiceStyle(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            child: ExcludeSemantics(
              child: _buildTermsCheckbox(model),
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: ReusableRaisedButton(
              title: 'Register',
              onPressed: !model.isLoading
                  ? () {
                      if (_formKey.currentState.validate()) {
                        _submit(model);
                      }
                    }
                  : null,
            ),
          ),
          SizedBox(height: 70),
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
              'I agree to Medicall’s <terms>Terms & Conditions<terms>. I have reviewed the <privacy>Privacy Policy<privacy>.',
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
