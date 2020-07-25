import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Questions/CompleteVisit/complete_visit_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompleteVisit extends StatelessWidget {
  const CompleteVisit({@required this.consult, @required this.model});
  final Consult consult;
  final CompleteVisitViewModel model;

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.completeVisit,
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
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        centerTitle: true,
        title: Text('Complete Visit',
            style: TextStyle(
              fontFamily: 'Roboto Thin',
              fontSize: 18,
              color: Colors.blue,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please Note:',
                    style: TextStyle(
                      fontFamily: 'Roboto Regular',
                      fontSize: 14.0,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Text(
                'Marking the visit \"complete\" will notify the patient that you\'ve completed your evaluation. The patient will still be able to message you with questions for 7 days.',
                style: TextStyle(
                  height: 1.5,
                  fontFamily: 'Roboto Regular',
                  fontSize: 14.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 250),
              ListTileTheme(
                contentPadding: EdgeInsets.all(0),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'Please send a copy of my note to my office manager via secure email.',
                    style: TextStyle(
                      fontFamily: 'Roboto Regular',
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  value: model.checkValue ?? false,
                  onChanged: model.updateCheckValue,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: CustomRaisedButton(
                  color: Colors.blue,
                  borderRadius: 14,
                  child: Text(
                    "Complete Visit",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Medium',
                      fontSize: 14,
                    ),
                  ),
                  onPressed: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<CompleteVisitViewModel>(
      create: (context) => CompleteVisitViewModel(
        database: database,
        userProvider: provider,
        auth: auth,
      ),
      child: Consumer<CompleteVisitViewModel>(
        builder: (_, model, __) => CompleteVisit(model: model, consult: null),
      ),
    );
  }
}