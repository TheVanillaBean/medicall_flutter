import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
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
    User medicallUser = Provider.of<UserProvider>(context).user;
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
      body: StreamBuilder(
          stream: db.visitReviewStream(consultId: consult.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                return Container(
                  padding: EdgeInsets.fromLTRB(30, 40, 30, 40),
                  child: TextFormField(
                    maxLines: 20,
                    minLines: 5,
                    readOnly: medicallUser.type.toString() == 'provider'
                        ? true
                        : false,
                    initialValue: snapshot.data == null
                        ? "Please wait while your doctor reviews and sumbits their notes"
                        : snapshot.data.toString(),
                    autocorrect: false,
                    keyboardType: TextInputType.multiline,
                    onChanged: (String text) => db.saveConsult(),
                    style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      labelStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(90),
                      ),
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(100, 100, 100, 1),
                      ),
                      filled: medicallUser.type.toString() == 'provider'
                          ? true
                          : false,
                      fillColor: Colors.grey.withAlpha(20),
                    ),
                  ),
                );
            }
          }),
    );
  }
}
