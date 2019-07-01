import 'package:Medicall/models/medicall_user_model.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _controller;
  bool isLoading = true;
  bool isConsultOpen = false;
  String documentId;
  String from;

  var snapshot;
  @override
  initState() {
    super.initState();
    documentId = widget.data['documentId'];
    medicallUser = widget.data['user'];
    from = widget.data['from'];
    controller = TabController(length: 3, vsync: this);
    _getConsultDetail();
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  Future<void> _getConsultDetail() async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(documentId);
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
        Firestore.instance.collection('consults').document(documentId);
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
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          snapshot != null && from == 'consults'
              ? snapshot['provider']
              : snapshot != null && from == 'patients'
                  ? snapshot['patient']
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
        leading: WillPopScope(
          onWillPop: () async {
            Navigator.pushNamed(context, '/history',
                arguments: {'user': medicallUser});
            return false;
          },
          child: BackButton(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: !isConsultOpen
          ? FlatButton(
              child: Text(
                'Show Consult',
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              padding: EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _providerModalBottomSheet,
            )
          : FlatButton(
              child: Text(
                'Close Consult',
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              padding: EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                _controller.close();
                setState(() {
                  isConsultOpen = false;
                });
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

  void _providerModalBottomSheet() {
    setState(() {
      isConsultOpen = true;
    });
    _controller = _scaffoldKey.currentState.showBottomSheet(
      (BuildContext bc) {
        return Container(
          color: Theme.of(context).colorScheme.primary.withAlpha(50),
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _consultFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      title: medicallUser.type == 'provider' &&
                              from == "patients"
                          ? Text(
                              'Notes To ' + snapshot['patient'],
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            )
                          : Text(
                              'Notes From ' + snapshot['provider'],
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
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
                  SizedBox(
                    height: 10,
                  ),
                  medicallUser.type == 'provider' && from == 'patients'
                      ? FormBuilderTextField(
                          initialValue: snapshot['consult'],
                          attribute: 'docInput',
                          maxLines: 8,
                          decoration: InputDecoration(
                              fillColor: Color.fromRGBO(255, 255, 255, 0.9),
                              filled: true,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none),
                          validators: [
                            //FormBuilderValidators.required(),
                          ],
                        )
                      : FormBuilderTextField(
                          initialValue: snapshot['consult'],
                          attribute: 'docInput',
                          readonly: true,
                          maxLines: 8,
                          decoration: InputDecoration(
                              fillColor: Color.fromRGBO(255, 255, 255, 0.9),
                              filled: true,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none),
                          validators: [
                            //FormBuilderValidators.required(),
                          ],
                        ),
                  medicallUser.type == 'provider' && from == 'patients'
                      ? Row(
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
                      : SizedBox(
                          height: 10,
                        )
                ],
              ),
            ),
          ),
        );
      },
    );
    _controller.closed.whenComplete(() {
      if (mounted) {
        setState(() {
          isConsultOpen = false;
        });
      }
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
                    if (questions[i]['options'] is String) {
                      return ListTile(
                        title: Text(
                          questions[i]['question'],
                          style: TextStyle(fontSize: 14.0),
                        ),
                        subtitle: Text(
                          questions[i]['answer'],
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
                          questions[i]['answer']
                              .toString()
                              .replaceAll(']', '')
                              .replaceAll('[', '')
                              .replaceAll('null', '')
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
