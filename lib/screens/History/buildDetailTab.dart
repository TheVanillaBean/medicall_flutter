import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/carouselWithIndicator.dart';
import 'package:Medicall/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:Medicall/Screens/History/chat.dart';
import 'package:Medicall/screens/History/buildMedicalNote.dart';
import 'package:Medicall/util/stripe_payment_handler.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:Medicall/secrets.dart' as secrets;
import 'package:google_maps_webservice/places.dart';

int currentDetailsIndex = 0;
List<dynamic> addressList = [];
ValueChanged onChangedCheckBox;
bool addedImages = false;
bool addedQuestions = false;
bool userShippingSelected = false;
String shippingAddress = '';
String shipTo = '';
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: secrets.kGoogleApiKey);
final TextEditingController typeAheadController = TextEditingController();
String buttonTxt = "Send Prescription";
bool isDone = false;
GlobalKey<FormBuilderState> consultFormKey = GlobalKey();

class BuildDetailTab extends StatefulWidget {
  final keyStr;
  final indx;
  BuildDetailTab({Key key, this.keyStr, this.indx}) : super(key: key);

  @override
  _BuildDetailTabState createState() => _BuildDetailTabState();
}

class _BuildDetailTabState extends State<BuildDetailTab> {
  var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
  @override
  Widget build(BuildContext context) {
    var key = widget.keyStr.toString();
    var ind = widget.indx;
    medicallUser = auth.medicallUser;
    var consultSnapshot = auth.consultSnapshot.data;
    var questions = consultSnapshot[key];
    var units = ['Capsule', 'Ointment', 'Cream', 'Solution', 'Foam'];
    if (key == 'details') {
      return Scaffold(
        bottomNavigationBar: Container(
            child: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[300], width: 1)),
          ),
          child: BottomNavigationBar(
            onTap: _handleDetailsTabSelection,
            elevation: 40.0,
            backgroundColor: Colors.transparent,
            unselectedItemColor: Colors.grey[500],
            selectedItemColor: Theme.of(GlobalNavigatorKey.key.currentContext)
                .colorScheme
                .secondary,
            currentIndex:
                currentDetailsIndex, // this will be set when a new tab is tapped
            items: auth.medicallUser.type == 'patient'
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
                  imgList: consultSnapshot['details'],
                )
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
                                  consultSnapshot['details'][i][y]['question'],
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
                                  imgList: urlImgs,
                                ));
                              }
                            }
                          }
                        }
                      }
                    } else {
                      if (i == 0 && currentDetailsIndex == 0 && ind == 0) {
                        finalArray.add(FutureBuilder(
                          future: auth.getPatientDetail(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return ListTile(
                                title: Text(
                                  buildMedicalNote(
                                      consultSnapshot, auth.patientDetail),
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
                padding: EdgeInsets.fromLTRB(15, 20, 15, 100),
                child: FormBuilder(
                  key: consultFormKey,
                  autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
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
                              consultSnapshot.containsKey('prescription') &&
                                      consultSnapshot['prescription'].length > 0
                                  ? consultSnapshot['prescription']
                                  : '',
                          attribute: 'docInput',
                          maxLines: 8,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText:
                                'This is where your presciption will show up. If a doctor prescribes something, you will be notified and asked here for payment and shipment address.',
                            fillColor: consultSnapshot
                                        .containsKey('prescription') &&
                                    consultSnapshot['prescription'].length > 0
                                ? Colors.lightGreen.withAlpha(120)
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
                      consultSnapshot.containsKey('prescription') &&
                              consultSnapshot['prescription'].length > 0
                          ? Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
                                  child: FormBuilderCheckboxList(
                                    leadingInput: true,
                                    attribute: 'shipTo',
                                    initialValue: [shipTo],
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                    onChanged: onChangedCheckBox,
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
                                Visibility(
                                    visible: userShippingSelected,
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: 10,
                                              bottom: 10,
                                            ),
                                            child: Text(
                                                'Please enter the address below where you want your prescription sent.'),
                                          ),
                                          TypeAheadFormField(
                                            hideOnEmpty: true,
                                            suggestionsBoxVerticalOffset: 5.0,
                                            hideOnError: true,
                                            suggestionsBoxDecoration:
                                                SuggestionsBoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                              onEditingComplete: () {
                                                if (addressList.length == 0) {
                                                  typeAheadController.clear();
                                                }
                                              },
                                              onSubmitted: (v) {
                                                if (addressList.length == 0) {
                                                  typeAheadController.clear();
                                                }
                                                if (addressList.indexOf(v) ==
                                                    -1) {
                                                  typeAheadController.clear();
                                                }
                                              },
                                              controller: typeAheadController,
                                              maxLines: 2,
                                              decoration: InputDecoration(
                                                  hintText: shipTo == 'delivery'
                                                      ? medicallUser.address
                                                      : '',
                                                  labelText: shipTo ==
                                                          'delivery'
                                                      ? 'Street Address'
                                                      : 'Local Pharmacy Address',
                                                  fillColor: Color.fromRGBO(
                                                      35, 179, 232, 0.1),
                                                  filled: true,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  border: InputBorder.none),
                                            ),
                                            suggestionsCallback:
                                                (pattern) async {
                                              addressList = [];
                                              if (pattern.length > 0) {
                                                return await _places
                                                    .searchByText(pattern)
                                                    .then((val) {
                                                  addressList.add(val.results
                                                      .first.formattedAddress);
                                                  return addressList;
                                                });
                                              } else {
                                                return addressList;
                                              }
                                            },
                                            itemBuilder: (context, suggestion) {
                                              return ListTile(
                                                title: Text(suggestion),
                                              );
                                            },
                                            transitionBuilder: (context,
                                                suggestionsBox, controller) {
                                              return suggestionsBox;
                                            },
                                            onSuggestionSelected: (suggestion) {
                                              shippingAddress = suggestion;
                                              typeAheadController.text =
                                                  suggestion;
                                            },
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter valid address';
                                              } else {
                                                if (addressList
                                                        .indexOf(value) ==
                                                    -1) {
                                                  typeAheadController.clear();
                                                } else {
                                                  shippingAddress = value;
                                                }
                                                return null;
                                              }
                                            },
                                            onSaved: (value) {
                                              shippingAddress = value;
                                            },
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          shippingAddress.length > 0
                                              ? FlatButton(
                                                  padding: EdgeInsets.fromLTRB(
                                                      20, 20, 20, 20),
                                                  color: Theme.of(
                                                          GlobalNavigatorKey.key
                                                              .currentContext)
                                                      .colorScheme
                                                      .secondary,
                                                  onPressed: () async {
                                                    if (auth.hasPayment) {
                                                      await PaymentService().chargePayment(
                                                          consultSnapshot[
                                                              'price'],
                                                          consultSnapshot[
                                                                  'consultType'] +
                                                              ' consult with ' +
                                                              consultSnapshot[
                                                                  'provider']);
                                                    } else {
                                                      await StripeSource
                                                              .addSource()
                                                          .then((String
                                                              token) async {
                                                        PaymentService()
                                                            .addCard(token);
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    auth.hasPayment
                                                        ? 'Pay for Presciption'
                                                        : 'Add Card',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Theme.of(
                                                              GlobalNavigatorKey
                                                                  .key
                                                                  .currentContext)
                                                          .colorScheme
                                                          .onBackground,
                                                      letterSpacing: 1.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ))
                              ],
                            )
                          : SizedBox()
                    ],
                  ),
                ))),
      );
    }
    if (medicallUser.type == 'provider' &&
        key == 'prescription' &&
        consultSnapshot['prescription'] != null) {
      return Scaffold(
          body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
              child: Column(
                children: <Widget>[
                  FormBuilder(
                    key: consultFormKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        auth.patientDetail != null
                            ? Row(
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
                                            auth.patientDetail.displayName
                                                .split(' ')[0][0]
                                                .toUpperCase() +
                                            auth.patientDetail.displayName
                                                .split(' ')[0]
                                                .substring(1) +
                                            ' ' +
                                            auth.patientDetail.displayName
                                                .split(' ')[1][0]
                                                .toUpperCase() +
                                            auth.patientDetail.displayName
                                                .split(' ')[1]
                                                .substring(1),
                                      ),
                                      Text(auth.patientDetail.dob),
                                      Text(auth.patientDetail.address
                                          .replaceFirst(',', '\n')),
                                    ],
                                  )
                                ],
                              )
                            : Container(),
                        Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                initialValue:
                                    consultSnapshot['prescription'].length > 0
                                        ? consultSnapshot['prescription']
                                        : '',
                                attribute: 'docInput',
                                maxLines: 1,
                                readOnly: consultSnapshot['state'] == 'done'
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Medication Name',
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
                        Row(
                          children: <Widget>[
                            Container(
                              width:
                                  MediaQuery.of(context).size.width / 3 - 6.7,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                // initialValue:
                                //     consultSnapshot['prescription'].length > 0
                                //         ? consultSnapshot['prescription']
                                //             ['quantity']
                                //         : '',
                                attribute: 'docInput',
                                maxLines: 1,
                                readOnly: consultSnapshot['state'] == 'done'
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
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
                            Container(
                              width:
                                  MediaQuery.of(context).size.width / 3 - 6.7,
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: FormBuilderDropdown(
                                attribute: "units",
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(9),
                                    labelText: 'Units',
                                    fillColor:
                                        Color.fromRGBO(35, 179, 232, 0.1),
                                    filled: true,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none),
                                validators: [
                                  //FormBuilderValidators.required(),
                                ],
                                items: units
                                    .map((unit) => DropdownMenuItem(
                                          value: unit,
                                          child: Text('$unit'),
                                        ))
                                    .toList(),
                              ),
                            ),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width / 3 - 6.7,
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: FormBuilderDropdown(
                                attribute: "refills",
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(9),
                                    labelText: 'Refills',
                                    fillColor:
                                        Color.fromRGBO(35, 179, 232, 0.1),
                                    filled: true,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none),
                                validators: [
                                  //FormBuilderValidators.required(),
                                ],
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
                              width: MediaQuery.of(context).size.width / 2 - 10,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                // initialValue:
                                //     consultSnapshot['prescription'].length > 0
                                //         ? consultSnapshot['prescription']
                                //         : '',
                                attribute: 'dose',
                                maxLines: 1,
                                readOnly: consultSnapshot['state'] == 'done'
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Dose',
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
                            Container(
                              width: MediaQuery.of(context).size.width / 2 - 10,
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: FormBuilderTextField(
                                // initialValue:
                                //     consultSnapshot['prescription'].length > 0
                                //         ? consultSnapshot['prescription']
                                //         : '',
                                attribute: 'frequency',
                                maxLines: 1,
                                readOnly: consultSnapshot['state'] == 'done'
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Frequency',
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
                        Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                // initialValue:
                                //     consultSnapshot['prescription'].length > 0
                                //         ? consultSnapshot['prescription']
                                //         : '',
                                attribute: 'instructions',
                                maxLines: 4,
                                readOnly: consultSnapshot['state'] == 'done'
                                    ? true
                                    : false,
                                decoration: InputDecoration(
                                  labelText: 'Instructions',
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
                      ],
                    ),
                  )
                ],
              )),
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
                      ? Theme.of(GlobalNavigatorKey.key.currentContext)
                          .colorScheme
                          .secondary
                      : Colors.green,
                  onPressed: () async {
                    await _updatePrescription();
                  },
                  child: Text(
                    buttonTxt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(GlobalNavigatorKey.key.currentContext)
                          .colorScheme
                          .onBackground,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ))
            ],
          ));
    }
    return Chat(
      peerId: auth.currConsultId,
      peerAvatar: isDone,
    );
  }

  Future<void> _updatePrescription() async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(auth.currConsultId);
    Map<String, String> data = <String, String>{
      "prescription":
          consultFormKey.currentState.fields['docInput'].currentState.value,
    };
    await documentReference.updateData(data).whenComplete(() {
      buttonTxt = 'Prescription Updated';
      Future.delayed(const Duration(milliseconds: 2500), () {
        buttonTxt = 'Send Prescription';
      });
      print("Prescription Updated");
    }).catchError((e) => print(e));
  }

  _handleDetailsTabSelection(int index) {
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
