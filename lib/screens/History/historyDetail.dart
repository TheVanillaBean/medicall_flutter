import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user.dart';
import 'package:Medicall/screens/QuestionsUpload/asset_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;

class HistoryDetailScreen extends StatefulWidget {
  final data;
  HistoryDetailScreen({Key key, @required this.data}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Consult Details',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(medicallUser.id)
                  .collection('consults')
                  .document(widget.data)
                  .snapshots(),
              builder: (context, snapshot) {
                var userDocuments = snapshot.data;
                if (!snapshot.hasData) {
                  return new Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var combinedQuestions = [
                  {'Symptom Questions': userDocuments['screening_questions']},
                  {
                    'Medical History Questions':
                        userDocuments['medical_history_questions']
                  },
                  {'Pictures': userDocuments['media']},
                ];
                List<Widget> historyList = [];
                for (var i = 0; i < combinedQuestions.length; i++) {
                  historyList.add(Expanded(
                    child: ListView.builder(
                      itemCount: combinedQuestions[i].values.length,
                      itemBuilder: (context, x) {
                        return ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            combinedQuestions[i].keys.first,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                          children: <Widget>[
                            Column(
                              children:
                                  _buildExpandableContent(combinedQuestions[i]),
                            ),
                          ],
                        );
                      },
                    ),
                  ));
                }
                return Column(children: historyList);
              }),
        ));
  }

  _buildExpandableContent(dynamic question) {
    List<Widget> columnContent = [];
    for (var i = 0; i < question.values.first.length; i++) {
      if (question.values.first[i] is Map) {
        if (question.values.first[i]['answers'] is String) {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i]['answers'],
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: Text(question.values.first[i]['question']),
              leading: Icon(Icons.linear_scale),
            ),
          );
        } else {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i]['answers']
                    .toString()
                    .replaceAll(']', '')
                    .replaceAll('[', '')
                    .replaceFirst(', ', ''),
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: Text(question.values.first[i]['question']),
              leading: Icon(Icons.linear_scale),
            ),
          );
        }
      }
    }
    if (question.keys.first == 'Pictures') {
      for (var i = 0; i < question.values.first.length; i++) {
        columnContent.add(
          ListTile(
            leading: Image.network(question.values.first[i]),
            title: Text(
              question.values.first[i].toString().split('%2F')[3].split('?')[0],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      }
    }
    return columnContent;
  }
}
