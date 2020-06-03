import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/symptoms.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Welcome/zip_code_view_model.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class ZipCodeVerifyScreen extends StatefulWidget {
  final ZipCodeViewModel model;
  final Symptom symptom;

  const ZipCodeVerifyScreen({@required this.model, @required this.symptom});

  static Widget create(BuildContext context, Symptom symptom) {
    final NonAuthDatabase nonAuthDatabase =
        Provider.of<NonAuthDatabase>(context);
    return ChangeNotifierProvider<ZipCodeViewModel>(
      create: (context) =>
          ZipCodeViewModel(nonAuthDatabase: nonAuthDatabase, symptom: symptom),
      child: Consumer<ZipCodeViewModel>(
        builder: (_, model, __) => ZipCodeVerifyScreen(
          model: model,
          symptom: symptom,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.zipCodeVerify,
      arguments: {
        'symptom': symptom,
      },
    );
  }

  @override
  _ZipCodeVerifyScreenState createState() => _ZipCodeVerifyScreenState();
}

class _ZipCodeVerifyScreenState extends State<ZipCodeVerifyScreen> {
  ZipCodeViewModel get model => widget.model;
  Symptom get symptom => widget.symptom;

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  Future<void> _submit() async {
    bool providersInArea = await model.areProvidersInArea(zipCode);
    if (providersInArea) {
      Navigator.pushNamed(context, '/selectProvider');
    } else {
      _showDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildChildren(),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return <Widget>[
      Text(
        'Let\'s make sure we are in your area.',
        style: TextStyle(fontSize: 30),
      ),
      buildZipCodeForm(),
      buildVerifyButton(),
    ];
  }

  Widget buildZipCodeForm() {
    return FormBuilder(
      key: formKey,
      child: Column(
        children: <Widget>[
          FormBuilderTextField(
            attribute: 'zipcode',
            minLines: 1,
            maxLength: 5,
            keyboardType: TextInputType.number,
            readOnly: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.withAlpha(50),
              labelText: 'Zip Code',
              labelStyle: TextStyle(color: Colors.black45),
            ),
            validators: [
              FormBuilderValidators.required(
                errorText: "Required field.",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildVerifyButton() {
    return FlatButton(
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: _submit,
      padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      child: Column(
        children: <Widget>[
          Text(
            'Continue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    return await PlatformAlertDialog(
      title: "We are not in your area yet",
      content:
          "We will be in your area soon, sign up below to be the first to get notified when we do.",
      defaultActionText: "Notify me",
      onPressed: () => Navigator.of(context).pop(),
      cancelActionText: "No, thank you",
    ).show(context);
  }

  String get zipCode {
    return formKey.currentState.fields['zipcode'].currentState.value;
  }
}
