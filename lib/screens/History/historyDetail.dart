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
  bool isLoading = true;

  bool isConsultOpen = false;
  bool addedImages = false;
  bool addedQuestions = false;
  String buttonTxt = "Send Prescription";
  MedicallUser patientDetail;
  String documentId;
  String from;
  var consultSnapshot;

  @override
  initState() {
    super.initState();
    documentId = widget.data['documentId'];
    medicallUser = widget.data['user'];
    from = widget.data['from'];
    controller = TabController(length: 3, vsync: this);
    controller.addListener(_handleTabSelection);
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
    await documentReference.get().then((datasnapshot) async {
      if (datasnapshot.data != null) {
        isLoading = false;
        consultSnapshot = datasnapshot.data;
        this.consultSnapshot['details'] = [
          consultSnapshot['medical_history_questions'],
          consultSnapshot['screening_questions'],
          consultSnapshot['media']
        ];
        if (consultSnapshot['state'] == 'done') {
          isDone = true;
        } else {
          isDone = false;
        }
        //await _getPatientDetail(consultSnapshot['patient_id']);
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getPatientDetail() async {
    final DocumentReference documentReference = Firestore.instance
        .collection('users')
        .document(this.widget.data['patient_id']);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data != null) {
        patientDetail = MedicallUser(
            address: datasnapshot.data['address'],
            displayName: datasnapshot.data['name'],
            dob: datasnapshot.data['dob'],
            gender: datasnapshot.data['gender'],
            phoneNumber: datasnapshot.data['phone']);
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
    return FutureBuilder<List<void>>(
      future: Future.wait([
        _getConsultDetail(),
        _getPatientDetail(),
      ]), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return Scaffold(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(choice.title),
                                  choice.icon
                                ],
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
                            consultSnapshot != null &&
                                    from == 'consults' &&
                                    consultSnapshot['type'] != 'Lesion'
                                ? consultSnapshot['type']
                                : consultSnapshot != null &&
                                        consultSnapshot['type'] == 'Lesion' &&
                                        medicallUser.type == 'patient'
                                    ? 'Spot'
                                    : consultSnapshot != null &&
                                            from == 'patients'
                                        ? '${consultSnapshot['patient'].split(" ")[0][0].toUpperCase()}${consultSnapshot['patient'].split(" ")[0].substring(1)} ${consultSnapshot['patient'].split(" ")[1][0].toUpperCase()}${consultSnapshot['patient'].split(" ")[1].substring(1)} '
                                        : '',
                            style: TextStyle(
                              fontSize: Theme.of(context).platform ==
                                      TargetPlatform.iOS
                                  ? 17.0
                                  : 20.0,
                            ),
                          ),
                          Text(
                            consultSnapshot != null &&
                                    from == 'consults' &&
                                    medicallUser.type == 'patient'
                                ? '${consultSnapshot['provider'].split(" ")[0][0].toUpperCase()}${consultSnapshot['provider'].split(" ")[0].substring(1)} ${consultSnapshot['provider'].split(" ")[1][0].toUpperCase()}${consultSnapshot['provider'].split(" ")[1].substring(1)} ' +
                                    consultSnapshot['providerTitles']
                                : consultSnapshot != null &&
                                        from == 'consults' &&
                                        medicallUser.type == 'provider'
                                    ? '${consultSnapshot['provider'].split(" ")[0][0].toUpperCase()}${consultSnapshot['provider'].split(" ")[0].substring(1)} ${consultSnapshot['provider'].split(" ")[1][0].toUpperCase()}${consultSnapshot['provider'].split(" ")[1].substring(1)} ' +
                                        consultSnapshot['providerTitles']
                                    : consultSnapshot != null &&
                                            consultSnapshot['type'] ==
                                                'Lesion' &&
                                            from == 'patients'
                                        ? 'Spot'
                                        : consultSnapshot != null &&
                                                from == 'patients' &&
                                                consultSnapshot['type'] !=
                                                    'Lesion'
                                            ? consultSnapshot['type']
                                            : '',
                            style: TextStyle(
                              fontSize: Theme.of(context).platform ==
                                      TargetPlatform.iOS
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
                    tabs: medicallUser.type == 'patient'
                        ? <Tab>[
                            Tab(
                              // set icon to the tab
                              text: 'Prescription',
                              icon: Icon(Icons.local_hospital),
                            ),
                            Tab(
                              // set icon to the tab
                              text: 'Chat',
                              icon: Icon(Icons.chat_bubble_outline),
                            ),
                            Tab(
                              // set icon to the tab
                              text: 'Details',
                              icon: Icon(Icons.assignment),
                            ),
                          ]
                        : <Tab>[
                            Tab(
                              // set icon to the tab
                              text: 'Details',
                              icon: Icon(Icons.assignment),
                            ),
                            Tab(
                              // set icon to the tab
                              text: 'Chat',
                              icon: Icon(Icons.chat_bubble_outline),
                            ),
                            Tab(
                              // set icon to the tab
                              text: 'Prescription',
                              icon: Icon(Icons.local_hospital),
                            ),
                          ],
                    // setup the controller
                    controller: controller,
                  ),
                  elevation: Theme.of(context).platform == TargetPlatform.iOS
                      ? 0.0
                      : 4.0,
                  leading: WillPopScope(
                    onWillPop: () async {
                      Navigator.pushNamed(context, '/history');
                      return false;
                    },
                    child: BackButton(),
                  ),
                ),
                body: medicallUser.type == 'patient' && consultSnapshot != null
                    ? TabBarView(
                        // Add tabs as widgets
                        children: <Widget>[
                          _buildTab('prescription', 0),
                          _buildTab('chat', 1),
                          _buildTab('details', 2),
                        ],
                        // set the controller
                        controller: controller,
                      )
                    : TabBarView(
                        children: <Widget>[
                          _buildTab('details', 0),
                          _buildTab('chat', 1),
                          _buildTab('prescription', 2),
                        ],
                        controller: controller,
                      ),
              );
        }
      },
    );
  }

  _buildTab(key, ind) {
    if (consultSnapshot != null) {
      var questions = consultSnapshot[key];
      if (key == 'details') {
        return Scaffold(
          bottomNavigationBar: Container(
              child: Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: Colors.grey[300], width: 1)),
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
                ? CarouselWithIndicator(
                    imgList: this.consultSnapshot['details'],
                  )
                : ListView.builder(
                    itemCount: this.consultSnapshot['details'] != null
                        ? this.consultSnapshot['details'].length
                        : 3,
                    itemBuilder: (context, i) {
                      List<Widget> finalArray = [];
                      if (medicallUser.type == 'patient') {
                        if (_currentDetailsIndex == i) {
                          for (var y = 0;
                              y < this.consultSnapshot['details'][i].length;
                              y++) {
                            if (i != 2) {
                              if (this.consultSnapshot['details'][i][y]
                                      ['visible'] &&
                                  this.consultSnapshot['details'][i][y]
                                      ['options'] is String) {
                                finalArray.add(ListTile(
                                  title: Text(
                                    this.consultSnapshot['details'][i][y]
                                        ['question'],
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  subtitle: Text(
                                    this.consultSnapshot['details'][i][y]
                                        ['answer'],
                                    style: TextStyle(
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ));
                              } else {
                                finalArray.add(this.consultSnapshot['details']
                                        [i][y]['visible']
                                    ? ListTile(
                                        title: Text(
                                          this.consultSnapshot['details'][i][y]
                                              ['question'],
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                        subtitle: Text(
                                          this
                                              .consultSnapshot['details'][i][y]
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
                                  //print(this.consultSnapshot['details'][i]);
                                  List<String> urlImgs = [
                                    ...this.consultSnapshot['details'][i]
                                  ];
                                  //print(this.consultSnapshot['details'][i]);
                                  finalArray.add(CarouselWithIndicator(
                                    imgList: urlImgs,
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
                                    this.consultSnapshot, this.patientDetail),
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ));
                          }
                        }

                        for (var y = 0;
                            y < this.consultSnapshot['details'][i].length;
                            y++) {
                          if (_currentDetailsIndex == 1 && !addedQuestions) {
                            addedQuestions = true;
                          }
                          if (i == 2 &&
                              _currentDetailsIndex == 1 &&
                              !addedImages) {
                            List<String> urlImgs = [
                              ...this.consultSnapshot['details'][i]
                            ];
                            //print(this.consultSnapshot['details'][i]);
                            if (y == 0) {
                              finalArray.add(CarouselWithIndicator(
                                imgList: urlImgs,
                              ));
                            }

                            //addedImages = true;
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
                              initialValue: consultSnapshot
                                          .containsKey('prescription') &&
                                      consultSnapshot['prescription'].length > 0
                                  ? consultSnapshot['prescription']
                                  : '',
                              attribute: 'docInput',
                              maxLines: 10,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText:
                                    'This is where your presciption will show up. If a doctor prescribes something, you will be notified and asked here for payment and shipment address.',
                                fillColor: consultSnapshot
                                            .containsKey('prescription') &&
                                        consultSnapshot['prescription'].length >
                                            0
                                    ? Colors.green.withAlpha(30)
                                    : Colors.grey.withAlpha(50),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 5.0),
                                ),
                              ),
                              validators: [
                                //FormBuilderValidators.required(),
                              ],
                            ),
                          ),
                          consultSnapshot.containsKey('prescription') &&
                                  consultSnapshot['prescription'].length > 0
                              ? Column(
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 20, 10),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  style:
                                                      TextStyle(fontSize: 21),
                                                ),
                                              ],
                                            ),
                                          ),
                                          FormBuilderFieldOption(
                                            value: 'delivery',
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  style:
                                                      TextStyle(fontSize: 21),
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
                consultSnapshot.containsKey('prescription') &&
                        consultSnapshot['prescription'].length > 0
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
      if (medicallUser.type == 'provider' &&
          key == 'prescription' &&
          consultSnapshot['prescription'] != null) {
        return Scaffold(
            body: Container(
                child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: FormBuilder(
                      key: _consultFormKey,
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          this.patientDetail != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Patient name: ' +
                                        this.patientDetail.displayName +
                                        ' '),
                                    Text('Date of birth: ' +
                                        this.patientDetail.dob +
                                        ' '),
                                    Text('Address: ' +
                                        this.patientDetail.address),
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
                              initialValue:
                                  consultSnapshot['prescription'].length > 0
                                      ? consultSnapshot['prescription']
                                      : '',
                              attribute: 'docInput',
                              maxLines: 10,
                              readOnly: consultSnapshot['state'] == 'done'
                                  ? true
                                  : false,
                              decoration: InputDecoration(
                                hintText:
                                    'This is where you can provide a prescription to your patient.',
                                fillColor: consultSnapshot['state'] == 'done'
                                    ? Colors.grey.withAlpha(30)
                                    : Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 5.0),
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
    } else {
      return Center(
        child: Container(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
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
        height: MediaQuery.of(context).size.height * 0.65,
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
