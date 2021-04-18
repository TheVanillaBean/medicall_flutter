import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/form_submit_button.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/ScheduleVisit/schedule_visit_view_model.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleVisit extends StatelessWidget {
  final ScheduleVisitViewModel model;

  const ScheduleVisit({@required this.model});

  static Widget create(BuildContext context, Consult consult) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<ScheduleVisitViewModel>(
      create: (context) => ScheduleVisitViewModel(
        auth: auth,
        userProvider: userProvider,
        consult: consult,
      ),
      child: Consumer<ScheduleVisitViewModel>(
        builder: (_, model, __) => ScheduleVisit(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Consult consult,
  }) async {
    if (pushReplaceNamed) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.scheduleVisit,
        arguments: {
          'consult': consult,
        },
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.scheduleVisit,
        arguments: {
          'consult': consult,
        },
      );
    }
  }

  void _navigateToScheduleURL() async {
    String url = await model.getScheduleUrl();
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true);
    } else {
      throw 'Could not launch url';
    }
  }

  void _navigateToMakePaymentScreen(BuildContext context) {
    MakePayment.show(context: context, consult: model.consult);
  }

  @override
  Widget build(BuildContext context) {
    final user = model.userProvider.user;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Close,
        title: "Schedule Visit",
        theme: Theme.of(context),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('consults')
              .doc(model.consult.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.data()['state'] == "NeedsScheduling") {
                MedicallUser provider = MedicallUser.fromMap(
                    userType: USER_TYPE.PROVIDER,
                    data: snapshot.data.data(), //lol
                    uid: user.uid);
                this.model.userProvider.user = provider;
                return _buildNeedsSchedulingWidget(context);
              } else {
                return _buildScheduledWidget(context);
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget _buildNeedsSchedulingWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "In accordance with state law, you are required to schedule a live visit time with this provider.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          ReusableRaisedButton(
            title: "Schedule Visit",
            onPressed: model.isLoading ? null : _navigateToScheduleURL,
          ),
          SizedBox(height: 16),
          if (model.isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduledWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Success! You may now proceed to the payment screen.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          FormSubmitButton(
              text: "Continue",
              onPressed: () => _navigateToMakePaymentScreen(context)),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
