import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/form_submit_button.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard.dart';
import 'package:Medicall/screens/StripeConnect/stripe_connect_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StripeConnect extends StatelessWidget {
  final StripeConnectStateModel model;

  const StripeConnect({@required this.model});

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<StripeConnectStateModel>(
      create: (context) =>
          StripeConnectStateModel(auth: auth, userProvider: userProvider),
      child: Consumer<StripeConnectStateModel>(
        builder: (_, model, __) => StripeConnect(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
  }) async {
    if (pushReplaceNamed) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.stripeConnect,
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.stripeConnect,
      );
    }
  }

  void _navigateToStripeURL() async {
    String url = await model.getStripeConnectURL();
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true);
    } else {
      throw 'Could not launch url';
    }
  }

  void _navigateToDashboardScreen(BuildContext context) {
    ProviderDashboardScreen.show(context: context, pushReplaceNamed: true);
  }

  @override
  Widget build(BuildContext context) {
    final user = model.userProvider.user;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Close,
        title: "Connect Your Bank Account",
        theme: Theme.of(context),
        onPressed: () => ProviderDashboardScreen.show(
          context: context,
          pushReplaceNamed: true,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.data()['stripe_connect_authorized'] == true) {
                MedicallUser provider = MedicallUser.fromMap(
                    userType: USER_TYPE.PROVIDER,
                    data: snapshot.data.data(), //lol
                    uid: user.uid);
                this.model.userProvider.user = provider;
                return _buildStripeAuthenticatedWidget(context);
              } else {
                return _buildStripeUnauthenticatedWidget(context);
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget _buildStripeAuthenticatedWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Success! You are now registered to use Medicall and can receive consultation requests.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          FormSubmitButton(
              text: "Continue",
              onPressed: () => _navigateToDashboardScreen(context)),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStripeUnauthenticatedWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "You are almost done with your account registration, but there is just one more step. Before you can begin accepting patient consultations, you must first connect your bank account information to Medicall. "
            "This ensures that you can get paid for each consultation.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          _buildStripeButton(context),
          SizedBox(height: 16),
          if (model.isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Material _buildStripeButton(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.red[300],
        onTap: model.isLoading ? null : _navigateToStripeURL,
        child: Image.asset(
          "assets/images/stripe-connect-button.png",
          width: width * 0.6,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
