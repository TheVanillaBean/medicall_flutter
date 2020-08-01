import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisitDocNote extends StatelessWidget {
  final Consult consult;

  const VisitDocNote({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitDocNote,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Doctor Note",
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/dashboard');
                })
          ]),
      body: FutureBuilder<ScreeningQuestions>(
        future: db.consultQuestionnaire(consultId: consult.uid),
        builder:
            (BuildContext context, AsyncSnapshot<ScreeningQuestions> snapshot) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(40, 5, 40, 5),
                  child: Text(
                    'data',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
