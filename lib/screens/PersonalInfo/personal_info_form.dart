import 'package:Medicall/common_widgets/custom_date_picker_formfield.dart';
import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/screens/MakePayment/make_payment.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info_text_field.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info_view_model.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PersonalInfoForm extends StatefulWidget {
  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm>
    with PersonalFormStatus {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MaskTextInputFormatter phoneTextInputFormatter = MaskTextInputFormatter(
      mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});

  MaskTextInputFormatter dobTextInputFormatter = MaskTextInputFormatter(
      mask: "##/##/####", filter: {"#": RegExp(r'[0-9]')});

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
        Provider.of<PersonalInfoViewModel>(context);
    model.setFormStatus(this);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          PersonalInfoTextField(
            labelText: 'First Name',
            hint: 'Jane',
            onChanged: model.updateFirstName,
          ),
          PersonalInfoTextField(
            labelText: 'Last Name',
            hint: 'Doe',
            onChanged: model.updateLastName,
          ),
          PersonalInfoTextField(
            inputFormatters: [phoneTextInputFormatter],
            labelText: 'Phone Number',
            hint: '(123)456-7890',
            keyboardType: TextInputType.phone,
            onChanged: model.updatePhoneNumber,
          ),
          CustomDatePickerFormField(
            inputFormatters: [dobTextInputFormatter],
            labelText: 'Date of Birth',
            hint: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
            initialDate: model.initialDatePickerDate,
            onChanged: model.updateBirthDate,
          ),
          PersonalInfoTextField(
            labelText: 'Billing Address',
            hint: '123 Main St',
            onChanged: model.updateBillingAddress,
          ),
          PersonalInfoTextField(
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
          PersonalInfoTextField(
            labelText: 'Zip code',
            hint: '12345',
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
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _submit(
                      model,
                      extendedImageProvider,
                    );
                  } else {
                    model.btnController.reset();
                  }
                },
              ),
            ),
          ),
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
