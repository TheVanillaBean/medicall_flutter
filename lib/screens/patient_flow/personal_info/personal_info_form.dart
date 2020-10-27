import 'package:Medicall/common_widgets/custom_date_picker_formfield.dart';
import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info_text_field.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info_view_model.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PersonalInfoForm extends StatefulWidget {
  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MaskTextInputFormatter phoneTextInputFormatter = MaskTextInputFormatter(
      mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter dobTextInputFormatter = MaskTextInputFormatter(
      mask: "##/##/####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter zipCodeTextInputFormatter =
      MaskTextInputFormatter(mask: "#####", filter: {"#": RegExp(r'[0-9]')});

  Future<void> _submit(
    PersonalInfoViewModel model,
    ExtendedImageProvider extendedImageProvider,
  ) async {
    try {
      await model.submit();
      extendedImageProvider.clearImageMemory();
      MakePayment.show(context: context, consult: model.consult);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExtendedImageProvider extendedImageProvider =
        Provider.of<ExtImageProvider>(context);
    final PersonalInfoViewModel model =
        PropertyChangeProvider.of<PersonalInfoViewModel>(
      context,
      properties: [PersonalInfoVMProperties.form],
    ).value;

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          PersonalInfoTextField(
            labelText: 'First Name',
            hint: 'Jane',
            errorText: model.firstNameErrorText,
            onChanged: model.updateFirstName,
          ),
          PersonalInfoTextField(
            labelText: 'Last Name',
            hint: 'Doe',
            errorText: model.lastNameErrorText,
            onChanged: model.updateLastName,
          ),
          PersonalInfoTextField(
            inputFormatters: [phoneTextInputFormatter],
            labelText: 'Phone Number',
            hint: '(123)456-7890',
            keyboardType: TextInputType.phone,
            errorText: model.phoneNumberErrorText,
            onChanged: model.updatePhoneNumber,
          ),
          CustomDatePickerFormField(
            inputFormatters: [dobTextInputFormatter],
            labelText: 'Date of Birth',
            hint: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
            errorText: model.patientDobErrorText,
            initialDate: model.initialDatePickerDate,
            onChanged: model.updateBirthDate,
          ),
          PersonalInfoTextField(
            labelText: 'Billing Address',
            hint: '123 Main St',
            errorText: model.patientBillingAddressErrorText,
            onChanged: model.updateBillingAddress,
          ),
          PersonalInfoTextField(
            labelText: 'Apartment, building, suite (optional)',
            hint: 'BLDG E, APT 2',
            onChanged: model.updateBillingAddressLine2,
          ),
          PersonalInfoTextField(
            labelText: 'City',
            hint: 'Anytown',
            errorText: model.patientCityErrorText,
            onChanged: model.updateCity,
          ),
          CustomDropdownFormField(
            labelText: 'State',
            onChanged: model.updateState,
            items: model.states,
            errorText: model.patientStateErrorText,
            selectedItem: model.state,
          ),
          PersonalInfoTextField(
            labelText: 'Zip code',
            inputFormatters: [zipCodeTextInputFormatter],
            hint: '12345',
            errorText: model.patientZipCodeErrorText,
            keyboardType: TextInputType.number,
            onChanged: model.updateZipCode,
          ),
          SizedBox(height: 30),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: SizedBox(
              height: 50,
              width: 200,
              child: RoundedLoadingButton(
                controller: model.btnController,
                color: Theme.of(context).colorScheme.primary,
                child: Text(
                  'Looks Good!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: !model.isLoading
                    ? () {
                        if (_formKey.currentState.validate()) {
                          _submit(
                            model,
                            extendedImageProvider,
                          );
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
