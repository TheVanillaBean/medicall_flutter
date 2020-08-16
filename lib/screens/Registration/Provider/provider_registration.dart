import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_form.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderRegistrationScreen extends StatefulWidget {
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
  _ProviderRegistrationScreenState createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Provider Registration",
        theme: Theme.of(context),
      ),
      //Content of tabs
      body: Scrollbar(
        controller: widget.model.scrollController,
        child: FadingEdgeScrollView.fromSingleChildScrollView(
          child: SingleChildScrollView(
            controller: widget.model.viewController,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: ProviderRegistrationForm(),
            ),
          ),
        ),
      ),
    );
  }
}
