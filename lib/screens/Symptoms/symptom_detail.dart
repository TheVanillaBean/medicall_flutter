import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/SelectProvider/select_provider.dart';
import 'package:Medicall/screens/Welcome/welcome.dart';
import 'package:Medicall/screens/Welcome/zip_code_verify.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SymptomDetailScreen extends StatelessWidget {
  final Symptom symptom;

  const SymptomDetailScreen({@required this.symptom});

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.symptomDetail,
      arguments: {
        'symptom': symptom,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MedicallUser medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}

    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: StringUtils.capitalize(symptom.name) + ' visit',
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (medicallUser != null) {
                    PatientDashboardScreen.show(
                      context: context,
                      pushReplaceNamed: true,
                    );
                  } else {
                    WelcomeScreen.show(
                      context: context,
                    );
                  }
                })
          ]),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        color: Colors.white,
        child: Column(
          children: _buildChildren(context, medicallUser),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context, MedicallUser medicallUser) {
    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              'Price',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Container(
            child: Text(
              "\$" + symptom.price.toString(),
              style: Theme.of(context).textTheme.headline5,
            ),
          )
        ],
      ),
      Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Divider(
            thickness: 1,
          )),
      Container(
        child: Text(
          symptom.description,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 40),
      _buildMedicationsDialog(context),
      SizedBox(height: 80),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: ReusableRaisedButton(
            title: 'Explore Providers',
            onPressed: () {
              if (medicallUser != null && medicallUser.uid.length > 0) {
                SelectProviderScreen.show(context: context, symptom: symptom);
              } else {
                ZipCodeVerifyScreen.show(context: context, symptom: symptom);
              }
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildMedicationsDialog(BuildContext context) {
    return ReusableRaisedButton(
      title: "Common Medications",
      outlined: true,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: Text(
                "Common Medications",
                style: Theme.of(context).textTheme.headline6,
              ),
              content: Text(
                symptom.commonMedications,
                style: Theme.of(context).textTheme.caption,
              ),
              actions: <Widget>[
                ReusableRaisedButton(
                  outlined: true,
                  width: 120,
                  title: "Close",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
