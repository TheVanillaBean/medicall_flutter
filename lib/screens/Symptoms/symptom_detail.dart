import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/SelectProvider/select_provider.dart';
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
    User medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}

    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: StringUtils.capitalize(symptom.name) + ' Visit',
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        color: Colors.white,
        child: Column(
          children: _buildChildren(context, medicallUser),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context, User medicallUser) {
    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              'Price',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
            child: Text(
              symptom.price.toString(),
              style: TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
      SizedBox(height: 30),
      Container(
        child: Text(
          symptom.description,
          style: TextStyle(
            height: 1.6,
            fontSize: 14,
            letterSpacing: 0.6,
            wordSpacing: 1,
          ),
        ),
      ),
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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text(
                "Prescriptions Information",
                style: TextStyle(color: Colors.blue),
              ),
              content: Text(
                "If a prescription is prescribed, we can send it to your local pharmacy or you can use our prescription service and have your medications delivered to your door with free 2-day shipping. Our prices are lower than most co-pays. Typical medications that are prescribed for hair loss include:",
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Text(
          'Common medications',
          style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
