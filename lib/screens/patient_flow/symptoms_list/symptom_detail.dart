import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/enter_insurance/enter_insurance.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).appBarTheme.iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                );
              },
            ),
            floating: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Image.network(
                symptom.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SymptomBody(symptom: symptom),
        ],
      ),
    );
  }
}

class SymptomBody extends StatelessWidget {
  final Symptom symptom;

  const SymptomBody({@required this.symptom});

  @override
  Widget build(BuildContext context) {
    MedicallUser medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context, listen: false).user;
    } catch (e) {}

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        color: Colors.white,
        child: Column(
          children: _buildChildren(context, medicallUser),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context, MedicallUser medicallUser) {
    String price =
        symptom.category == "cosmetic" ? "\$${symptom.price}" : "Variable";
    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              "${symptom.name}",
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontSize: 24,
                  ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 16,
      ),
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
              price,
              style: Theme.of(context).textTheme.headline5,
            ),
          )
        ],
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Divider(
          thickness: 1,
        ),
      ),
      Container(
        child: Text(
          symptom.description,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 80),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: ReusableRaisedButton(
            title: 'Explore Providers',
            onPressed: () async {
              if (medicallUser != null && medicallUser.uid.length > 0) {
                SelectProviderScreen.show(
                  context: context,
                  symptom: symptom,
                  state: medicallUser.mailingState,
                  insurance: (medicallUser as PatientUser).insurance,
                  filter: (medicallUser as PatientUser).insurance ==
                          "Proceed without insurance"
                      ? SelectProviderFilter.NoInsurance
                      : SelectProviderFilter.InNetwork,
                );
              } else {
                EnterInsuranceScreen.show(context: context, symptom: symptom);
              }
            },
          ),
        ),
      ),
    ];
  }
}
