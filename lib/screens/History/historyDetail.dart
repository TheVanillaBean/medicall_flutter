import 'package:Medicall/models/medicall_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class HistoryDetailScreen extends StatefulWidget {
  final data;
  HistoryDetailScreen({Key key, @required this.data}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Consult Details',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        bottom: TabBar(
          tabs: <Tab>[
            Tab(
              // set icon to the tab
              text: 'Symptom',
              icon: Icon(Icons.local_pharmacy),
            ),
            Tab(
              text: 'History',
              icon: Icon(Icons.assignment_ind),
            ),
            Tab(
              text: 'Pictures',
              icon: Icon(Icons.perm_media),
            ),
          ],
          // setup the controller
          controller: controller,
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: FlatButton(
        child: Text('Start Consult'),
        padding: EdgeInsets.all(20),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _settingModalBottomSheet(context);
        },
      ),
      body: TabBarView(
        // Add tabs as widgets
        children: <Widget>[
          _symptomQuestionsTab(),
          _historyQuestionsTab(),
          _picturesTab()
        ],
        // set the controller
        controller: controller,
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.all(10),
            child: FormBuilder(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Enter your consult below,'),
                  FormBuilderTextField(
                    initialValue: '',
                    attribute: 'docInput',
                    maxLines: 10,
                    decoration: InputDecoration(
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none),
                    validators: [
                      //FormBuilderValidators.required(),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () {},
                          color: Theme.of(context).primaryColor,
                          child: Text('Submit Consult'),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  _symptomQuestionsTab() {
    return Scaffold(
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
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              var combinedQuestions = [
                {'Symptom Questions': userDocuments['screening_questions']},
              ];
              List<Widget> historyList = [];
              for (var i = 0; i < combinedQuestions.length; i++) {
                historyList.add(Expanded(
                  child: ListView.builder(
                    itemCount: combinedQuestions[i].values.length,
                    itemBuilder: (context, x) {
                      return Column(
                        children: _buildExpandableContent(combinedQuestions[i]),
                      );
                    },
                  ),
                ));
              }
              return Column(children: historyList);
            }),
      ),
    );
  }

  _picturesTab() {
    return Scaffold(
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
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              var combinedQuestions = [
                {'Pictures': userDocuments['media']},
              ];
              List<Widget> historyList = [];
              for (var i = 0; i < combinedQuestions.length; i++) {
                historyList.add(Expanded(
                  child: ListView.builder(
                    itemCount: combinedQuestions[i].values.length,
                    itemBuilder: (context, x) {
                      return Column(
                        children: _buildExpandableContent(combinedQuestions[i]),
                      );
                    },
                  ),
                ));
              }
              return Column(children: historyList);
            }),
      ),
    );
  }

  _historyQuestionsTab() {
    return Scaffold(
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
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              var combinedQuestions = [
                {
                  'Medical History Questions':
                      userDocuments['medical_history_questions']
                },
              ];
              List<Widget> historyList = [];
              for (var i = 0; i < combinedQuestions.length; i++) {
                historyList.add(Expanded(
                  child: ListView.builder(
                    itemCount: combinedQuestions[i].values.length,
                    itemBuilder: (context, x) {
                      return Column(
                        children: _buildExpandableContent(combinedQuestions[i]),
                      );
                    },
                  ),
                ));
              }
              return Column(children: historyList);
            }),
      ),
    );
  }

  _buildExpandableContent(dynamic question) {
    List<Widget> columnContent = [
      // ListTile(
      //   title: Text(
      //     question.keys.first,
      //     textAlign: TextAlign.center,
      //   ),
      // )
    ];
    for (var i = 0; i < question.values.first.length; i++) {
      if (question.values.first[i] is Map) {
        if (question.values.first[i]['answers'] is String) {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i]['question'],
                style: TextStyle(fontSize: 14.0),
              ),
              subtitle: Text(
                question.values.first[i]['answers'],
                style: TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              leading: Text((i + 1).toString() + '.'),
            ),
          );
        } else {
          columnContent.add(
            ListTile(
              title: Text(
                question.values.first[i]['question'],
                style: TextStyle(fontSize: 14.0),
              ),
              subtitle: Text(
                question.values.first[i]['answers']
                    .toString()
                    .replaceAll(']', '')
                    .replaceAll('[', '')
                    .replaceFirst(', ', ''),
                style: TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              leading: Text((i + 1).toString() + '.'),
            ),
          );
        }
      }
    }
    if (question.keys.first == 'Pictures') {
      List<NetworkImage> allChildren = [];
      for (var i = 0; i < question.values.first.length; i++) {
        allChildren.add(NetworkImage(question.values.first[i]));
        // GridTile(
        //   child: Image.network(question.values.first[i]),
        // ),
        // ListTile(
        //   leading: Image.network(question.values.first[i]),
        //   title: Text(
        //     question.values.first[i].toString().split('%2F')[3].split('?')[0],
        //     style: TextStyle(fontSize: 18.0),
        //   ),
        // ),
      }
      columnContent.add(Container(
          height: 540,
          child: Carousel(
            autoplay: false,
            images: allChildren,
          )));
    }
    return columnContent;
  }
}
