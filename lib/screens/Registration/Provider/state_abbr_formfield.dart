import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StateAbbrFormField extends StatelessWidget {
  const StateAbbrFormField({
    this.onChanged,
    this.icon,
    this.labelText,
    this.hint,
    this.keyboardType,
    this.validator,
    this.controller,
    this.enabled,
    this.errorText,
    this.obscureText,
  });
  final ValueChanged<String> onChanged;
  final Icon icon;
  final String labelText;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final String errorText;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;
  final List<String> _states = const <String>[
    "AK",
    "AL",
    "AR",
    "AS",
    "AZ",
    "CA",
    "CO",
    "CT",
    "DC",
    "DE",
    "FL",
    "GA",
    "GU",
    "HI",
    "IA",
    "ID",
    "IL",
    "IN",
    "KS",
    "KY",
    "LA",
    "MA",
    "MD",
    "ME",
    "MI",
    "MN",
    "MO",
    "MP",
    "MS",
    "MT",
    "NC",
    "ND",
    "NE",
    "NH",
    "NJ",
    "NM",
    "NV",
    "NY",
    "OH",
    "OK",
    "OR",
    "PA",
    "PR",
    "RI",
    "SC",
    "SD",
    "TN",
    "TX",
    "UM",
    "UT",
    "VA",
    "VI",
    "VT",
    "WA",
    "WI",
    "WV",
    "WY"
  ];

  @override
  Widget build(BuildContext context) {
    final ProviderRegistrationViewModel model =
        Provider.of<ProviderRegistrationViewModel>(context);
    return Container(
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        child: FormField(builder: (FormFieldState state) {
          return InputDecorator(
              decoration: InputDecoration(
                icon: IconTheme(
                    data: IconThemeData(color: Colors.black54), child: icon),
                labelText: labelText,
                labelStyle: TextStyle(fontSize: 16, color: Colors.black54),
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
              isEmpty: model.medLicenseState == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: model.medLicenseState.isNotEmpty
                      ? model.medLicenseState
                      : null,
                  isDense: true,
                  onChanged: onChanged,
                  items: _states.map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }).toList(),
                ),
              ));
        }));
  }
}
