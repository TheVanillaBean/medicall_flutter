import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_list_item.dart';
import 'package:flutter/material.dart';

class VisitOverview extends StatelessWidget {
  final Consult consult;

  const VisitOverview({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitOverview,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text("Visit Overview"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProviderDashboardListItem(
          consult: consult,
          onTap: null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "REVIEW VISIT INFORMATION",
        onPressed: () => {},
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "DIAGNOSIS & TREATMENT PLAN",
        onPressed: () => {},
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "MESSAGE PATIENT",
        onPressed: () => {},
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "REFUND PATIENT FEE",
        onPressed: () => {},
      ),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: SignInButton(
              text: "Begin Diagnosis & Treatment Plan",
              height: 8,
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () => {},
            ),
          ),
        ),
      )
    ];
  }
}