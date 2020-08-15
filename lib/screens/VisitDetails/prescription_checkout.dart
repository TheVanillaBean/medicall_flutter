import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/VisitDetails/prescription_checkout_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:provider/provider.dart';

class PrescriptionCheckout extends StatefulWidget {
  final PrescriptionCheckoutViewModel model;

  PrescriptionCheckout({@required this.model});

  static Widget create(
    BuildContext context,
    String consultId,
    List<TreatmentOptions> treatmentOptions,
  ) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return ChangeNotifierProvider<PrescriptionCheckoutViewModel>(
      create: (context) => PrescriptionCheckoutViewModel(
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
        consultId: consultId,
        treatmentOptions: treatmentOptions,
      ),
      child: Consumer<PrescriptionCheckoutViewModel>(
        builder: (_, model, __) => PrescriptionCheckout(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    String consultId,
    List<TreatmentOptions> treatmentOptions,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.prescriptionCheckout,
      arguments: {
        'consultId': consultId,
        'treatmentOptions': treatmentOptions,
      },
    );
  }

  @override
  _PrescriptionCheckoutState createState() => _PrescriptionCheckoutState();
}

class _PrescriptionCheckoutState extends State<PrescriptionCheckout> {
  final TextEditingController _shippingAddressController =
      TextEditingController();

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final FocusNode _shippingAddressFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _zipCodeFocusNode = FocusNode();

  PrescriptionCheckoutViewModel get model => widget.model;

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  void dispose() {
    _shippingAddressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _shippingAddressFocusNode.dispose();
    _cityFocusNode.dispose();
    _zipCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await model.submit();
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Prescription Checkout",
        theme: Theme.of(context),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Select the prescriptions you would like to receive",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: CheckboxGroup(
                      labels: ["Finasteride", "Minoxidil 5%", "Biotin"],
                      itemBuilder: (Checkbox cb, Text txt, int i) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    txt.data,
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Text(
                                    "\$29",
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ],
                              ),
                            ),
                            cb,
                          ],
                        );
                      },
                    ),
                  ),
                  Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FormBuilderCheckbox(
                      attribute: 'shipping_address',
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Use my account address",
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "${model.userProvider.user.address} ${model.userProvider.user.city} ${model.userProvider.user.state} ${model.userProvider.user.zipCode}",
                                  maxLines: 3,
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      initialValue: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildAddressInputFields(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInputFields() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          buildShippingAddressTextField(
            controller: _shippingAddressController,
            focusNode: _shippingAddressFocusNode,
            labelText: "Shipping Address",
            hint: "541 Main St",
            enabled: model.isLoading == false,
            errorText: model.shippingAddressErrorText,
            onChanged: model.updateShippingAddress,
          ),
          buildShippingAddressTextField(
            controller: _cityController,
            focusNode: _cityFocusNode,
            labelText: "City",
            hint: "Boston",
            enabled: model.isLoading == false,
            onChanged: model.updateCity,
          ),
          CustomDropdownFormField(
            addPadding: false,
            labelText: 'State',
            onChanged: model.updateState,
            items: model.states,
            selectedItem: model.state,
          ),
          buildShippingAddressTextField(
            textInputType: TextInputType.number,
            maxLength: 5,
            controller: _zipCodeController,
            focusNode: _zipCodeFocusNode,
            labelText: "Zip Code",
            hint: "02101",
            enabled: model.isLoading == false,
            errorText: model.zipCodeErrorText,
            onChanged: model.updateZipCode,
          ),
        ],
      ),
    );
  }

  Widget buildShippingAddressTextField({
    TextEditingController controller,
    FocusNode focusNode,
    String labelText,
    String hint,
    String errorText,
    Function onChanged,
    bool enabled,
    TextInputType textInputType = TextInputType.text,
    int maxLength,
  }) {
    return TextFormField(
      keyboardType: textInputType,
      maxLength: maxLength,
      autocorrect: false,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      autofocus: true,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        counterText: "",
        labelText: labelText,
        errorText: errorText,
        labelStyle: Theme.of(context).textTheme.bodyText1,
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.caption,
        enabled: enabled,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black26,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
      ),
      validator: (input) {
        if (input.isEmpty) {
          return '$labelText is required';
        }
        return null;
      },
    );
  }

  //Keep just in case for now
//  void _buildAddressToggleBox() {
//  Padding(
//  padding: const EdgeInsets.symmetric(horizontal: 30),
//  child: Row(
//  mainAxisAlignment: MainAxisAlignment.center,
//  children: [
//  Expanded(
//  child: Column(
//  crossAxisAlignment: CrossAxisAlignment.start,
//  children: [
//  Text(
//  "Use my account address",
//  maxLines: 1,
//  style: Theme.of(context).textTheme.headline6,
//  ),
//  Text(
//  "${model.userProvider.user.address} ${model.userProvider.user.city} ${model.userProvider.user.state} ${model.userProvider.user.zipCode}",
//  maxLines: 1,
//  style: Theme.of(context).textTheme.subtitle2,
//  ),
//  Switch(
//  value: true,
//  activeColor:
//  Theme.of(context).colorScheme.primary,
//  activeTrackColor:
//  Theme.of(context).colorScheme.primary,
//  onChanged: (value) => {},
//  ),
//  ],
//  ),
//  ),
//  ],
//  ),
//  ),
//  }

}
