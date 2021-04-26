import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/form_submit_button.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/flavor_settings.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'nylas_connect_view_model.dart';

class NylasConnect extends StatelessWidget {
  final NylasConnectViewModel model;

  const NylasConnect({@required this.model});

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final FlavorSettings settings =
        Provider.of<FlavorSettings>(context, listen: false);
    return ChangeNotifierProvider<NylasConnectViewModel>(
      create: (context) => NylasConnectViewModel(
        auth: auth,
        userProvider: userProvider,
        nylasConnectUrl: settings.nylasConnectRedirectURl,
      ),
      child: Consumer<NylasConnectViewModel>(
        builder: (_, model, __) => NylasConnect(
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
        Routes.nylasConnect,
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.nylasConnect,
      );
    }
  }

  void _navigateToNylasURL() async {
    String url = await model.getNylasConnectURL();
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
        title: "Connect to your Calendar",
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
              if (snapshot.data.data()['nylas_connected'] == true) {
                MedicallUser provider = MedicallUser.fromMap(
                    userType: USER_TYPE.PROVIDER,
                    data: snapshot.data.data(), //lol
                    uid: user.uid);
                this.model.userProvider.user = provider;
                return _buildNylasAuthenticatedWidget(context);
              } else {
                return _buildNylasUnauthenticatedWidget(context);
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget _buildNylasAuthenticatedWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Success! You are now ready to begin accepting live visit consultations!",
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

  Widget _buildNylasUnauthenticatedWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "You are almost done with your account registration, but there is just one more step. Before you can begin accepting patient consultations, you must first connect a calendar and customize your availability for live visits. We use a third-party secure HIPAA compliant service called Nylas to make scheduling easy for you and your patients.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          ReusableRaisedButton(
            title: "Connect with Nylas",
            onPressed: model.isLoading ? null : _navigateToNylasURL,
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
}
