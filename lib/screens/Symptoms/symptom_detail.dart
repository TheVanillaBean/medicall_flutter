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
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          StringUtils.capitalize(symptom.name) + ' visit',
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pushNamed('/dashboard');
              })
        ],
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
              "\$" + symptom.price.toString(),
              style: TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10), child: Divider()),
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
      Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FlatButton(
            color: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Text(
              'Explore Providers',
              style: TextStyle(fontSize: 14),
            ),
            onPressed: () {
              if (medicallUser != null && medicallUser.uid.length > 0) {
                SelectProviderScreen.show(context: context, symptom: symptom);
              } else {
                ZipCodeVerifyScreen.show(context: context, symptom: symptom);
              }
            },
          ),
        ),
      )
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
                  borderRadius: BorderRadius.circular(12.0)),
              title: Text(
                "Prescriptions Information",
                style: Theme.of(context).textTheme.headline6,
              ),
              content: Text(
                "If a prescription is prescribed, we can send it to your local pharmacy or you can use our prescription service and have your medications delivered to your door with free 2-day shipping. Our prices are lower than most co-pays. Typical medications that are prescribed for hair loss include:",
                style: Theme.of(context).textTheme.caption,
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  width: 1.0, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Text(
            'Common medications',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
