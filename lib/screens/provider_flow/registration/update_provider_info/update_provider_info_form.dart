import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_custom_text_field.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_registration_view_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

enum ProfileInputType {
  PHONE,
  ADDRESS,
  PROFESSIONAL_TITLE,
  MEDICAL_LICENSE,
  MEDICAL_LICENSE_STATE,
  NPI,
  BOARD_CERTIFIED,
  MEDICAL_SCHOOL,
  MEDICAL_RESIDENCY,
  BIO,
}

class UpdateProviderInfoForm extends StatefulWidget {
  final ProfileInputType inputType;

  const UpdateProviderInfoForm({@required this.inputType});

  @override
  _UpdateProviderInfoFormState createState() => _UpdateProviderInfoFormState();
}

class _UpdateProviderInfoFormState extends State<UpdateProviderInfoForm>
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

  Function updateFunction(ProviderRegistrationViewModel model) {
    if (widget.inputType == ProfileInputType.PHONE) {
      return model.updatePhoneNumber;
    } else if (widget.inputType == ProfileInputType.ADDRESS) {
      return model.updateAddress;
    } else if (widget.inputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return model.updateProfessionalTitle;
    } else if (widget.inputType == ProfileInputType.MEDICAL_LICENSE) {
      return model.updateMedLicense;
    } else if (widget.inputType == ProfileInputType.MEDICAL_LICENSE_STATE) {
      return model.updateMedLicenseState;
    } else if (widget.inputType == ProfileInputType.NPI) {
      return model.updateNpi;
    } else if (widget.inputType == ProfileInputType.BOARD_CERTIFIED) {
      return model.updateBoardCertified;
    } else if (widget.inputType == ProfileInputType.MEDICAL_SCHOOL) {
      return model.updateMedSchool;
    } else if (widget.inputType == ProfileInputType.MEDICAL_RESIDENCY) {
      return model.updateMedResidency;
    } else if (widget.inputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return model.updateProfessionalTitle;
    } else if (widget.inputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return model.updateProfessionalTitle;
    } else if (widget.inputType == ProfileInputType.NPI) {
      return model.updateNpi;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProviderRegistrationViewModel model =
        Provider.of<ProviderRegistrationViewModel>(context);
    model.setVerificationStatus(this);

    String title = "";
    String hint = "";

    if (widget.inputType == ProfileInputType.PHONE) {
      title = "Mobile Phone";
      hint = "(123)456-7890";
    } else if (widget.inputType == ProfileInputType.ADDRESS) {
      title = "Address";
    } else if (widget.inputType == ProfileInputType.PROFESSIONAL_TITLE) {
      title = "Professional Title";
    } else if (widget.inputType == ProfileInputType.MEDICAL_LICENSE) {
      title = "Medical License Number";
    } else if (widget.inputType == ProfileInputType.MEDICAL_LICENSE_STATE) {
      title = "Medical License State";
    } else if (widget.inputType == ProfileInputType.NPI) {
      title = "NPI Number";
    } else if (widget.inputType == ProfileInputType.BOARD_CERTIFIED) {
      title = "Board Certification";
    } else if (widget.inputType == ProfileInputType.MEDICAL_SCHOOL) {
      title = "Medical School";
    } else if (widget.inputType == ProfileInputType.MEDICAL_RESIDENCY) {
      title = "Medical Residency";
    } else if (widget.inputType == ProfileInputType.BIO) {
      title = "Bio";
    }

    if (widget.inputType == ProfileInputType.ADDRESS) {
      return Form(
          key: _formKey,
          autovalidate: false,
          child: Column(
            children: [
              ProviderCustomTextField(
                labelText: 'Practice Address',
                hint: '123 Main St',
                errorText: model.practiceAddressErrorText,
                onChanged: model.updateAddress,
              ),
              ProviderCustomTextField(
                labelText: 'Apartment, building, suite (optional)',
                hint: 'BLDG E, APT 2',
                //errorText: model.practiceAddressErrorText,
                onChanged: model.updateAddressLine2,
              ),
              ProviderCustomTextField(
                labelText: 'City',
                hint: 'Anytown',
                errorText: model.practiceCityErrorText,
                onChanged: model.updateCity,
              ),
              CustomDropdownFormField(
                labelText: 'State',
                onChanged: model.updateState,
                items: model.states,
                selectedItem: model.state,
                errorText: model.practiceStateErrorText,
              ),
              ProviderCustomTextField(
                labelText: 'Zip Code',
                inputFormatters: [zipCodeTextInputFormatter],
                hint: '12345',
                keyboardType: TextInputType.number,
                errorText: model.practiceZipCodeErrorText,
                onChanged: model.updateZipCode,
              ),
              SizedBox(height: 20),
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
    } else if (widget.inputType == ProfileInputType.PHONE) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderCustomTextField(
              inputFormatters: [phoneTextInputFormatter],
              labelText: 'Mobile Phone',
              hint: '(123)456-7890',
              keyboardType: TextInputType.phone,
              errorText: model.mobilePhoneErrorText,
              onChanged: model.updatePhoneNumber,
            ),
            SizedBox(height: 20),
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            CustomDropdownFormField(
              labelText: 'Select Your Title',
              hint: 'Select your title',
              items: model.professionalTitles,
              selectedItem: model.professionalTitle,
              errorText: model.professionalTitleErrorText,
              onChanged: model.updateProfessionalTitle,
            ),
            SizedBox(height: 20),
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
        ),
      );
    } else {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderCustomTextField(
              labelText: title,
              hint: '1234567890',
              keyboardType: TextInputType.number,
              errorText: model.npiNumberErrorText,
              onChanged: updateFunction(model),
            ),
          ],
        ),
      );
    }
  }

  void _showFlushBarMessage(String message) {
    AppUtil().showFlushBar(message, context);
  }

  @override
  void updateStatus(String msg) {
    _showFlushBarMessage(msg);
  }
}
