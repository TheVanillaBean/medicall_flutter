import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class ZipCodeVerifyScreen extends StatefulWidget {
  ZipCodeVerifyScreen({Key key}) : super(key: key);

  @override
  _ZipCodeVerifyScreenState createState() => _ZipCodeVerifyScreenState();
}

class _ZipCodeVerifyScreenState extends State<ZipCodeVerifyScreen> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
    Database db = Provider.of<Database>(context);
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              );
            },
          ),
        ),
        body: Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Let\'s make sure we are in your area.',
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(height: 80),
                    FormBuilder(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            FormBuilderTextField(
                              attribute: 'zipcode',
                              minLines: 1,
                              maxLength: 5,
                              keyboardType: TextInputType.number,
                              readOnly: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.withAlpha(50),
                                labelText: 'Zip Code',
                                labelStyle: TextStyle(color: Colors.black45),
                              ),
                              validators: [
                                FormBuilderValidators.required(
                                    errorText: "Required field."),
                              ],
                            )
                          ],
                        )),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () async {
                      db.getAllProviders().listen((element) {
                        for (var i = 0; i < element.documents.length; i++) {
                          String state = element.documents[i].data['address']
                              .split(',')[2]
                              .split(' ')[1];
                          String formAnswer = formKey.currentState
                              .fields['zipcode'].currentState.value;
                          String enteredState = getState(formAnswer);
                          if (state == enteredState) {
                            Navigator.pushNamed(context, '/selectProvider');
                            return true;
                          }
                        }
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              title: Text(
                                "We are not in your area yet",
                                style: TextStyle(color: Colors.blue),
                              ),
                              content: Text(
                                "We will be in your area soon, signup below to be the first to get notified when we do,",
                                style: TextStyle(fontSize: 12, height: 1.5),
                              ),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                FlatButton(
                                  child: Text("Notify me"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return false;
                      });
                    },
                    padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}

String getState(zipcode) {
  // Ensure we don't parse strings starting with 0 as octal values
  int thiszip = int.parse(zipcode);

  String st;
  String state;

  // Code blocks alphabetized by state
  if (thiszip >= 35000 && thiszip <= 36999) {
    st = 'AL';
    state = 'Alabama';
  } else if (thiszip >= 99500 && thiszip <= 99999) {
    st = 'AK';
    state = 'Alaska';
  } else if (thiszip >= 85000 && thiszip <= 86999) {
    st = 'AZ';
    state = 'Arizona';
  } else if (thiszip >= 71600 && thiszip <= 72999) {
    st = 'AR';
    state = 'Arkansas';
  } else if (thiszip >= 90000 && thiszip <= 96699) {
    st = 'CA';
    state = 'California';
  } else if (thiszip >= 80000 && thiszip <= 81999) {
    st = 'CO';
    state = 'Colorado';
  } else if (thiszip >= 6000 && thiszip <= 6999) {
    st = 'CT';
    state = 'Connecticut';
  } else if (thiszip >= 19700 && thiszip <= 19999) {
    st = 'DE';
    state = 'Delaware';
  } else if (thiszip >= 32000 && thiszip <= 34999) {
    st = 'FL';
    state = 'Florida';
  } else if (thiszip >= 30000 && thiszip <= 31999) {
    st = 'GA';
    state = 'Georgia';
  } else if (thiszip >= 96700 && thiszip <= 96999) {
    st = 'HI';
    state = 'Hawaii';
  } else if (thiszip >= 83200 && thiszip <= 83999) {
    st = 'ID';
    state = 'Idaho';
  } else if (thiszip >= 60000 && thiszip <= 62999) {
    st = 'IL';
    state = 'Illinois';
  } else if (thiszip >= 46000 && thiszip <= 47999) {
    st = 'IN';
    state = 'Indiana';
  } else if (thiszip >= 50000 && thiszip <= 52999) {
    st = 'IA';
    state = 'Iowa';
  } else if (thiszip >= 66000 && thiszip <= 67999) {
    st = 'KS';
    state = 'Kansas';
  } else if (thiszip >= 40000 && thiszip <= 42999) {
    st = 'KY';
    state = 'Kentucky';
  } else if (thiszip >= 70000 && thiszip <= 71599) {
    st = 'LA';
    state = 'Louisiana';
  } else if (thiszip >= 3900 && thiszip <= 4999) {
    st = 'ME';
    state = 'Maine';
  } else if (thiszip >= 20600 && thiszip <= 21999) {
    st = 'MD';
    state = 'Maryland';
  } else if (thiszip >= 1000 && thiszip <= 2799) {
    st = 'MA';
    state = 'Massachusetts';
  } else if (thiszip >= 48000 && thiszip <= 49999) {
    st = 'MI';
    state = 'Michigan';
  } else if (thiszip >= 55000 && thiszip <= 56999) {
    st = 'MN';
    state = 'Minnesota';
  } else if (thiszip >= 38600 && thiszip <= 39999) {
    st = 'MS';
    state = 'Mississippi';
  } else if (thiszip >= 63000 && thiszip <= 65999) {
    st = 'MO';
    state = 'Missouri';
  } else if (thiszip >= 59000 && thiszip <= 59999) {
    st = 'MT';
    state = 'Montana';
  } else if (thiszip >= 27000 && thiszip <= 28999) {
    st = 'NC';
    state = 'North Carolina';
  } else if (thiszip >= 58000 && thiszip <= 58999) {
    st = 'ND';
    state = 'North Dakota';
  } else if (thiszip >= 68000 && thiszip <= 69999) {
    st = 'NE';
    state = 'Nebraska';
  } else if (thiszip >= 88900 && thiszip <= 89999) {
    st = 'NV';
    state = 'Nevada';
  } else if (thiszip >= 3000 && thiszip <= 3899) {
    st = 'NH';
    state = 'New Hampshire';
  } else if (thiszip >= 7000 && thiszip <= 8999) {
    st = 'NJ';
    state = 'New Jersey';
  } else if (thiszip >= 87000 && thiszip <= 88499) {
    st = 'NM';
    state = 'New Mexico';
  } else if (thiszip >= 10000 && thiszip <= 14999) {
    st = 'NY';
    state = 'New York';
  } else if (thiszip >= 43000 && thiszip <= 45999) {
    st = 'OH';
    state = 'Ohio';
  } else if (thiszip >= 73000 && thiszip <= 74999) {
    st = 'OK';
    state = 'Oklahoma';
  } else if (thiszip >= 97000 && thiszip <= 97999) {
    st = 'OR';
    state = 'Oregon';
  } else if (thiszip >= 15000 && thiszip <= 19699) {
    st = 'PA';
    state = 'Pennsylvania';
  } else if (thiszip >= 300 && thiszip <= 999) {
    st = 'PR';
    state = 'Puerto Rico';
  } else if (thiszip >= 2800 && thiszip <= 2999) {
    st = 'RI';
    state = 'Rhode Island';
  } else if (thiszip >= 29000 && thiszip <= 29999) {
    st = 'SC';
    state = 'South Carolina';
  } else if (thiszip >= 57000 && thiszip <= 57999) {
    st = 'SD';
    state = 'South Dakota';
  } else if (thiszip >= 37000 && thiszip <= 38599) {
    st = 'TN';
    state = 'Tennessee';
  } else if ((thiszip >= 75000 && thiszip <= 79999) ||
      (thiszip >= 88500 && thiszip <= 88599)) {
    st = 'TX';
    state = 'Texas';
  } else if (thiszip >= 84000 && thiszip <= 84999) {
    st = 'UT';
    state = 'Utah';
  } else if (thiszip >= 5000 && thiszip <= 5999) {
    st = 'VT';
    state = 'Vermont';
  } else if (thiszip >= 22000 && thiszip <= 24699) {
    st = 'VA';
    state = 'Virgina';
  } else if (thiszip >= 20000 && thiszip <= 20599) {
    st = 'DC';
    state = 'Washington DC';
  } else if (thiszip >= 98000 && thiszip <= 99499) {
    st = 'WA';
    state = 'Washington';
  } else if (thiszip >= 24700 && thiszip <= 26999) {
    st = 'WV';
    state = 'West Virginia';
  } else if (thiszip >= 53000 && thiszip <= 54999) {
    st = 'WI';
    state = 'Wisconsin';
  } else if (thiszip >= 82000 && thiszip <= 83199) {
    st = 'WY';
    state = 'Wyoming';
  } else {
    st = 'none';
    state = 'none';
  }

  return st;
}
