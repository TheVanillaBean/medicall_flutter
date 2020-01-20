import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/stripe_payment_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:Medicall/secrets.dart' as secrets;

class PrescriptionPayment extends StatefulWidget {
  PrescriptionPayment({Key key}) : super(key: key);

  @override
  _PrescriptionPaymentState createState() => _PrescriptionPaymentState();
}

class _PrescriptionPaymentState extends State<PrescriptionPayment> {
  bool userShippingSelected = false;
  String shippingAddress = '';
  String shipTo = '';
  List<dynamic> addressList = [];
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: secrets.kGoogleApiKey);
  final TextEditingController typeAheadController = TextEditingController();
  GlobalKey<FormBuilderState> prescriptionPaymentKey = GlobalKey();

  ValueChanged onChangedCheckBox;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    typeAheadController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
    MedicallUser medicallUser = auth.medicallUser;
    var consultSnapshot = auth.consultSnapshot.data;
    onChangedCheckBox = (val) {
      if (val.length > 0) {
        if (val.length >= 2 && val[1] == 'pickup') {
          val.removeAt(0);
        }
        if (val.length >= 2 && val[1] == 'delivery') {
          val.removeAt(0);
        }
        shipTo = val[0];
        setState(() {
          if (prescriptionPaymentKey != null &&
              prescriptionPaymentKey.currentState != null &&
              prescriptionPaymentKey
                      .currentState.fields['shipTo'].currentState.value.length >
                  0) {
            userShippingSelected = true;
          } else {
            userShippingSelected = false;
          }
        });
      } else {
        setState(() {
          userShippingSelected = false;
        });
      }
    };
    if (shipTo == 'delivery') {
      typeAheadController.text = medicallUser.address;
      shippingAddress = medicallUser.address;
    } else {
      typeAheadController.text = '';
    }
    return consultSnapshot.containsKey('medication_name') &&
            consultSnapshot['medication_name'].length > 0
        ? FormBuilder(
            key: prescriptionPaymentKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
                  child: FormBuilderCheckboxList(
                    leadingInput: true,
                    attribute: 'shipTo',
                    initialValue: [shipTo],
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                    onChanged: onChangedCheckBox,
                    options: [
                      FormBuilderFieldOption(
                        value: 'pickup',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Local pharmacy pickup',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                            Text(
                              '\$80',
                              style: TextStyle(fontSize: 21),
                            ),
                          ],
                        ),
                      ),
                      FormBuilderFieldOption(
                        value: 'delivery',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Ship directly to my door.',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                            Text(
                              '\$60',
                              style: TextStyle(fontSize: 21),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Visibility(
                    visible: userShippingSelected,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: Text(
                                'Please enter the address below where you want your prescription sent.'),
                          ),
                          TypeAheadFormField(
                            hideOnEmpty: true,
                            suggestionsBoxVerticalOffset: 5.0,
                            hideOnError: true,
                            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            textFieldConfiguration: TextFieldConfiguration(
                              onEditingComplete: () {
                                if (addressList.length == 0) {
                                  typeAheadController.clear();
                                }
                              },
                              onSubmitted: (v) {
                                if (addressList.length == 0) {
                                  typeAheadController.clear();
                                }
                                if (addressList.indexOf(v) == -1) {
                                  typeAheadController.clear();
                                }
                              },
                              controller: typeAheadController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                  hintText: shipTo == 'delivery'
                                      ? medicallUser.address
                                      : '',
                                  labelText: shipTo == 'delivery'
                                      ? 'Street Address'
                                      : 'Local Pharmacy Address',
                                  fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                  filled: true,
                                  disabledBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  border: InputBorder.none),
                            ),
                            suggestionsCallback: (pattern) async {
                              addressList = [];
                              if (pattern.length > 0) {
                                return await _places
                                    .searchByText(pattern)
                                    .then((val) {
                                  addressList
                                      .add(val.results.first.formattedAddress);
                                  return addressList;
                                });
                              } else {
                                return addressList;
                              }
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            transitionBuilder:
                                (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (suggestion) {
                              shippingAddress = suggestion;
                              typeAheadController.text = suggestion;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter valid address';
                              } else {
                                if (addressList.indexOf(value) == -1) {
                                  typeAheadController.clear();
                                } else {
                                  shippingAddress = value;
                                }
                                return null;
                              }
                            },
                            onSaved: (value) {
                              shippingAddress = value;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          shippingAddress.length > 0
                              ? FlatButton(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  color: Theme.of(
                                          GlobalNavigatorKey.key.currentContext)
                                      .colorScheme
                                      .secondary,
                                  onPressed: () async {
                                    if (auth.hasPayment) {
                                      await PaymentService().chargePayment(
                                          consultSnapshot['price'],
                                          consultSnapshot['consultType'] +
                                              ' consult with ' +
                                              consultSnapshot['provider']);
                                    } else {
                                      await StripeSource.addSource()
                                          .then((String token) async {
                                        PaymentService().addCard(token);
                                      });
                                    }
                                  },
                                  child: Text(
                                    auth.hasPayment
                                        ? 'Pay for Presciption'
                                        : 'Add Card',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(GlobalNavigatorKey
                                              .key.currentContext)
                                          .colorScheme
                                          .onBackground,
                                      letterSpacing: 1.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ))
              ],
            ),
          )
        : SizedBox();
  }
}
