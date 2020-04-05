import 'package:Medicall/screens/StripeConnect/stripe_connect_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StripeConnect extends StatelessWidget {
  final StripeConnectStateModel model;

  const StripeConnect({@required this.model});

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<StripeConnectStateModel>(
      create: (context) => StripeConnectStateModel(auth: auth),
      child: Consumer<StripeConnectStateModel>(
        builder: (_, model, __) => StripeConnect(
          model: model,
        ),
      ),
    );
  }

  void navigateToStripeURL() {
    String url = model.getStripeConnectURL();
    print(url);
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
              "Before you can begin accepting patient consultations, you must first connect your bank account information to Medicall. "
              "This ensures that you can get paid for each consultation.",
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            _buildStripeButton(context)
          ],
        ),
      ),
    );
  }

  Material _buildStripeButton(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: AbsorbPointer(
        absorbing: !model.submitted,
        child: InkWell(
          onTap: () => navigateToStripeURL(),
          child: Image.asset(
            "assets/images/stripe-connect-button.png",
            width: width * 0.5,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
