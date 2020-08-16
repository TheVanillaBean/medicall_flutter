import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/History/Detail/prescriptionPayment.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class PrescriptionScreen extends StatefulWidget {
  final DocumentSnapshot snapshot;
  PrescriptionScreen({Key key, @required this.snapshot}) : super(key: key);

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _scrollController = ScrollController();
  Database db;
  User medicallUser;
  final GlobalKey<FormBuilderState> consultFormKey =
      GlobalKey<FormBuilderState>();
  String buttonTxt = "Send Prescription";
  @override
  Widget build(BuildContext context) {
    db = Provider.of<Database>(context);
    medicallUser = Provider.of<UserProvider>(context).user;
    var units = ['Capsule', 'Ointment', 'Cream', 'Solution', 'Foam'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snapshot.data['medication_name']),
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
            child: FadeInPlace(
              3,
              Column(
                children: <Widget>[
                  FormBuilder(
                    key: consultFormKey,
                    autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        db.patientDetail != null &&
                                medicallUser.type == 'provider'
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
                                      Text(widget.snapshot.data.containsKey(
                                                  'shipping_address') &&
                                              widget.snapshot.data[
                                                      'shipping_address'] !=
                                                  null
                                          ? widget
                                              .snapshot.data['shipping_address']
                                              .replaceFirst(',', '\n')
                                          : db.patientDetail.mailingAddress
                                              .replaceFirst(',', '\n')),
                                    ],
                                  )
                                ],
                              )
                            : Container(),
                        widget.snapshot.data.containsKey('medication_name') &&
                                widget.snapshot.data['medication_name']
                                        .length ==
                                    0 &&
                                medicallUser.type == 'patient'
                            ? Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(50),
                                  border: Border.all(
                                      color: Colors.grey.withAlpha(100),
                                      style: BorderStyle.solid,
                                      width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Text(
                                    'Once your doctor reviews the details and if a prescription is nessassary it will appear below. When you doctor fills out the form below we will ask you for address & payment below.'),
                              )
                            : Container(),
                        Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                initialValue: widget.snapshot.data
                                            .containsKey('medication_name') &&
                                        widget.snapshot.data['medication_name']
                                                .length >
                                            0
                                    ? widget.snapshot.data['medication_name']
                                    : '',
                                attribute: 'medName',
                                maxLines: 1,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.black45),
                                  labelText: 'Medication Name',
                                  hintText: 'Enter patient\'s medication name',
                                  fillColor:
                                      widget.snapshot.data['state'] == 'done' ||
                                              medicallUser.type == 'patient' ||
                                              widget.snapshot.data
                                                  .containsKey('pay_date')
                                          ? Colors.grey.withAlpha(30)
                                          : Color.fromRGBO(35, 179, 232, 0.1),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 5.0),
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
                              width: MediaQuery.of(context).size.width / 2 - 10,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                initialValue: widget.snapshot.data
                                            .containsKey('quantity') &&
                                        widget.snapshot.data['quantity']
                                                .length >
                                            0
                                    ? widget.snapshot.data['quantity']
                                    : '0',
                                attribute: 'quantity',
                                maxLines: 1,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(color: Colors.black45),
                                  labelText: 'Quantity',
                                  hintText: '',
                                  fillColor:
                                      widget.snapshot.data['state'] == 'done' ||
                                              medicallUser.type == 'patient' ||
                                              widget.snapshot.data
                                                  .containsKey('pay_date')
                                          ? Colors.grey.withAlpha(30)
                                          : Color.fromRGBO(35, 179, 232, 0.1),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 5.0),
                                  ),
                                ),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: "Required field."),
                                  FormBuilderValidators.min(1,
                                      errorText: "Minimum quantity of 1."),
                                  FormBuilderValidators.max(10,
                                      errorText: "Maximum quantity of 10.")
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2 - 10,
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: FormBuilderDropdown(
                                isExpanded: true,
                                initialValue:
                                    widget.snapshot.data.containsKey('refills')
                                        ? widget.snapshot.data['refills']
                                        : 0,
                                attribute: "refills",
                                readOnly: true,
                                iconSize:
                                    medicallUser.type == 'patient' ? 0 : 24,
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(5, 9, 5, 9),
                                    labelStyle:
                                        TextStyle(color: Colors.black45),
                                    labelText: 'Refills',
                                    fillColor: widget.snapshot.data['state'] ==
                                                'done' ||
                                            medicallUser.type == 'patient' ||
                                            widget.snapshot.data
                                                .containsKey('pay_date')
                                        ? Colors.grey.withAlpha(30)
                                        : Color.fromRGBO(35, 179, 232, 0.1),
                                    filled: true,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: "Required field."),
                                ],
                                isDense: true,
                                items: Iterable<int>.generate(20)
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
                              width: MediaQuery.of(context).size.width - 20,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderDropdown(
                                isExpanded: true,
                                initialValue: widget.snapshot.data
                                            .containsKey('units') &&
                                        widget.snapshot.data['units'].length > 0
                                    ? widget.snapshot.data['units']
                                    : 'Capsule',
                                attribute: "units",
                                iconSize:
                                    medicallUser.type == 'patient' ? 0 : 24,
                                readOnly: true,
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.fromLTRB(5, 9, 5, 9),
                                    labelStyle:
                                        TextStyle(color: Colors.black45),
                                    labelText: 'Units',
                                    fillColor: widget.snapshot.data['state'] ==
                                                'done' ||
                                            medicallUser.type == 'patient' ||
                                            widget.snapshot.data
                                                .containsKey('pay_date')
                                        ? Colors.grey.withAlpha(30)
                                        : Color.fromRGBO(35, 179, 232, 0.1),
                                    filled: true,
                                    disabledBorder: InputBorder.none,
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
                              width: MediaQuery.of(context).size.width / 2 - 10,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                initialValue: widget.snapshot.data
                                            .containsKey('dose') &&
                                        widget.snapshot.data['dose'].length > 0
                                    ? widget.snapshot.data['dose']
                                    : '',
                                attribute: 'dose',
                                maxLines: 1,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Dose',
                                  labelStyle: TextStyle(color: Colors.black45),
                                  fillColor:
                                      widget.snapshot.data['state'] == 'done' ||
                                              medicallUser.type == 'patient' ||
                                              widget.snapshot.data
                                                  .containsKey('pay_date')
                                          ? Colors.grey.withAlpha(30)
                                          : Color.fromRGBO(35, 179, 232, 0.1),
                                  filled: true,
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
                            Container(
                              width: MediaQuery.of(context).size.width / 2 - 10,
                              padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              child: FormBuilderTextField(
                                initialValue: widget.snapshot.data
                                            .containsKey('frequency') &&
                                        widget.snapshot.data['frequency']
                                                .length >
                                            0
                                    ? widget.snapshot.data['frequency']
                                    : '',
                                attribute: 'frequency',
                                maxLines: 1,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Frequency',
                                  labelStyle: TextStyle(color: Colors.black45),
                                  fillColor:
                                      widget.snapshot.data['state'] == 'done' ||
                                              medicallUser.type == 'patient' ||
                                              widget.snapshot.data
                                                  .containsKey('pay_date')
                                          ? Colors.grey.withAlpha(30)
                                          : Color.fromRGBO(35, 179, 232, 0.1),
                                  filled: true,
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
                        Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width - 20,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: FormBuilderTextField(
                                initialValue: widget.snapshot.data
                                            .containsKey('instructions') &&
                                        widget.snapshot.data['instructions']
                                                .length >
                                            0
                                    ? widget.snapshot.data['instructions']
                                    : '',
                                attribute: 'instructions',
                                maxLines: 3,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Instructions',
                                  labelStyle: TextStyle(color: Colors.black45),
                                  fillColor:
                                      widget.snapshot.data['state'] == 'done' ||
                                              medicallUser.type == 'patient' ||
                                              widget.snapshot.data
                                                  .containsKey('pay_date')
                                          ? Colors.grey.withAlpha(30)
                                          : Color.fromRGBO(35, 179, 232, 0.1),
                                  filled: true,
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
                        FutureBuilder(
                            future: db.getPatientDetail(medicallUser),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return PrescriptionPayment(
                                  scriptData: this.widget.snapshot.data,
                                  pageScrollCtrl: this._scrollController,
                                );
                              } else {
                                return Container();
                              }
                            })
                      ],
                    ),
                  )
                ],
              ),
            )),
      ),
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
}
