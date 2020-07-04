import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteUserOrderScreen extends StatefulWidget {
  final data;
  RouteUserOrderScreen({Key key, @required this.data}) : super(key: key);

  @override
  _RouteUserOrderScreenState createState() => _RouteUserOrderScreenState();
}

class _RouteUserOrderScreenState extends State<RouteUserOrderScreen> {
  ConsultData _consult;
  Future<bool> _onWillPop() async {
    return false;
  }

  User medicallUser = PatientUser();

  @override
  void initState() {
    _consult = widget.data['consult'];
    medicallUser = widget.data['user'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _extImageProvider = Provider.of<ExtImageProvider>(context);
    Database _db = Provider.of<Database>(context);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            title: Text('Order Confirmation'),
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Thank you for your payment of ${_consult.price},',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Doctor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(140.0),
                        child: _consult != null &&
                                _consult.providerProfilePic != null
                            ? Container(
                                child: _extImageProvider.returnNetworkImage(
                                    _consult.providerProfilePic,
                                    cache: true,
                                    fit: BoxFit.cover,
                                    height: 140,
                                    width: 140))
                            : Icon(
                                Icons.account_circle,
                                size: 160,
                              ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        _consult.provider + ' ' + _consult.providerTitles,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        'will provide care for your',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        _consult.consultType == 'Lesion'
                            ? 'Spot'
                            : _consult.consultType,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Your payment has been successful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  color: Theme.of(context).colorScheme.secondaryVariant,
                  onPressed: () {
                    _db.newConsult = ConsultData();
                    Navigator.of(context).pushReplacementNamed('/congrats');
                    _db.newConsult = ConsultData();
                  },
                  textColor: Theme.of(context).colorScheme.onSecondary,
                  child: Text(
                    'Go to Dashboard',
                  ),
                )
              ]),
        ));
  }
}
