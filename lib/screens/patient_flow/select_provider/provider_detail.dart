import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/registration/registration.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/screens/patient_flow/verify_insurance/verify_insurance.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Symptom symptom;
  final ProviderUser provider;
  final bool inNetwork;

  const ProviderDetailScreen({
    @required this.symptom,
    @required this.provider,
    @required this.inNetwork,
  });

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
    ProviderUser provider,
    bool inNetwork,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.providerDetail,
      arguments: {
        'symptom': symptom,
        'provider': provider,
        'inNetwork': inNetwork
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    final ExtImageProvider extImageProvider =
        Provider.of<ExtImageProvider>(context);

    PatientUser currentUser;
    try {
      currentUser = Provider.of<UserProvider>(context).user;
    } catch (e) {
      // This is okay, as this just checks if the provider exists.
    }

    ScreenUtil.init(context);
    return Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: 'Provider Information',
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (currentUser != null) {
                    PatientDashboardScreen.show(
                      context: context,
                      pushReplaceNamed: true,
                    );
                  } else {
                    WelcomeScreen.show(context: context);
                  }
                })
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 12, 30, 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _buildChildren(
                    tempUserProvider,
                    extImageProvider,
                    currentUser,
                    context,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white.withAlpha(170),
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: SizedBox(
                  height: 60,
                  width: ScreenUtil.screenWidthDp - 60,
                  child: ReusableRaisedButton(
                    title: "Start Visit",
                    onPressed: () {
                      Consult consult = Consult(
                        providerId: provider.uid,
                        providerUser: provider,
                        symptom: symptom.name,
                        date: DateTime.now(),
                        price: 49,
                      );
                      if (currentUser != null) {
                        if (inNetwork) {
                          VerifyInsurance.show(
                            context: context,
                            pushReplaceNamed: false,
                            consult: consult,
                          );
                        } else {
                          StartVisitScreen.show(
                            context: context,
                            consult: consult,
                          );
                        }
                      } else {
                        tempUserProvider.consult = consult;
                        RegistrationScreen.show(context: context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  List<Widget> _buildChildren(
    TempUserProvider tempUserProvider,
    ExtendedImageProvider extImageProvider,
    PatientUser currentUser,
    BuildContext context,
  ) {
    return <Widget>[
      CircleAvatar(
        radius: 150.0,
        child: ClipOval(
          child: provider.profilePic.length > 0
              ? extImageProvider.returnNetworkImage(
                  provider.profilePic,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.account_circle,
                  size: 250,
                  color: Colors.grey,
                ),
        ),
        backgroundColor: Colors.transparent,
      ),
      SizedBox(height: 10),
      Center(
        child: Text(
          provider.fullName + ', ' + provider.professionalTitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20.0,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(
        height: 30,
        width: 120,
        child: Divider(
          color: Colors.black38,
        ),
      ),
      provider.medSchool != '' ? _medSchoolInfo(context) : SizedBox(),
      provider.medSchool != '' ? Divider(height: 0) : SizedBox(),
      provider.medResidency != '' ? _medResidencyInfo(context) : SizedBox(),
      provider.medResidency != '' ? Divider(height: 0) : SizedBox(),
      provider.practiceName != '' ? _practiceNameInfo(context) : SizedBox(),
      provider.practiceName != '' ? Divider(height: 0) : SizedBox(),
      provider.mailingAddress != ''
          ? _practiceAddressInfo(context)
          : SizedBox(),
      provider.mailingAddress != '' ? Divider(height: 0) : SizedBox(),
      provider.providerBio != '' ? _providerBioInfo(context) : SizedBox(),
    ];
  }

  Widget _providerBioInfo(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 8),
      dense: true,
      title: Text(
        'Bio:',
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        provider.providerBio ?? '',
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _practiceAddressInfo(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 8),
      dense: true,
      title: Text(
        'Practice Address:',
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        provider.mailingAddressLine2 == ''
            ? '${provider.mailingAddress} \n${provider.mailingCity}, ${provider.mailingState} ${provider.mailingZipCode}'
            : '${provider.mailingAddress} \n${provider.mailingAddressLine2} \n${provider.mailingCity}, ${provider.mailingState} ${provider.mailingZipCode}',
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _medResidencyInfo(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      dense: true,
      title: Text(
        'Medical Residency:',
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        provider.medResidency ?? '',
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _medSchoolInfo(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      dense: true,
      title: Text(
        'Medical School:',
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        provider.medSchool ?? '',
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _practiceNameInfo(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      dense: true,
      title: Text(
        'Practice Name:',
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        provider.practiceName ?? '',
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
