import 'package:Medicall/Screens/History/chat.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/buildMedicalNote.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class HistoryDetailScreen extends StatefulWidget {
  final data;
  HistoryDetailScreen({Key key, @required this.data}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

bool isDone = false;

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormBuilderState> _consultFormKey = GlobalKey();
  TabController controller;
  int _currentIndex = 0;
  int _currentDetailsIndex = 0;
  Choice _selectedChoice;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;

  bool isConsultOpen = false;
  bool addedImages = false;
  bool addedQuestions = false;
  String buttonTxt = "Send Prescription";
  MedicallUser patientDetail;
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
    controller.addListener(_handleTabSelection);
    _getConsultDetail();
  }

  _handleTabSelection() {
    setState(() {
      _currentIndex = controller.index;
    });
  }

  _handleDetailsTabSelection(int index) {
    setState(() {
      this._currentDetailsIndex = index;
      if (index == 1) {
        addedImages = false;
      } else {
        addedQuestions = false;
        //_currentDetailsIndex = 1;
      }
    });
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
          isLoading = false;
          snapshot = datasnapshot.data;
          _getPatientDetail(snapshot['patient_id']);
          this.snapshot['details'] = [
            snapshot['medical_history_questions'],
            snapshot['screening_questions'],
            snapshot['media']
          ];
          //snapshot['prescription'] = [];
          if (snapshot['state'] == 'done') {
            isDone = true;
          } else {
            isDone = false;
          }
        });
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getPatientDetail(uid) async {
    final DocumentReference documentReference =
        Firestore.instance.collection('users').document(uid);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data != null) {
        setState(() {
          patientDetail = MedicallUser(
              address: datasnapshot.data['address'],
              displayName: datasnapshot.data['name'],
              dob: datasnapshot.data['dob'],
              gender: datasnapshot.data['gender'],
              phoneNumber: datasnapshot.data['phone']);
        });
      }
    }).catchError((e) => print(e));
  }

  Future<void> _updatePrescription() async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(documentId);
    Map<String, String> data = <String, String>{
      "prescription":
          _consultFormKey.currentState.fields['docInput'].currentState.value,
    };
    await documentReference.updateData(data).whenComplete(() {
      setState(() {
        isLoading = false;
        buttonTxt = 'Prescription Updated';
      });
      Future.delayed(const Duration(milliseconds: 2500), () {
        setState(() {
          buttonTxt = 'Send Prescription';
        });
      });
      print("Document Added");
    }).catchError((e) => print(e));
  }

  void _select(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
      final DocumentReference documentReference =
          Firestore.instance.collection('consults').document(documentId);
      documentReference.get().then((snap) {
        if (snap.documentID == documentId &&
            snap.data['provider_id'] == medicallUser.uid) {
          Map<String, dynamic> consultStateData;
          if (_selectedChoice.title == 'Done') {
            _selectedChoice.icon = Icon(Icons.check_box, color: Colors.green);
            consultStateData = {'state': 'done'};
          } else {
            _selectedChoice.icon = Icon(
              Icons.check_box_outline_blank,
              color: Colors.blue,
            );
            consultStateData = {'state': 'in progress'};
          }
          // if (snap.data['state'] == 'done') {
          //   consultStateData = {'state': 'in progress'};
          // }
          Navigator.pop(context);
          documentReference.updateData(consultStateData).whenComplete(() {
            setState(() {
              if (consultStateData['state'] == 'done') {
                isDone = true;
                if (_currentIndex != 0) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    controller.index = 0;
                  });
                }
              } else {
                isDone = false;
                if (_currentIndex != 0) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    controller.index = 0;
                  });
                } else {
                  //controller.index = 3;
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.index = 0;
                  });
                }
              }
            });
            print("Document Added");
          }).catchError((e) => print(e));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Choice> choices = <Choice>[
      Choice(
          title: 'Done',
          icon: isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
      Choice(
          title: 'Active',
          icon: !isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
    ];

    // The app's "state".

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: _select,
            initialValue: _selectedChoice,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Container(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[Text(choice.title), choice.icon],
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  snapshot != null &&
                          from == 'consults' &&
                          snapshot['type'] != 'Lesion'
                      ? snapshot['type']
                      : snapshot != null &&
                              snapshot['type'] == 'Lesion' &&
                              medicallUser.type == 'patient'
                          ? 'Spot'
                          : snapshot != null && from == 'patients'
                              ? '${snapshot['patient'].split(" ")[0][0].toUpperCase()}${snapshot['patient'].split(" ")[0].substring(1)} ${snapshot['patient'].split(" ")[1][0].toUpperCase()}${snapshot['patient'].split(" ")[1].substring(1)} '
                              : '',
                  style: TextStyle(
                    fontSize: Theme.of(context).platform == TargetPlatform.iOS
                        ? 17.0
                        : 20.0,
                  ),
                ),
                Text(
                  snapshot != null &&
                          from == 'consults' &&
                          medicallUser.type == 'patient'
                      ? '${snapshot['provider'].split(" ")[0][0].toUpperCase()}${snapshot['provider'].split(" ")[0].substring(1)} ${snapshot['provider'].split(" ")[1][0].toUpperCase()}${snapshot['provider'].split(" ")[1].substring(1)} ' +
                          snapshot['providerTitles']
                      : snapshot != null &&
                              from == 'consults' &&
                              medicallUser.type == 'provider'
                          ? '${snapshot['provider'].split(" ")[0][0].toUpperCase()}${snapshot['provider'].split(" ")[0].substring(1)} ${snapshot['provider'].split(" ")[1][0].toUpperCase()}${snapshot['provider'].split(" ")[1].substring(1)} ' +
                              snapshot['providerTitles']
                          : snapshot != null &&
                                  snapshot['type'] == 'Lesion' &&
                                  from == 'patients'
                              ? 'Spot'
                              : snapshot != null &&
                                      from == 'patients' &&
                                      snapshot['type'] != 'Lesion'
                                  ? snapshot['type']
                                  : '',
                  style: TextStyle(
                    fontSize: Theme.of(context).platform == TargetPlatform.iOS
                        ? 12.0
                        : 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 12),
          tabs: <Tab>[
            medicallUser.type == 'patient'
                ? Tab(
                    // set icon to the tab
                    text: 'Prescription',
                    icon: Icon(Icons.local_hospital),
                  )
                : Tab(
                    // set icon to the tab
                    text: 'Details',
                    icon: Icon(Icons.assignment),
                  ),
            Tab(
              // set icon to the tab
              text: 'Chat',
              icon: Icon(Icons.chat_bubble_outline),
            ),
            medicallUser.type == 'patient'
                ? Tab(
                    // set icon to the tab
                    text: 'Details',
                    icon: Icon(Icons.assignment),
                  )
                : Tab(
                    // set icon to the tab
                    text: 'Prescription',
                    icon: Icon(Icons.local_hospital),
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
      body: snapshot != null
          ? TabBarView(
              // Add tabs as widgets
              children: medicallUser.type == 'patient'
                  ? <Widget>[
                      _buildTab('prescription', 0),
                      _buildTab('chat', 1),
                      _buildTab('details', 2),
                    ]
                  : <Widget>[
                      _buildTab('details', 0),
                      _buildTab('chat', 1),
                      _buildTab('prescription', 2),
                    ],
              // set the controller
              controller: controller,
            )
          : null,
    );
  }

  _buildTab(key, ind) {
    var questions = snapshot[key];
    if (key == 'details') {
      return Scaffold(
        bottomNavigationBar: Container(
            child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[300], width: 1)),
          ),
          child: BottomNavigationBar(
            onTap: _handleDetailsTabSelection,
            elevation: 40.0,
            backgroundColor: Colors.transparent,
            unselectedItemColor: Colors.grey[500],
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            currentIndex:
                _currentDetailsIndex, // this will be set when a new tab is tapped
            items: medicallUser.type == 'patient'
                ? [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_ind),
                      title: Text('History'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.local_pharmacy),
                      title: Text('Symptom'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.perm_media),
                      title: Text('Pictures'),
                    )
                  ]
                : [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_ind),
                      title: Text('Medical Note'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.perm_media),
                      title: Text('Pictures'),
                    )
                  ],
          ),
        )),
        body: Container(
          child: questions[0].toString().contains('https')
              ? CarouselSlider(
                  height: 400.0,
                  items: questions.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(color: Colors.amber),
                            child: Image(
                              image: CachedNetworkImageProvider(i),
                            ));
                      },
                    );
                  }).toList(),
                )
              : ListView.builder(
                  itemCount: this.snapshot['details'] != null
                      ? this.snapshot['details'].length
                      : 3,
                  itemBuilder: (context, i) {
                    List<Widget> finalArray = [];
                    if (medicallUser.type == 'patient') {
                      if (_currentDetailsIndex == i) {
                        for (var y = 0;
                            y < this.snapshot['details'][i].length;
                            y++) {
                          if (i != 2) {
                            if (this.snapshot['details'][i][y]['visible'] &&
                                this.snapshot['details'][i][y]['options']
                                    is String) {
                              finalArray.add(ListTile(
                                title: Text(
                                  this.snapshot['details'][i][y]['question'],
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                subtitle: Text(
                                  this.snapshot['details'][i][y]['answer'],
                                  style: TextStyle(
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ));
                            } else {
                              finalArray
                                  .add(this.snapshot['details'][i][y]['visible']
                                      ? ListTile(
                                          title: Text(
                                            this.snapshot['details'][i][y]
                                                ['question'],
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                          subtitle: Text(
                                            this
                                                .snapshot['details'][i][y]
                                                    ['answer']
                                                .toString()
                                                .replaceAll(']', '')
                                                .replaceAll('[', '')
                                                .replaceAll('null', '')
                                                .replaceFirst(', ', ''),
                                            style: TextStyle(
                                                height: 1.2,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          ),
                                        )
                                      : SizedBox());
                            }
                          } else {
                            if (ind == i && y == 0 && i == 2) {
                              if (_currentDetailsIndex == 2) {
                                List<dynamic> thisList = this
                                    .snapshot['details'][i]
                                    .map((f) => (CachedNetworkImageProvider(f)))
                                    .toList();
                                //print(this.snapshot['details'][i]);
                                finalArray.add(CarouselSlider(
                                  height: 400.0,
                                  items: thisList.map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            decoration: BoxDecoration(
                                                color: Colors.amber),
                                            child: Text(
                                              ' $i',
                                              style: TextStyle(fontSize: 16.0),
                                            ));
                                      },
                                    );
                                  }).toList(),
                                ));
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (i == 0 && _currentDetailsIndex == 0 && ind == 0) {
                        if (this.patientDetail != null) {
                          finalArray.add(ListTile(
                            title: Text(
                              buildMedicalNote(
                                  this.snapshot, this.patientDetail),
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ));
                        }
                      }

                      for (var y = 0;
                          y < this.snapshot['details'][i].length;
                          y++) {
                        if (_currentDetailsIndex == 1 && !addedQuestions) {
                          addedQuestions = true;
                        }
                        if (i == 2 &&
                            _currentDetailsIndex == 1 &&
                            !addedImages) {
                          List<String> urlImgs = [
                            ...this.snapshot['details'][i]
                          ];
                          //print(this.snapshot['details'][i]);
                          finalArray.add(CarouselWithIndicator(
                            imgList: urlImgs,
                          ));
                          addedImages = true;
                        }
                      }
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: finalArray,
                    );
                  }),
        ),
      );
    }
    if (medicallUser.type == 'patient' && key == 'prescription') {
      return Scaffold(
          body: Container(
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                  child: FormBuilder(
                    key: _consultFormKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Rx',
                            style: TextStyle(
                                fontSize: 24, fontFamily: 'MedicallApp'),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: FormBuilderTextField(
                            initialValue: snapshot['prescription'].length > 0
                                ? snapshot['prescription']
                                : '',
                            attribute: 'docInput',
                            maxLines: 10,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText:
                                  'This is where your presciption will show up. If a doctor prescribes something, you will be notified and asked here for payment and shipment address.',
                              fillColor: snapshot['prescription'].length > 0
                                  ? Colors.green.withAlpha(30)
                                  : Colors.grey.withAlpha(50),
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 5.0),
                              ),
                            ),
                            validators: [
                              //FormBuilderValidators.required(),
                            ],
                          ),
                        ),
                        snapshot['prescription'].length > 0
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
                                    child: FormBuilderCheckboxList(
                                      leadingInput: true,
                                      attribute: 'shipTo',
                                      validators: [
                                        FormBuilderValidators.required(),
                                      ],
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              0, 10, 0, 10)),
                                      onChanged: null,
                                      options: [
                                        FormBuilderFieldOption(
                                          value: 'pickup',
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Local pharmacy pickup',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                                softWrap: true,
                                              ),
                                              Text(
                                                '\$80',
                                                style: TextStyle(fontSize: 21),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FormBuilderFieldOption(
                                          value: 'delivery',
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Ship directly to my door.',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                                softWrap: true,
                                              ),
                                              Text(
                                                '\$60',
                                                style: TextStyle(fontSize: 21),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                        'Please enter the address below where you want your prescription sent.'),
                                  ),
                                  FormBuilderTextField(
                                    attribute: "Address",
                                    initialValue: medicallUser.address,
                                    decoration: InputDecoration(
                                        labelText: 'Street Address',
                                        fillColor:
                                            Color.fromRGBO(35, 179, 232, 0.1),
                                        filled: true,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        border: InputBorder.none),
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  FormBuilderTextField(
                                    attribute: "City",
                                    decoration: InputDecoration(
                                        labelText: 'City',
                                        fillColor:
                                            Color.fromRGBO(35, 179, 232, 0.1),
                                        filled: true,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        border: InputBorder.none),
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  FormBuilderTextField(
                                    attribute: "State",
                                    decoration: InputDecoration(
                                        labelText: 'State',
                                        fillColor:
                                            Color.fromRGBO(35, 179, 232, 0.1),
                                        filled: true,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        border: InputBorder.none),
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                  )
                                ],
                              )
                            : SizedBox()
                      ],
                    ),
                  ))),
          bottomSheet: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              snapshot['prescription'].length > 0
                  ? Expanded(
                      child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                  style: BorderStyle.solid))),
                      child: FlatButton(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {},
                        child: Text(
                          'Pay for Presciption',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onBackground,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ))
                  : SizedBox()
            ],
          ));
    }
    if (medicallUser.type == 'provider' && key == 'prescription') {
      return Scaffold(
          body: Container(
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                  child: FormBuilder(
                    key: _consultFormKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        this.patientDetail != null
                            ? Column(
                                children: <Widget>[
                                  Text(this.patientDetail.displayName + ' '),
                                  Text(this.patientDetail.dob + ' '),
                                  Text(this.patientDetail.address),
                                ],
                              )
                            : Container(),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Text(
                            'Rx',
                            style: TextStyle(
                                fontSize: 24, fontFamily: 'MedicallApp'),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: FormBuilderTextField(
                            initialValue: snapshot['prescription'].length > 0
                                ? snapshot['prescription']
                                : '',
                            attribute: 'docInput',
                            maxLines: 10,
                            readOnly:
                                snapshot['state'] == 'done' ? true : false,
                            decoration: InputDecoration(
                              hintText:
                                  'This is where you can provide a prescription to your patient.',
                              fillColor: snapshot['state'] == 'done'
                                  ? Colors.grey.withAlpha(30)
                                  : Color.fromRGBO(35, 179, 232, 0.1),
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 5.0),
                              ),
                            ),
                            validators: [
                              //FormBuilderValidators.required(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))),
          bottomSheet: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.grey,
                            width: 1,
                            style: BorderStyle.solid))),
                child: FlatButton(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  color: buttonTxt.contains('Send')
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.green,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await _updatePrescription();
                  },
                  child: !isLoading
                      ? Text(
                          buttonTxt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onBackground,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                ),
              ))
            ],
          ));
    }
    if (key == 'chat') {
      return Chat(
        peerId: documentId,
        peerAvatar: isDone,
      );
    }
  }
}

class Choice {
  Choice({this.title, this.icon});

  final String title;
  Icon icon;
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class CarouselWithIndicator extends StatefulWidget {
  final List<String> imgList;
  CarouselWithIndicator({Key key, @required this.imgList}) : super(key: key);
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        viewportFraction: 1.0,
        items: widget.imgList.map(
          (url) {
            return Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
                child: CachedNetworkImage(
                  imageUrl: url,
                ),
              ),
            );
          },
        ).toList(),
        autoPlay: false,
        enlargeCenterPage: true,
        onPageChanged: (index) {
          setState(() {
            _current = index;
          });
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: map<Widget>(
          widget.imgList,
          (index, url) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? Color.fromRGBO(0, 0, 0, 0.9)
                      : Color.fromRGBO(0, 0, 0, 0.4)),
            );
          },
        ),
      ),
    ]);
  }
}
