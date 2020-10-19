import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_bio_text_field.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_custom_text_field.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
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

  Future<void> _submit(
    UpdateProviderInfoViewModel model,
  ) async {
    try {
      await model.submit();
      Navigator.pop(context);
    } catch (e) {
      AppUtil.internal().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UpdateProviderInfoViewModel model =
        Provider.of<UpdateProviderInfoViewModel>(
      context,
      listen: false,
    );

    model.setVerificationStatus(this);

    if (model.profileInputType == ProfileInputType.ADDRESS) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderCustomTextField(
              initialText: userProvider.user.mailingAddress,
              labelText: 'Practice Address',
              hint: '123 Main St',
              errorText: model.practiceAddressErrorText,
              onChanged: model.updateMailingAddress,
            ),
            ProviderCustomTextField(
              initialText: userProvider.user.mailingAddressLine2,
              labelText: 'Apartment, building, suite (optional)',
              hint: 'BLDG E, APT 2',
              errorText: model.practiceAddressErrorText,
              onChanged: model.updateMailingAddressLine2,
            ),
            ProviderCustomTextField(
              initialText: userProvider.user.mailingCity,
              labelText: 'City',
              hint: 'Anytown',
              errorText: model.practiceCityErrorText,
              onChanged: model.updateMailingCity,
            ),
            CustomDropdownFormField(
              labelText: 'State',
              onChanged: model.updateMailingState,
              items: model.states,
              selectedItem: userProvider.user.mailingState,
              errorText: model.practiceStateErrorText,
            ),
            ProviderCustomTextField(
              initialText: userProvider.user.mailingZipCode,
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
    } else if (model.profileInputType == ProfileInputType.PHONE) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderCustomTextField(
              initialText: userProvider.user.phoneNumber,
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
    } else if (model.profileInputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            CustomDropdownFormField(
              labelText: 'Select Your Title',
              hint: 'Select your title',
              items: model.professionalTitles,
              selectedItem:
                  (userProvider.user as ProviderUser).professionalTitle,
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
    } else if (model.profileInputType == ProfileInputType.MEDICAL_LICENSE) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderCustomTextField(
              initialText: (userProvider.user as ProviderUser).medLicense,
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
    } else if (model.profileInputType ==
        ProfileInputType.MEDICAL_LICENSE_STATE) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            CustomDropdownFormField(
              labelText: 'Medical License State',
              onChanged: model.updateMedLicenseState,
              items: model.states,
              selectedItem: (userProvider.user as ProviderUser).medLicenseState,
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
    } else if (model.profileInputType == ProfileInputType.NPI) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderCustomTextField(
              initialText: (userProvider.user as ProviderUser).npi,
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
    } else if (model.profileInputType == ProfileInputType.BOARD_CERTIFIED) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            CustomDropdownFormField(
              labelText: 'Board Certification',
              onChanged: model.updateBoardCertified,
              items: model.boardCertification,
              selectedItem: (userProvider.user as ProviderUser).boardCertified,
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
    } else if (model.profileInputType == ProfileInputType.MEDICAL_SCHOOL) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderBioTextField(
              initialText: (userProvider.user as ProviderUser).medSchool,
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
    } else if (model.profileInputType == ProfileInputType.MEDICAL_RESIDENCY) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderBioTextField(
              initialText: (userProvider.user as ProviderUser).medResidency,
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
    } else if (model.profileInputType == ProfileInputType.BIO) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            ProviderBioTextField(
              initialText: (userProvider.user as ProviderUser).providerBio,
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
