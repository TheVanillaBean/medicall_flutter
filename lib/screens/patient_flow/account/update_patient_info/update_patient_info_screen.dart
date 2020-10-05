import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_form.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_view_model.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdatePatientInfoScreen extends StatefulWidget {
  final UpdatePatientInfoViewModel model;

  UpdatePatientInfoScreen({
    @required this.model,
  });

  static Widget create(
    BuildContext context,
    UpdatePatientInfoViewModel model,
  ) {
    return ChangeNotifierProvider.value(
      value: model,
      child: Consumer<UpdatePatientInfoViewModel>(
        builder: (_, model, __) => UpdatePatientInfoScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    UpdatePatientInfoViewModel model,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.updatePatientInfo,
      arguments: {
        "model": model,
      },
    );
  }

  @override
  _UpdatePatientInfoScreenState createState() =>
      _UpdatePatientInfoScreenState();
}

class _UpdatePatientInfoScreenState extends State<UpdatePatientInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Update Account Information",
        theme: Theme.of(context),
      ),
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
              child: UpdatePatientInfoForm(),
            ),
          ),
        ),
      ),
    );
  }
}
