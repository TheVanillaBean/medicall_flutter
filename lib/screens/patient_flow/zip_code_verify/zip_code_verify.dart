import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/verify_insurance/verify_insurance.dart';
import 'package:Medicall/screens/patient_flow/zip_code_verify/zip_code_view_model.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
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
    final AuthBase auth = Provider.of<AuthBase>(context);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return ChangeNotifierProvider<ZipCodeViewModel>(
      create: (context) => ZipCodeViewModel(
        nonAuthDatabase: nonAuthDatabase,
        symptom: symptom,
        auth: auth,
        tempUserProvider: tempUserProvider,
      ),
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

  Future<void> _addEmailToWaitList() async {
    try {
      await model.submit();
      AppUtil().showFlushBar(
          "You have been added to our waitlist. We will notify you once we are in your area!",
          context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _submit() async {
    String state = await model.areProvidersInArea(model.zipcode);
    if (state != null) {
      model.tempUserProvider.setUser(userType: USER_TYPE.PATIENT);
      model.tempUserProvider.user.mailingZipCode = model.zipcode;
      model.tempUserProvider.user.mailingState = state;
      VerifyInsurance.show(
        context: context,
        pushReplaceNamed: false,
        symptom: symptom,
      );
      // SelectProviderScreen.show(
      //   context: context,
      //   symptom: symptom,
      //   state: state,
      // );
    } else {
      model.updateWith(showEmailField: true);
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
                    PatientDashboardScreen.show(
                        context: context, pushReplaceNamed: true);
                  } else {
                    WelcomeScreen.show(context: context);
                  }
                })
          ]),
      body: KeyboardDismisser(
        child: SingleChildScrollView(
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
        height: 24,
      ),
      buildVerifyButton(),
      if (model.showEmailField) ...buildNotifyTextField(),
    ];
  }

  Widget buildZipCodeForm() {
    return TextField(
      minLines: 1,
      maxLength: 5,
      keyboardType: TextInputType.number,
      readOnly: false,
      onChanged: model.updateZipcode,
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.grey.withAlpha(20),
        labelText: 'Zip Code',
        labelStyle: TextStyle(color: Colors.black45),
      ),
    );
  }

  Widget buildVerifyButton() {
    return ReusableRaisedButton(
      title: "Continue",
      onPressed: _submit,
    );
  }

  List<Widget> buildNotifyTextField() {
    return [
      SizedBox(height: 32),
      Center(
        child: Text(
          "We are not in your area yet :(",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      SizedBox(height: 8),
      Center(
        child: Text(
          "Sign up below to be the first to get notified when we are.\nYou will receive a 20% off coupon for your first visit by joining the waitlist.",
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
      SizedBox(height: 16),
      TextField(
        autocorrect: false,
        style: Theme.of(context).textTheme.bodyText1,
        keyboardType: TextInputType.emailAddress,
        onChanged: model.updateEmail,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'jane@doe.com',
          fillColor: Colors.grey.withAlpha(40),
          filled: true,
          prefixIcon: Icon(
            Icons.email,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          errorText: model.emailErrorText,
          enabled: model.isLoading == false,
        ),
      ),
      SizedBox(height: 8),
      ReusableRaisedButton(
        color: Theme.of(context).colorScheme.primary,
        title: "Enter your email",
        onPressed: _addEmailToWaitList,
      ),
    ];
  }
}
