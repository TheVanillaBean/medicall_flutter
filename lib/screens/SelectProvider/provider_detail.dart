import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/registration.dart';
import 'package:Medicall/screens/Welcome/start_visit.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Symptom symptom;
  final ProviderUser provider;

  const ProviderDetailScreen({@required this.symptom, @required this.provider});

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
    ProviderUser provider,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.providerDetail,
      arguments: {
        'symptom': symptom,
        'provider': provider,
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
          title: provider.fullName + ', ' + provider.professionalTitle,
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (currentUser != null) {
                    Navigator.of(context).pushNamed('/dashboard');
                  } else {
                    Navigator.of(context).pushNamed('/welcome');
                  }
                })
          ]),
      body: SingleChildScrollView(
        child: Container(
          height:
              ScreenUtil.screenHeightDp - (ScreenUtil.screenHeightDp * 0.11),
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
    );
  }

  List<Widget> _buildChildren(
    TempUserProvider tempUserProvider,
    ExtendedImageProvider extImageProvider,
    PatientUser currentUser,
    BuildContext context,
  ) {
    return <Widget>[
      CircleAvatar(
        radius: 80.0,
        child: ClipOval(
          child: provider.profilePic.length > 0
              ? extImageProvider.returnNetworkImage(
                  provider.profilePic,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Colors.grey,
                ),
        ),
        backgroundColor: Colors.transparent,
      ),
      SizedBox(height: 10),
      Text(
        'Dermatologist',
        style: Theme.of(context).textTheme.bodyText1,
      ),
      SizedBox(
        height: 20,
        width: 80,
        child: Divider(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      Container(
        alignment: Alignment.center,
        width: 250,
        child: Text(
          '${provider.mailingAddress}, \n${provider.mailingCity}, ${provider.mailingState} ${provider.mailingZipCode}',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 20),
      Expanded(
        flex: 5,
        child: Container(
          child: Text(
            symptom.description,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Align(
          alignment: FractionalOffset.bottomCenter,
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
                StartVisitScreen.show(
                  context: context,
                  consult: consult,
                );
              } else {
                tempUserProvider.consult = consult;
                RegistrationScreen.show(context: context);
              }
            },
          ),
        ),
      )
    ];
  }
}
