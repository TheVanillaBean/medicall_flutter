import 'package:Medicall/screens/StripeConnect/stripe_connect_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
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

  void _navigateToStripeURL() async {
    String url = await model.getStripeConnectURL();
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true);
    } else {
      throw 'Could not launch url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Connect Your Bank Account'),
      ),
      body: Padding(
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
