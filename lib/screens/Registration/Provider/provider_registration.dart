import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_form.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderRegistrationScreen extends StatelessWidget {
  final ProviderRegistrationViewModel model;

  const ProviderRegistrationScreen({@required this.model});

  static Widget create(BuildContext context) {
    final NonAuthDatabase db =
        Provider.of<NonAuthDatabase>(context, listen: false);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return ChangeNotifierProvider<ProviderRegistrationViewModel>(
      create: (context) => ProviderRegistrationViewModel(
        nonAuthDatabase: db,
        auth: auth,
        tempUserProvider: tempUserProvider,
      ),
      child: Consumer<ProviderRegistrationViewModel>(
        builder: (_, model, __) => ProviderRegistrationScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.providerRegistration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
            );
          },
        ),
        title: Text(
          'Provider Registration',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
      ),
      //Content of tabs
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: ProviderRegistrationForm(),
        ),
      ),
    );
  }
}
