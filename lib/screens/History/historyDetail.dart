import 'package:Medicall/models/medicall_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryDetailScreen extends StatefulWidget {
  final data;
  HistoryDetailScreen({Key key, @required this.data}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;
  GlobalKey<FormBuilderState> _consultFormKey = GlobalKey();
  bool isLoading = true;

  var snapshot;
  @override
  initState() {
    super.initState();
    _getConsultDetail();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  Future<void> _getConsultDetail() async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(widget.data);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data != null) {
        setState(() {
          snapshot = datasnapshot.data;
        });
      }
    }).catchError((e) => print(e));
  }

  Future<void> _updateConsult() async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(widget.data);
    Map<String, String> data = <String, String>{
      "consult": _consultFormKey.currentState.value['docInput'],
    };
    await documentReference.updateData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          snapshot != null && snapshot['provider'] != null
              ? 'Consult with ' + snapshot['provider']
              : snapshot != null && snapshot['patient'] != null
                  ? 'Consult with ' + snapshot['patient']
                  : '',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
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
      bottomNavigationBar: medicallUser.type == 'provider'
          ? FlatButton(
              child: Text(
                'Edit Consult',
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              padding: EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                _settingModalBottomSheet(context);
              },
            )
          : FlatButton(
              child: Text(
                'Show Consult',
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              padding: EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                _patientModalBottomSheet(context);
              },
            ),
      body: snapshot != null
          ? TabBarView(
              // Add tabs as widgets
              children: <Widget>[
                _buildTab(snapshot['screening_questions']),
                _buildTab(snapshot['medical_history_questions']),
                _buildTab(snapshot['media']),
              ],
              // set the controller
              controller: controller,
            )
          : null,
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: FormBuilder(
              key: _consultFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    color: Theme.of(context).colorScheme.primary.withAlpha(30),
                    child: ListTile(
                      title: Text(
                        'Notes To ' + snapshot['patient'],
                        style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      leading: Icon(
                        Icons.local_hospital,
                        size: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(150),
                      ),
                    ),
                  ),
                  FormBuilderTextField(
                    initialValue: snapshot['consult'],
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
                  Container(
                    child: Text('- ' + medicallUser.displayName),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () {
                            _consultFormKey.currentState.save();
                            _updateConsult();
                            Navigator.pop(context);
                            _previewModalBottomSheet(context);
                          },
                          color: Theme.of(context).primaryColor,
                          child: Text(isLoading ? 'Update Consult' : ''),
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

  Future _previewModalBottomSheet(context) async {
    await _getConsultDetail();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: FormBuilder(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    color: Theme.of(context).colorScheme.primary.withAlpha(30),
                    child: ListTile(
                      title: Text(
                        'Consult Sent',
                        style: TextStyle(
                            fontSize: 24,
                            color:
                                Theme.of(context).colorScheme.secondaryVariant),
                      ),
                      leading: Icon(
                        Icons.local_hospital,
                        size: 40,
                        color: Theme.of(context).colorScheme.secondaryVariant,
                      ),
                    ),
                  ),
                  FormBuilderTextField(
                    initialValue: snapshot['consult'] != null &&
                            snapshot['consult'] != ''
                        ? snapshot['consult']
                        : 'Waiting on Doctor response, please check back later',
                    attribute: 'docInput',
                    readonly: true,
                    maxLines: 10,
                    decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none),
                    validators: [
                      //FormBuilderValidators.required(),
                    ],
                  ),
                  Container(
                    child: Text('- ' + medicallUser.displayName),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () {
                            Navigator.pop(context);
                            //_settingModalBottomSheet(context);
                          },
                          color: Theme.of(context).primaryColor,
                          child: Text('Done'),
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

  void _patientModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                child: ListTile(
                  title: Text(
                    'Doctor Notes',
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  leading: Icon(
                    Icons.local_hospital,
                    size: 40,
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(150),
                  ),
                ),
              ),
              Container(
                  height: 300,
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: Text(
                    snapshot['consult'] != null && snapshot['consult'] != ''
                        ? snapshot['consult']
                        : 'Waiting on Doctor response, please check back later',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  )),
              Container(
                child: Text('- ' + snapshot['provider']),
              )
            ],
          );
        });
  }

  _buildTab(questions) {
    if (questions.length > 0) {
      return Scaffold(
        body: Container(
          child: questions[0].toString().contains('https')
              ? Carousel(
                  autoplay: false,
                  dotColor: Theme.of(context).colorScheme.primary,
                  dotBgColor: Colors.white70,
                  images: questions
                      .map((f) => (CachedNetworkImageProvider(f)))
                      .toList(),
                )
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, i) {
                    if (questions[i]['answers'] is String) {
                      return ListTile(
                        title: Text(
                          questions[i]['question'],
                          style: TextStyle(fontSize: 14.0),
                        ),
                        subtitle: Text(
                          questions[i]['answers'],
                          style: TextStyle(
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        leading: Text((i + 1).toString() + '.'),
                      );
                    } else {
                      return ListTile(
                        title: Text(
                          questions[i]['question'],
                          style: TextStyle(fontSize: 14.0),
                        ),
                        subtitle: Text(
                          questions[i]['answers']
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
                      );
                    }
                  }),
        ),
      );
    } else {
      return Center(
        child: Icon(
          Icons.broken_image,
          size: 140,
          color: Theme.of(context).colorScheme.secondary.withAlpha(90),
        ),
      );
    }
  }
}
