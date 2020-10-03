import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_bio_text_field.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_custom_text_field.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';

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

  Future<void> _submit(UpdateProviderInfoViewModel model) async {
    try {
      await model.submit();
      Navigator.pop(context);
    } catch (e) {
      AppUtil.internal().showFlushBar(e, context);
    }
  }

  Function updateFunction(UpdateProviderInfoViewModel model) {
    if (widget.inputType == ProfileInputType.PHONE) {
      return model.updatePhoneNumber;
    } else if (widget.inputType == ProfileInputType.ADDRESS) {
      return model.updateMailingAddress;
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
    final UpdateProviderInfoViewModel model =
        Provider.of<UpdateProviderInfoViewModel>(context);
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
        ),
      );
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
            SizedBox(height: 30),
            ReusableRaisedButton(
              title: 'Save',
              onPressed: !model.isLoading
                  ? () {
                      _submit(model);
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
            SizedBox(height: 30),
            ReusableRaisedButton(
              title: 'Save',
              onPressed: !model.isLoading
                  ? () {
                      _submit(model);
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
    } else if (widget.inputType == ProfileInputType.MEDICAL_LICENSE) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderCustomTextField(
              labelText: 'Medical License Number',
              hint: '12345',
              errorText: model.medicalLicenseErrorText,
              onChanged: model.updateMedLicense,
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.MEDICAL_LICENSE_STATE) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            CustomDropdownFormField(
              labelText: 'Medical License State',
              onChanged: model.updateMedLicenseState,
              items: model.states,
              selectedItem: model.medLicenseState,
              errorText: model.medicalStateErrorText,
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.NPI) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderCustomTextField(
              labelText: 'NPI Number',
              hint: '1234567890',
              keyboardType: TextInputType.number,
              errorText: model.npiNumberErrorText,
              onChanged: model.updateNpi,
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.BOARD_CERTIFIED) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            CustomDropdownFormField(
              labelText: 'Board Certification',
              onChanged: model.updateBoardCertified,
              items: model.boardCertification,
              selectedItem: model.boardCertified,
              errorText: model.boardCertificationErrorText,
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.MEDICAL_SCHOOL) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderBioTextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
              labelText: 'Medical School',
              hint: 'Harvard Medical School',
              errorText: model.medicalSchoolErrorText,
              onChanged: model.updateMedSchool,
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.MEDICAL_RESIDENCY) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderBioTextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
              labelText: 'Medical Residency',
              hint:
                  'Mayo Clinic College of Medicine and Science (Arizona) Dermatology Residency Program in Scottsdale, AZ',
              errorText: model.medicalResidencyErrorText,
              onChanged: model.updateMedResidency,
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
        ),
      );
    } else if (widget.inputType == ProfileInputType.BIO) {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderBioTextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 20,
              maxLength: 1000,
              labelText: 'Short Bio',
              hint:
                  'Dr. Jane Doe is a board-certified dermatologist specializing '
                  'in general and cosmetic dermatology. She earned her medical '
                  'degree from the University of Nevada School of Medicine followed '
                  'by dermatology residency at Mayo Clinic in Scottsdale, AZ. She is '
                  'a member of the Phoenix Dermatology Society, Fellow of the American '
                  'Academy of Dermatologic Surgery and serves as an organizer for the '
                  'Phoenix Dermatology Journal Club. Outside dermatology, Dr. Doe loves '
                  'reading, traveling, and playing piano. She speaks English, Spanish '
                  'and Portuguese.',
              errorText: model.providerBioErrorText,
              onChanged: model.updateProviderBio,
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
        ),
      );
    } else {
      return Form(
        key: _formKey,
        autovalidate: false,
        child: Column(
          children: [
            ProviderBioTextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              labelText: '',
              hint: '',
              errorText: model.invalidInputErrorText,
              onChanged: model.updateProviderBio,
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
