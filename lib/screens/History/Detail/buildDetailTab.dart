import 'package:Medicall/common_widgets/carousel/carousel_with_indicator.dart';
import 'package:Medicall/common_widgets/chat/chat.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/History/Detail/prescriptionPayment.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/build_medical_note.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildDetailTab extends StatefulWidget {
  final keyStr;
  final bool isDone;
  final indx;
  BuildDetailTab({Key key, this.keyStr, this.indx, this.isDone})
      : super(key: key);

  @override
  _BuildDetailTabState createState() => _BuildDetailTabState();
}

class _BuildDetailTabState extends State<BuildDetailTab> {
  int currentDetailsIndex = 0;
  List<dynamic> addressList = [];
  ValueChanged onChangedCheckBox;
  bool addedImages = false;
  bool addedQuestions = false;
  String buttonTxt = "Send Prescription";
  bool isDone = false;
  final GlobalKey<FormBuilderState> consultFormKey =
      GlobalKey<FormBuilderState>();
  final _scrollController = ScrollController();
  Database db;
  User medicallUser;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    db = Provider.of<Database>(context);
    medicallUser = Provider.of<UserProvider>(context).user;
    if (currentDetailsIndex == 0) {
      db.getPatientMedicalHistory(medicallUser);
    }
    var key = widget.keyStr.toString();
    var ind = widget.indx;
    var consultSnapshot = db.consultSnapshot.data;
    List<String> mediaList = [];
    consultSnapshot['details'] = [
      consultSnapshot['screening_questions'],
      consultSnapshot['media']
    ];
    for (var i = 0; i < consultSnapshot['media'].length; i++) {
      mediaList.add(consultSnapshot['media'][i]);
    }
    var units = ['Capsule', 'Ointment', 'Cream', 'Solution', 'Foam'];
    if (key == 'Educational Information') {
      return Scaffold(
        appBar: AppBar(
          title: Text('Educational Information'),
          centerTitle: true,
        ),
        body: consultSnapshot.containsKey('education')
            ? ListView.builder(
                itemCount: consultSnapshot['education'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryVariant,
                      child: Icon(
                        Icons.web,
                      ),
                    ),
                    onTap: () async {
                      String url =
                          consultSnapshot['education'][index].split('-')[0];

                      if (await canLaunch(url)) {
                        await launch(
                          url,
                          forceSafariVC: true,
                          forceWebView: true,
                        );
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.primaryVariant,
                    ),
                    title: Text(
                      consultSnapshot['education'][index],
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryVariant),
                    ),
                  );
                })
            : Container(
                margin: EdgeInsets.all(20),
                child: Text(
                    'No education yet provided by your doctor, come back here to view educational information.'),
              ),
      );
    }
    if (key == 'Doctor Note') {
      return Scaffold(
        appBar: AppBar(
          title: Text(consultSnapshot['type'] == 'Lesion'
              ? 'Spot Doctor Notes'
              : consultSnapshot['type'] + ' ' + key.capitalize()),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FormBuilder(
                key: consultFormKey,
                autovalidate: false,
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: FormBuilderTextField(
                                initialValue: consultSnapshot
                                            .containsKey('doctor_notes') &&
                                        consultSnapshot['doctor_notes'].length >
                                            0
                                    ? consultSnapshot['doctor_notes']
                                    : 'This is where any notes from your doctor will appear once they have reviewed your case.',
                                attribute: 'doctor_notes',
                                minLines: 3,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: '',
                                  alignLabelWithHint: true,
                                  labelStyle: TextStyle(color: Colors.black45),
                                  filled: false,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 5.0),
                                  ),
                                ),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: "Required field."),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
    if (key == 'details') {
      return Scaffold(
        appBar: AppBar(
          title: Text(consultSnapshot['type'] == 'Lesion'
              ? 'Spot Details'
              : consultSnapshot['type'] + ' ' + key.capitalize()),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55.0),
            child: BottomNavigationBar(
              onTap: _handleDetailsTabSelection,
              elevation: 20.0,
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onSecondary.withAlpha(150),
              selectedItemColor: Theme.of(context).colorScheme.onPrimary,
              currentIndex:
                  currentDetailsIndex, // this will be set when a new tab is tapped
              items: medicallUser.type == 'patient'
                  ? [
                      BottomNavigationBarItem(
                        icon: Container(),
                        backgroundColor: Colors.blue,
                        title: Text('Questions'),
                      ),
                      BottomNavigationBarItem(
                        icon: Container(),
                        title: Text('Pictures'),
                      )
                    ]
                  : [
                      BottomNavigationBarItem(
                        icon: Container(),
                        title: Text('Medical Note'),
                      ),
                      BottomNavigationBarItem(
                        icon: Container(),
                        title: Text('Pictures'),
                      )
                    ],
            ),
          ),
        ),
        body: FadeInPlace(
          3,
          Container(
            child: currentDetailsIndex == 1
                ? CarouselWithIndicator(imgList: mediaList, from: 'detailTab')
                : ListView.builder(
                    itemCount: consultSnapshot['details'] != null
                        ? consultSnapshot['details'].length
                        : 3,
                    itemBuilder: (context, i) {
                      List<Widget> finalArray = [];
                      if (medicallUser.type == 'patient') {
                        if (currentDetailsIndex == i) {
                          for (var y = 0;
                              y < consultSnapshot['details'][i].length;
                              y++) {
                            if (i != 2) {
                              if (consultSnapshot['details'][i][y]['visible'] &&
                                  consultSnapshot['details'][i][y]['options']
                                      is String) {
                                finalArray.add(ListTile(
                                  title: Text(
                                    consultSnapshot['details'][i][y]
                                        ['question'],
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  subtitle: Text(
                                    consultSnapshot['details'][i][y]['answer'],
                                    style: TextStyle(
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ));
                              } else {
                                finalArray.add(
                                    consultSnapshot['details'][i][y]['visible']
                                        ? ListTile(
                                            title: Text(
                                              consultSnapshot['details'][i][y]
                                                  ['question'],
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                            subtitle: Text(
                                              consultSnapshot['details'][i][y]
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
                                if (currentDetailsIndex == 2) {
                                  //print(consultSnapshot['details'][i]);
                                  List<String> urlImgs = [
                                    ...consultSnapshot['details'][i]
                                  ];
                                  //print(consultSnapshot['details'][i]);
                                  finalArray.add(CarouselWithIndicator(
                                      imgList: urlImgs, from: 'detailTab'));
                                }
                              }
                            }
                          }
                        }
                      } else {
                        if (i == 0 && currentDetailsIndex == 0 && ind == 0) {
                          finalArray.add(FutureBuilder(
                            future: db.getPatientDetail(medicallUser),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return ListTile(
                                  title: Text(
                                    buildMedicalNote(
                                        consultSnapshot,
                                        db.patientDetail,
                                        db.userMedicalRecord.data),
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ));
                        }

                        for (var y = 0;
                            y < consultSnapshot['details'][i].length;
                            y++) {
                          if (currentDetailsIndex == 1 && !addedQuestions) {
                            addedQuestions = true;
                          }
                          if (i == 2 &&
                              currentDetailsIndex == 1 &&
                              !addedImages) {
                            List<String> urlImgs = [
                              ...consultSnapshot['details'][i]
                            ];
                            //print(consultSnapshot['details'][i]);
                            if (y == 0) {
                              finalArray.add(CarouselWithIndicator(
                                  imgList: urlImgs, from: 'detailTab'));
                            }

                            //addedImages = true;
                          }
                        }
                      }

                      return FadeInPlace(
                        1.0,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: finalArray,
                        ),
                      );
                    }),
          ),
        ),
      );
    }
    if (key == 'Create Prescription') {
      return Scaffold(
        appBar: AppBar(
          title: Text(key.capitalize()),
          centerTitle: true,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 80),
              controller: _scrollController,
              child: FutureBuilder(
                future: db.getPatientDetail(medicallUser),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FadeInPlace(
                      3,
                      Column(
                        children: <Widget>[
                          FormBuilder(
                            key: consultFormKey,
                            autovalidate: false,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Patient name: ',
                                        ),
                                        Text('Date of birth: '),
                                        Text('Address: '),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '\n' +
                                              db.patientDetail.fullName
                                                  .split(' ')[0][0]
                                                  .toUpperCase() +
                                              db.patientDetail.fullName
                                                  .split(' ')[0]
                                                  .substring(1) +
                                              ' ' +
                                              db.patientDetail.fullName
                                                  .split(' ')[1][0]
                                                  .toUpperCase() +
                                              db.patientDetail.fullName
                                                  .split(' ')[1]
                                                  .substring(1),
                                        ),
                                        Text(db.patientDetail.dob),
                                        Text(db.consultSnapshot.data
                                                .containsKey('shipping_address')
                                            ? db.consultSnapshot
                                                .data['shipping_address']
                                                .replaceFirst(',', '\n')
                                            : db.patientDetail.mailingAddress
                                                .replaceFirst(',', '\n')),
                                      ],
                                    )
                                  ],
                                ),
                                consultSnapshot
                                            .containsKey('medication_name') &&
                                        consultSnapshot['medication_name']
                                                .length ==
                                            0 &&
                                        medicallUser.type == 'patient'
                                    ? Container(
                                        margin:
                                            EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withAlpha(50),
                                          border: Border.all(
                                              color: Colors.grey.withAlpha(100),
                                              style: BorderStyle.solid,
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        child: Text(
                                            'Once your doctor reviews the details and if a prescription is nessassary it will appear below. When you doctor fills out the form below we will ask you for address & payment below.'),
                                      )
                                    : Container(),
                                Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              20,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: FormBuilderTextField(
                                            initialValue: consultSnapshot
                                                        .containsKey(
                                                            'medication_name') &&
                                                    consultSnapshot[
                                                                'medication_name']
                                                            .length >
                                                        0
                                                ? consultSnapshot[
                                                    'medication_name']
                                                : '',
                                            attribute: 'medName',
                                            maxLines: 1,
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                  color: Colors.black45),
                                              labelText: 'Medication Name',
                                              hintText:
                                                  'Enter patient\'s medication name',
                                              fillColor:
                                                  consultSnapshot['state'] ==
                                                              'done' ||
                                                          medicallUser.type ==
                                                              'patient' ||
                                                          consultSnapshot
                                                              .containsKey(
                                                                  'pay_date')
                                                      ? Colors.grey
                                                          .withAlpha(30)
                                                      : Color.fromRGBO(
                                                          35, 179, 232, 0.1),
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 5.0),
                                              ),
                                            ),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                              FormBuilderValidators.minLength(4,
                                                  errorText:
                                                      "Medication name must have a minumum of four characters.")
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2 -
                                              10,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: FormBuilderTextField(
                                            initialValue: consultSnapshot
                                                        .containsKey(
                                                            'quantity') &&
                                                    consultSnapshot['quantity']
                                                            .length >
                                                        0
                                                ? consultSnapshot['quantity']
                                                : '0',
                                            attribute: 'quantity',
                                            maxLines: 1,
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                  color: Colors.black45),
                                              labelText: 'Quantity',
                                              hintText: '',
                                              fillColor:
                                                  consultSnapshot['state'] ==
                                                              'done' ||
                                                          medicallUser.type ==
                                                              'patient' ||
                                                          consultSnapshot
                                                              .containsKey(
                                                                  'pay_date')
                                                      ? Colors.grey
                                                          .withAlpha(30)
                                                      : Color.fromRGBO(
                                                          35, 179, 232, 0.1),
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 5.0),
                                              ),
                                            ),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                              FormBuilderValidators.min(1,
                                                  errorText:
                                                      "Minimum quantity of 1."),
                                              FormBuilderValidators.max(10,
                                                  errorText:
                                                      "Maximum quantity of 10.")
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2 -
                                              10,
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          child: FormBuilderDropdown(
                                            isExpanded: true,
                                            initialValue: consultSnapshot
                                                    .containsKey('refills')
                                                ? consultSnapshot['refills']
                                                : 0,
                                            attribute: "refills",
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            iconSize:
                                                medicallUser.type == 'patient'
                                                    ? 0
                                                    : 24,
                                            decoration: InputDecoration(
                                                alignLabelWithHint: true,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 9, 5, 9),
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                                labelText: 'Refills',
                                                fillColor: consultSnapshot[
                                                                'state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot
                                                            .containsKey(
                                                                'pay_date')
                                                    ? Colors.grey.withAlpha(30)
                                                    : Color.fromRGBO(
                                                        35, 179, 232, 0.1),
                                                filled: true,
                                                disabledBorder:
                                                    InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                border: InputBorder.none),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                            ],
                                            isDense: true,
                                            items: Iterable<int>.generate(10)
                                                .map((unit) => DropdownMenuItem(
                                                      value: unit,
                                                      child: Text('$unit'),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              20,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: FormBuilderDropdown(
                                            isExpanded: true,
                                            initialValue: consultSnapshot
                                                        .containsKey('units') &&
                                                    consultSnapshot['units']
                                                            .length >
                                                        0
                                                ? consultSnapshot['units']
                                                : 'Capsule',
                                            attribute: "units",
                                            iconSize:
                                                medicallUser.type == 'patient'
                                                    ? 0
                                                    : 24,
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        5, 9, 5, 9),
                                                labelStyle: TextStyle(
                                                    color: Colors.black45),
                                                labelText: 'Units',
                                                fillColor: consultSnapshot[
                                                                'state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot
                                                            .containsKey(
                                                                'pay_date')
                                                    ? Colors.grey.withAlpha(30)
                                                    : Color.fromRGBO(
                                                        35, 179, 232, 0.1),
                                                filled: true,
                                                disabledBorder:
                                                    InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                border: InputBorder.none),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                            ],
                                            items: units
                                                .map((unit) => DropdownMenuItem(
                                                      value: unit,
                                                      child: Text('$unit'),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2 -
                                              10,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: FormBuilderTextField(
                                            initialValue: consultSnapshot
                                                        .containsKey('dose') &&
                                                    consultSnapshot['dose']
                                                            .length >
                                                        0
                                                ? consultSnapshot['dose']
                                                : '',
                                            attribute: 'dose',
                                            maxLines: 1,
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            decoration: InputDecoration(
                                              labelText: 'Dose',
                                              labelStyle: TextStyle(
                                                  color: Colors.black45),
                                              fillColor:
                                                  consultSnapshot['state'] ==
                                                              'done' ||
                                                          medicallUser.type ==
                                                              'patient' ||
                                                          consultSnapshot
                                                              .containsKey(
                                                                  'pay_date')
                                                      ? Colors.grey
                                                          .withAlpha(30)
                                                      : Color.fromRGBO(
                                                          35, 179, 232, 0.1),
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 5.0),
                                              ),
                                            ),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2 -
                                              10,
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          child: FormBuilderTextField(
                                            initialValue: consultSnapshot
                                                        .containsKey(
                                                            'frequency') &&
                                                    consultSnapshot['frequency']
                                                            .length >
                                                        0
                                                ? consultSnapshot['frequency']
                                                : '',
                                            attribute: 'frequency',
                                            maxLines: 1,
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            decoration: InputDecoration(
                                              labelText: 'Frequency',
                                              labelStyle: TextStyle(
                                                  color: Colors.black45),
                                              fillColor:
                                                  consultSnapshot['state'] ==
                                                              'done' ||
                                                          medicallUser.type ==
                                                              'patient' ||
                                                          consultSnapshot
                                                              .containsKey(
                                                                  'pay_date')
                                                      ? Colors.grey
                                                          .withAlpha(30)
                                                      : Color.fromRGBO(
                                                          35, 179, 232, 0.1),
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 5.0),
                                              ),
                                            ),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              20,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: FormBuilderTextField(
                                            initialValue: consultSnapshot
                                                        .containsKey(
                                                            'instructions') &&
                                                    consultSnapshot[
                                                                'instructions']
                                                            .length >
                                                        0
                                                ? consultSnapshot[
                                                    'instructions']
                                                : '',
                                            attribute: 'instructions',
                                            maxLines: 3,
                                            readOnly:
                                                consultSnapshot['state'] ==
                                                            'done' ||
                                                        medicallUser.type ==
                                                            'patient' ||
                                                        consultSnapshot[
                                                                'pay_date'] !=
                                                            null
                                                    ? true
                                                    : false,
                                            decoration: InputDecoration(
                                              labelText: 'Instructions',
                                              labelStyle: TextStyle(
                                                  color: Colors.black45),
                                              fillColor:
                                                  consultSnapshot['state'] ==
                                                              'done' ||
                                                          medicallUser.type ==
                                                              'patient' ||
                                                          consultSnapshot
                                                              .containsKey(
                                                                  'pay_date')
                                                      ? Colors.grey
                                                          .withAlpha(30)
                                                      : Color.fromRGBO(
                                                          35, 179, 232, 0.1),
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 5.0),
                                              ),
                                            ),
                                            validators: [
                                              FormBuilderValidators.required(
                                                  errorText: "Required field."),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    medicallUser.type == 'provider' &&
                                            consultSnapshot['pay_date'] ==
                                                null &&
                                            consultSnapshot['state'] != 'done'
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                  child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        top: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1,
                                                            style: BorderStyle
                                                                .solid))),
                                                child: FlatButton(
                                                  padding: EdgeInsets.fromLTRB(
                                                      20, 20, 20, 20),
                                                  color:
                                                      buttonTxt.contains('Send')
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                          : Colors.green,
                                                  onPressed: () async {
                                                    await prescriptionButtonPressed(
                                                        context);
                                                  },
                                                  child: Text(
                                                    buttonTxt,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      letterSpacing: 1.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            ],
                                          )
                                        : Container(),
                                    FutureBuilder(
                                        future:
                                            db.getPatientDetail(medicallUser),
                                        builder: (BuildContext context,
                                            AsyncSnapshot snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return PrescriptionPayment(
                                              pageScrollCtrl:
                                                  this._scrollController,
                                              scriptData:
                                                  this.db.consultSnapshot.data,
                                            );
                                          } else {
                                            return Container();
                                          }
                                        })
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              )),
        ),
      );
    }
    return Chat(
      isDone: widget.isDone,
    );
  }

  Future prescriptionButtonPressed(BuildContext context) async {
    if (consultFormKey.currentState.saveAndValidate()) {
      await db.updatePrescription(consultFormKey).then((val) {
        setState(() {
          buttonTxt = 'Prescription Updated';
        });
        Navigator.of(context).pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text("Prescription Submitted"),
              content: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          "We have sent your prescription to the patient, they will be notified. Once they review and pay, the prescription will be updated."),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: Text("Continue"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
        Future.delayed(const Duration(milliseconds: 2500), () {
          buttonTxt = 'Send Prescription';
        });
      });
    }
  }

  _handleDetailsTabSelection(int index) async {
    currentDetailsIndex = index;

    setState(() {
      if (index == 1) {
        addedImages = false;
      } else {
        addedQuestions = false;
        //currentDetailsIndex = 1;
      }
    });
  }
}
