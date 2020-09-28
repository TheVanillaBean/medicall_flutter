import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/screens/patient_flow/zip_code_verify/zip_code_view_model.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
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
    String state = await model.areProvidersInArea(zipCode);
    if (state != null) {
      SelectProviderScreen.show(
        context: context,
        symptom: symptom,
        state: state,
      );
    } else {
      _showDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    MedicallUser medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Checking your area.",
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (medicallUser != null) {
                    Navigator.of(context).pushNamed('/dashboard');
                  } else {
                    Navigator.of(context).pushNamed('/welcome');
                  }
                })
          ]),
      body: KeyboardDismisser(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildChildren(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return <Widget>[
      SizedBox(
        height: 60,
      ),
      Column(
        children: <Widget>[
          Text(
            'Please enter your zipcode',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 20,
          ),
          buildZipCodeForm(),
        ],
      ),
      SizedBox(
        height: 10,
      ),
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
              counterText: "",
              filled: true,
              fillColor: Colors.grey.withAlpha(20),
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
    return ReusableRaisedButton(
      title: "Continue",
      onPressed: _submit,
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    bool didPressNotify = await PlatformAlertDialog(
      title: "We are not in your area yet",
      content:
          "We will be in your area soon, sign up below to be the first to get notified when we do.",
      defaultActionText: "Notify me",
      cancelActionText: "No, thank you",
    ).show(context);

    if (didPressNotify) {
      Navigator.of(context).pop();
    }
  }

  String get zipCode {
    return formKey.currentState.fields['zipcode'].currentState.value;
  }
}
