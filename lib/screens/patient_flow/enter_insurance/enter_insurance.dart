import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/enter_insurance/enter_insurance_view_model.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reclassify_visit/reclassify_visit.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/direct_select.dart';
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
import 'package:super_rich_text/super_rich_text.dart';

class EnterInsuranceScreen extends StatefulWidget {
  final EnterInsuranceViewModel model;
  final Symptom symptom;

  const EnterInsuranceScreen({@required this.model, @required this.symptom});

  static Widget create(BuildContext context, Symptom symptom) {
    final NonAuthDatabase nonAuthDatabase =
        Provider.of<NonAuthDatabase>(context);
    final AuthBase auth = Provider.of<AuthBase>(context);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return ChangeNotifierProvider<EnterInsuranceViewModel>(
      create: (context) => EnterInsuranceViewModel(
        nonAuthDatabase: nonAuthDatabase,
        symptom: symptom,
        auth: auth,
        tempUserProvider: tempUserProvider,
      ),
      child: Consumer<EnterInsuranceViewModel>(
        builder: (_, model, __) => EnterInsuranceScreen(
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
  _EnterInsuranceScreenState createState() => _EnterInsuranceScreenState();
}

class _EnterInsuranceScreenState extends State<EnterInsuranceScreen>
    with SingleTickerProviderStateMixin {
  EnterInsuranceViewModel get model => widget.model;
  Symptom get symptom => widget.symptom;
  AnimationController controller;
  Animation<Offset> offset;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    offset = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(-0.5, 0.0))
        .animate(controller);
  }

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  Future<void> _addEmailToWaitList() async {
    try {
      await model.addEmailToWaitList();
      AppUtil().showFlushBar(
          "You have been added to our waitlist. We will notify you once we are in your area!",
          context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    try {
      String state = await model.validateZipCodeAndInsurance();

      if (state != null) {
        SelectProviderScreen.show(
          context: context,
          symptom: symptom.name,
          state: state,
          insurance: model.insurance,
          filter: model.proceedWithoutInsuranceSelected
              ? SelectProviderFilter.NoInsurance
              : SelectProviderFilter.InNetwork,
        );
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
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
          title: "Your Insurance",
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
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
          _buildZipCodeForm(),
          if (model.showInsuranceWidgets)
            _buildInsuranceWidgets(model.showInsuranceWidgets),
        ],
      ),
      SizedBox(
        height: 24,
      ),
      if (model.proceedWithoutInsuranceSelected)
        _buildInsuranceWaiverCheckbox(),
      _buildVerifyButton(),
      if (model.showEmailField) ..._buildNotifyTextField(),
    ];
  }

  Widget _buildZipCodeForm() {
    return TextField(
      minLines: 1,
      maxLength: 5,
      keyboardType: TextInputType.number,
      readOnly: false,
      onChanged: model.updateZipcode,
      onSubmitted: (state) {
        _submit();
      },
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.grey.withAlpha(20),
        labelText: 'Zip Code',
        labelStyle: TextStyle(color: Colors.black45),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return ReusableRaisedButton(
      title: "Continue",
      onPressed: _submit,
    );
  }

  List<Widget> _buildNotifyTextField() {
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
        title: "Submit email",
        onPressed: _addEmailToWaitList,
      ),
    ];
  }

  Widget _buildInsuranceWidgets(bool loading) {
    switch (controller.status) {
      case AnimationStatus.completed:
        if (loading) {
          controller.reverse();
        }
        break;
      case AnimationStatus.dismissed:
        if (!loading) {
          controller.forward();
        }
        break;
      default:
    }
    return AnimatedOpacity(
      opacity: loading ? 1 : 0,
      duration: Duration(milliseconds: 500),
      child: SlideTransition(
        position: offset,
        child: Column(
          children: [
            SizedBox(height: 32),
            Text(
              'Please enter your insurance',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(
              height: 8,
            ),
            Center(
              child: Text(
                "This helps us show you the doctors covered by your plan.",
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            DirectSelect(
              itemExtent: 60.0,
              selectedIndex: model.selectedItemIndex,
              child: CustomSelectionItem(
                isForList: false,
                title: model.insurance,
              ),
              onSelectedItemChanged: (index) =>
                  model.updateWith(selectedItemIndex: index),
              items: _buildInsuranceListItem(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceWaiverCheckbox() {
    return Column(
      children: [
        Center(
          child: Text(
            "To proceed without insurance you will have to agree to our insurance waiver, which ensures that you agree not to file an insurance claim separately after completing this visit. This waiver protects our doctors from any legal issues (between them and insurance companies) that may arise from this.",
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        CheckboxListTile(
          title: Title(
            color: Colors.blue,
            child: SuperRichText(
              text: 'I agree to Medicall’s <waiver>Insurance Waiver<waiver>.',
              style: Theme.of(context).textTheme.bodyText2,
              othersMarkers: [
                MarkerText.withSameFunction(
                  marker: '<waiver>',
                  function: () => Navigator.of(context).pushNamed('/terms'),
                  onError: (msg) => print('$msg'),
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
          value: model.waiverCheck,
          onChanged: (waiverCheck) =>
              model.updateWith(waiverCheck: waiverCheck),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  List<Widget> _buildInsuranceListItem() {
    return model.insuranceOptions
        .map((val) => CustomSelectionItem(
              title: val,
            ))
        .toList();
  }
}
