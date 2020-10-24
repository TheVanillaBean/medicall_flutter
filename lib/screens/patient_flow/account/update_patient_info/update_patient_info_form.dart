import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_view_model.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info_text_field.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

enum PatientProfileInputType {
  PHONE,
  ADDRESS,
}

class UpdatePatientInfoForm extends StatefulWidget {
  @override
  _UpdatePatientInfoFormState createState() => _UpdatePatientInfoFormState();
}

class _UpdatePatientInfoFormState extends State<UpdatePatientInfoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MaskTextInputFormatter phoneTextInputFormatter = MaskTextInputFormatter(
      mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter dobTextInputFormatter = MaskTextInputFormatter(
      mask: "##/##/####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter zipCodeTextInputFormatter =
      MaskTextInputFormatter(mask: "#####", filter: {"#": RegExp(r'[0-9]')});

  Future<void> _submit(
    UpdatePatientInfoViewModel model,
  ) async {
    try {
      await model.submit();
      Navigator.pop(context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UpdatePatientInfoViewModel model = Provider.of<UpdatePatientInfoViewModel>(
      context,
      listen: false,
    );

    if (model.patientProfileInputType == PatientProfileInputType.PHONE) {
      return Form(
          key: _formKey,
          child: Column(
            children: [
              PersonalInfoTextField(
                initialText: userProvider.user.phoneNumber,
                inputFormatters: [phoneTextInputFormatter],
                labelText: 'Phone Number',
                hint: '(123)456-7890',
                keyboardType: TextInputType.phone,
                errorText: model.phoneNumberErrorText,
                onChanged: model.updatePhoneNumber,
              ),
              SizedBox(height: 30),
              ReusableRaisedButton(
                title: 'Save',
                onPressed: !model.isLoading
                    ? () {
                        if (_formKey.currentState.validate()) {
                          _submit(model);
                        }
                      }
                    : null,
              ),
              SizedBox(height: 70),
              if (model.isLoading)
                Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator()),
            ],
          ));
    } else if (model.patientProfileInputType ==
        PatientProfileInputType.ADDRESS) {
      return Form(
          key: _formKey,
          child: Column(
            children: [
              PersonalInfoTextField(
                initialText: userProvider.user.mailingAddress,
                labelText: 'Billing Address',
                hint: '123 Main St',
                errorText: model.patientBillingAddressErrorText,
                onChanged: model.updateBillingAddress,
              ),
              PersonalInfoTextField(
                initialText: userProvider.user.mailingAddressLine2,
                labelText: 'Apartment, building, suite (optional)',
                hint: 'BLDG E, APT 2',
                onChanged: model.updateBillingAddressLine2,
              ),
              PersonalInfoTextField(
                initialText: userProvider.user.mailingCity,
                labelText: 'City',
                hint: 'Anytown',
                errorText: model.patientCityErrorText,
                onChanged: model.updateMailingCity,
              ),
              CustomDropdownFormField(
                labelText: 'State',
                onChanged: model.updateMailingState,
                items: model.states,
                errorText: model.patientStateErrorText,
                selectedItem: userProvider.user.mailingState,
              ),
              PersonalInfoTextField(
                initialText: userProvider.user.mailingZipCode,
                labelText: 'Zip code',
                inputFormatters: [zipCodeTextInputFormatter],
                hint: '12345',
                errorText: model.patientZipCodeErrorText,
                keyboardType: TextInputType.number,
                onChanged: model.updateMailingZipCode,
              ),
              SizedBox(height: 30),
              ReusableRaisedButton(
                title: 'Save',
                onPressed: !model.isLoading
                    ? () {
                        if (_formKey.currentState.validate()) {
                          _submit(model);
                        }
                      }
                    : null,
              ),
              SizedBox(height: 70),
              if (model.isLoading)
                Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator()),
            ],
          ));
    } else {
      return Center(
        child: Text("An error occurred",
            style: Theme.of(context).textTheme.headline6),
      );
    }
  }
}