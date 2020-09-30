import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/registration/update_provider_info/update_provider_info_form.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_registration_view_model.dart';

class UpdateProviderInfoScreen extends StatefulWidget {
  final ProviderRegistrationViewModel model;
  final ProfileInputType inputType;

  const UpdateProviderInfoScreen({Key key, this.model, this.inputType})
      : super(key: key);

  static Widget create(BuildContext context, ProfileInputType inputType) {
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
        builder: (_, model, __) => UpdateProviderInfoScreen(
          model: model,
          inputType: inputType,
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
                inputType: widget.inputType,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
