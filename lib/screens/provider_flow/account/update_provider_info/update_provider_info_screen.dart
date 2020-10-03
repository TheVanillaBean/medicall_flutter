import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_form.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProviderInfoScreen extends StatefulWidget {
  final UpdateProviderInfoViewModel model;

  const UpdateProviderInfoScreen({Key key, this.model}) : super(key: key);

  static Widget create(BuildContext context, ProfileInputType inputType) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    return ChangeNotifierProvider<UpdateProviderInfoViewModel>(
      create: (context) => UpdateProviderInfoViewModel(
        auth: auth,
        profileInputType: inputType,
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
      ),
      child: Consumer<UpdateProviderInfoViewModel>(
        builder: (_, model, __) => UpdateProviderInfoScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show(
      {BuildContext context, ProfileInputType inputType}) async {
    await Navigator.of(context).pushNamed(
      Routes.updateProviderInfo,
      arguments: {
        'inputType': inputType,
      },
    );
  }

  @override
  _UpdateProviderInfoScreenState createState() =>
      _UpdateProviderInfoScreenState();
}

class _UpdateProviderInfoScreenState extends State<UpdateProviderInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Update Account Information",
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
              child: UpdateProviderInfoForm(
                inputType: widget.model.profileInputType,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
